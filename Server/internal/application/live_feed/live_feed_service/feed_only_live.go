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

package live_feed_service

import (
	"context"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_cdn_service"
	"github.com/byteplus/VideoOneServer/internal/application/live_feed/live_feed_model"
	"github.com/byteplus/VideoOneServer/internal/application/live_feed/live_feed_repo"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/token"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
)

func GetFeedStreamOnlyLive(ctx context.Context, offset, pageSize int, roomID, userID string) ([]*live_feed_model.RoomDetail, error) {
	result := make([]*live_feed_model.RoomDetail, 0)

	liveList, err := live_feed_repo.GetLiveFeedRepo().GetLiveFeed(ctx, offset, pageSize, roomID)
	if err != nil {
		logs.CtxError(ctx, "GetLiveFeed err: %v", err)
		return nil, err
	}

	for _, l := range liveList {
		rtcToken, err := token.GenerateToken(&token.GenerateParam{
			AppID:        config.Configs().RTCAppID,
			AppKey:       config.Configs().RTCAppKey,
			RoomID:       l.RoomID,
			UserID:       userID,
			ExpireAt:     7 * 24 * 3600,
			CanPublish:   true,
			CanSubscribe: true,
		})
		if err != nil {
			logs.CtxError(ctx, "generate token failed,error:%s", err)
			return nil, custom_error.InternalError(err)
		}

		result = append(result, &live_feed_model.RoomDetail{
			LiveFeed:          *l,
			HostUserID:        util.Hashcode(l.HostName),
			RtsToken:          rtcToken,
			StreamPullUrlList: live_cdn_service.GenPullUrl(l.StreamID),
		})
	}

	return result, nil
}
