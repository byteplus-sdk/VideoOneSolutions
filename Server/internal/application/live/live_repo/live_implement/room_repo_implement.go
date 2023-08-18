/*
 * Copyright 2023 CloudWeGo Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package live_implement

import (
	"context"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_room_models"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/db"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"github.com/go-redis/redis/v8"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

const (
	RoomAudienceCountPrefix = "rtc_demo:room_audience_count:"
	RoomRtcMapPrefix        = "rtc_demo:rtc:"
)

const expireTime = 12 * time.Hour

const RoomTable = "live_room"

type RoomRepoImpl struct {
}

func (impl *RoomRepoImpl) Save(ctx context.Context, room *live_entity.LiveRoom) error {
	defer util.CheckPanic()
	err := db.Client.WithContext(ctx).Debug().Table(RoomTable).
		Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "rtc_app_id"}, {Name: "room_id"}},
			UpdateAll: true,
		}).Create(&room).Error
	if err != nil {
		return custom_error.InternalError(err)
	}
	return nil
}

func (impl *RoomRepoImpl) GetActiveRoom(ctx context.Context, appID, roomID string) (*live_entity.LiveRoom, error) {
	var rs *live_entity.LiveRoom
	err := db.Client.WithContext(ctx).Debug().Table(RoomTable).Where("rtc_app_id =? and room_id = ? and status = ?", appID, roomID, live_room_models.RoomStatusStart).First(&rs).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}

	count, _ := impl.GetRoomAudienceCount(ctx, roomID)
	rs.AudienceCount = count

	return rs, nil
}

func (impl *RoomRepoImpl) GetRoom(ctx context.Context, appID, roomID string) (*live_entity.LiveRoom, error) {
	var rs *live_entity.LiveRoom
	err := db.Client.WithContext(ctx).Debug().Table(RoomTable).Where("rtc_app_id =? and room_id = ? and status <> ?", appID, roomID, live_room_models.RoomStatusFinish).First(&rs).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}

	count, _ := impl.GetRoomAudienceCount(ctx, roomID)
	rs.AudienceCount = count

	return rs, nil
}

func (impl *RoomRepoImpl) GetActiveRooms(ctx context.Context, appID string) ([]*live_entity.LiveRoom, error) {
	var rs []*live_entity.LiveRoom
	err := db.Client.WithContext(ctx).Debug().Table(RoomTable).Where("rtc_app_id =? and status = ?", appID, live_room_models.RoomStatusStart).Find(&rs).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}

	return rs, nil
}

func (impl *RoomRepoImpl) GetAllActiveRooms(ctx context.Context) ([]*live_entity.LiveRoom, error) {
	var rs []*live_entity.LiveRoom
	err := db.Client.WithContext(ctx).Debug().Table(RoomTable).Where(" status = ?", live_room_models.RoomStatusStart).Find(&rs).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}

	return rs, nil
}

func (impl *RoomRepoImpl) GetRooms(ctx context.Context, appID string) ([]*live_entity.LiveRoom, error) {
	var rs []*live_entity.LiveRoom
	err := db.Client.WithContext(ctx).Debug().Table(RoomTable).Where("rtc_app_id=? and status <> ?", appID, live_room_models.RoomStatusFinish).Find(&rs).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}

	return rs, nil
}

func (impl *RoomRepoImpl) AddRoomAudienceCount(ctx context.Context, roomID string) error {
	err := redis_cli.Client.IncrBy(ctx, getRoomAudienceCountKey(roomID), 1).Err()
	if err != nil {
		logs.CtxError(ctx, "AddRoomAudienceCount Error: "+err.Error())
		return custom_error.InternalError(err)
	}
	redis_cli.Client.Expire(ctx, getRoomAudienceCountKey(roomID), expireTime)
	return nil
}

func (impl *RoomRepoImpl) SubRoomAudienceCount(ctx context.Context, roomID string) error {
	count, err := redis_cli.Client.Get(ctx, getRoomAudienceCountKey(roomID)).Int64()
	if err != nil {
		logs.CtxError(ctx, "getRoomAudienceCount Error: "+err.Error())
		return custom_error.InternalError(err)
	}
	if count <= 0 {
		return nil
	}
	err = redis_cli.Client.IncrBy(ctx, getRoomAudienceCountKey(roomID), -1).Err()
	if err != nil {
		logs.CtxError(ctx, "SubRoomAudienceCount Error: "+err.Error())
		return custom_error.InternalError(err)
	}
	logs.CtxInfo(ctx, "reduce room user count, roomID:"+roomID)
	return nil
}

func (impl *RoomRepoImpl) GetRoomAudienceCount(ctx context.Context, roomID string) (int, error) {
	count, err := redis_cli.Client.Get(ctx, getRoomAudienceCountKey(roomID)).Int64()
	if err != nil {
		if err == redis.Nil {
			return 0, nil
		}
		return 0, custom_error.InternalError(err)
	}
	return int(count), nil
}

func getRoomAudienceCountKey(roomID string) string {
	return RoomAudienceCountPrefix + roomID
}

func getRoomRtcRoomIDKey(roomID string) string {
	return RoomRtcMapPrefix + roomID
}

func (impl *RoomRepoImpl) SetRoomRtcRoomID(ctx context.Context, roomID string, rtcRoomID string) {
	logs.CtxInfo(ctx, "set rtc_room_id:%s", rtcRoomID)
	redis_cli.Client.Set(ctx, getRoomRtcRoomIDKey(roomID), rtcRoomID, 0)
}

func (impl *RoomRepoImpl) GetRoomRtcRoomID(ctx context.Context, roomID string) string {
	val := redis_cli.Client.Get(ctx, getRoomRtcRoomIDKey(roomID)).Val()
	logs.CtxInfo(ctx, "get  rtc_room_id:%s", val)
	return val
}

func (impl *RoomRepoImpl) DelRoomRtcRoomID(ctx context.Context, roomID string) {
	redis_cli.Client.Del(ctx, getRoomRtcRoomIDKey(roomID))
}

func (impl *RoomRepoImpl) GetRoomByRoomID(ctx context.Context, appID, roomID string) (*live_entity.LiveRoom, error) {
	var rs *live_entity.LiveRoom
	err := db.Client.WithContext(ctx).Debug().Table(RoomTable).Where("rtc_app_id =? and room_id = ?", appID, roomID).First(&rs).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}

	count, _ := impl.GetRoomAudienceCount(ctx, roomID)
	rs.AudienceCount = count

	return rs, nil
}
