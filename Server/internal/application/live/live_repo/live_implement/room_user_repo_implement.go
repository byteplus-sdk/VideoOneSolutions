/*
 * Copyright (c) 2023 BytePlus Pte. Ltd.
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
	"errors"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_room_models"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/db"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

const RoomUserTable = "live_room_user"

type RoomUserRepoImpl struct {
}

func (impl *RoomUserRepoImpl) Save(ctx context.Context, user *live_entity.LiveRoomUser) error {
	defer util.CheckPanic()
	err := db.Client.WithContext(ctx).Debug().Table(RoomUserTable).
		Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "app_id"}, {Name: "room_id"}, {Name: "user_id"}},
			UpdateAll: true,
		}).Create(&user).Error
	if err != nil {
		return custom_error.InternalError(err)
	}
	return nil
}

func (impl *RoomUserRepoImpl) GetActiveUser(ctx context.Context, appID, roomID, userID string) (*live_entity.LiveRoomUser, error) {
	defer util.CheckPanic()
	var rs *live_entity.LiveRoomUser
	err := db.Client.WithContext(ctx).Debug().Table(RoomUserTable).Where("app_id=? and room_id = ? and user_id = ? and status = ?", appID, roomID, userID, live_room_models.RoomUserStatusStart).First(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}

	return rs, nil
}

func (impl *RoomUserRepoImpl) GetUser(ctx context.Context, appID, roomID, userID string) (*live_entity.LiveRoomUser, error) {
	defer util.CheckPanic()
	var rs *live_entity.LiveRoomUser
	err := db.Client.WithContext(ctx).Debug().Table(RoomUserTable).Where("app_id=? and room_id = ? and user_id = ? and status <> ?", appID, roomID, userID, live_room_models.RoomUserStatusFinish).First(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}

	return rs, nil
}

func (impl *RoomUserRepoImpl) GetUsersByRoomIDUserIDs(ctx context.Context, appID, roomID string, userIDs []string) (map[string]*live_entity.LiveRoomUser, error) {
	defer util.CheckPanic()
	var users []*live_entity.LiveRoomUser
	err := db.Client.WithContext(ctx).Debug().Table(RoomUserTable).Where("app_id=? and room_id = ? and user_id in ? and status = ?", appID, roomID, userIDs, live_room_models.RoomUserStatusStart).Find(&users).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}

	rs := make(map[string]*live_entity.LiveRoomUser)

	for _, user := range users {
		rs[user.UserID] = user
	}

	return rs, nil
}

func (impl *RoomUserRepoImpl) GetAudiencesByRoomID(ctx context.Context, appID string, roomID string) ([]*live_entity.LiveRoomUser, error) {
	defer util.CheckPanic()
	var rs []*live_entity.LiveRoomUser
	err := db.Client.WithContext(ctx).Debug().Table(RoomUserTable).Where("app_id=? and room_id = ? and user_role = ?  and status = ?", appID, roomID, live_room_models.RoomUserRoleAudience, live_room_models.RoomUserStatusStart).Find(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}

	return rs, nil
}

func (impl *RoomUserRepoImpl) GetAnchors(ctx context.Context, appID string) ([]*live_entity.LiveRoomUser, error) {
	defer util.CheckPanic()
	var rs []*live_entity.LiveRoomUser
	err := db.Client.WithContext(ctx).Debug().Table(RoomUserTable).Where("app_id=? and user_role = ?  and status = ?", appID, live_room_models.RoomUserRoleHost, live_room_models.RoomUserStatusStart).Find(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}

	return rs, nil
}

func (impl *RoomUserRepoImpl) GetUsersByUserID(ctx context.Context, appID, userID string) ([]*live_entity.LiveRoomUser, error) {
	defer util.CheckPanic()
	var rs []*live_entity.LiveRoomUser
	err := db.Client.WithContext(ctx).Debug().Table(RoomUserTable).Where("app_id=? and user_id =  ? and status = ?", appID, userID, live_room_models.RoomUserStatusStart).Find(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}

	return rs, nil
}

func (impl *RoomUserRepoImpl) UpdateUsersByRoomID(ctx context.Context, appID, roomID string, ups map[string]interface{}) error {
	defer util.CheckPanic()
	err := db.Client.WithContext(ctx).Debug().Table(RoomUserTable).Where("app_id=? and room_id=  ?", appID, roomID).Updates(ups).Error
	if err != nil {
		return custom_error.InternalError(err)
	}

	return nil
}
