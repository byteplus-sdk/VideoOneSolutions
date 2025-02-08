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

package live_feed_repo

import (
	"context"
	"math/rand"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/live_feed/live_feed_model"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/db"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli"
)

type LiveFeedRepoImpl struct{}

const (
	TableLiveFeed = "live_feed"
)

func (l *LiveFeedRepoImpl) GetLiveFeed(ctx context.Context, offset, pageSize int, excludeRoomID string) ([]*live_feed_model.LiveFeed, error) {
	var resp []*live_feed_model.LiveFeed
	query := db.Client.WithContext(ctx).Debug().Table(TableLiveFeed)

	if excludeRoomID != "" {
		query = query.Where("room_id != ?", excludeRoomID)
	}
	err := query.Offset(offset).Limit(pageSize).Find(&resp).Error
	if err != nil {
		logs.CtxError(ctx, "DB Op Failed! *Error is: %v", err)
		return nil, err
	}

	rand.Shuffle(len(resp), func(i, j int) {
		resp[i], resp[j] = resp[j], resp[i]
	})
	for i := range resp {
		resp[i].RTCAppID = config.Configs().RTCAppID
	}

	return resp, nil
}

func (l *LiveFeedRepoImpl) AddRoomAudienceCount(ctx context.Context, roomID string, value int64) (int64, error) {
	count, err := redis_cli.Client.IncrBy(ctx, getRoomAudienceCountKey(roomID), value).Result()
	if err != nil {
		logs.CtxError(ctx, "AddRoomAudienceCount Error: "+err.Error())
		return 0, custom_error.InternalError(err)
	}
	redis_cli.Client.Expire(ctx, getRoomAudienceCountKey(roomID), 24*365*time.Hour)
	return count, nil
}

const (
	RoomAudienceCountPrefix = "videoone:live_feed:room_audience_count:"
)

func getRoomAudienceCountKey(roomID string) string {
	return RoomAudienceCountPrefix + ":" + roomID
}
