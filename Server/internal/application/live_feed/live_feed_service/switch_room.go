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

	"github.com/byteplus/VideoOneServer/internal/application/live_feed/live_feed_model"
	"github.com/byteplus/VideoOneServer/internal/application/live_feed/live_feed_repo"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/inform"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

func SwitchRoom(ctx context.Context, oldRoomID, newRoomID, userID string) (map[string]int64, error) {
	userName, err := login_service.GetUserService().GetUserName(ctx, userID)
	if err != nil {
		logs.CtxError(ctx, "get user name error:"+err.Error())
		userName = "unknown"
	}

	appID := config.Configs().RTCAppID
	informer := inform.GetInformService(appID)
	count := int64(0)
	if oldRoomID != "" {
		count, err = live_feed_repo.GetLiveFeedRepo().AddRoomAudienceCount(ctx, oldRoomID, -1)
		if err != nil {
			logs.CtxError(ctx, "AddRoomAudienceCount err: %v", err)
			return nil, err
		}
		data := &live_feed_model.InformUserLeave{
			UserID:        userID,
			AudienceCount: count,
			UserName:      userName,
		}
		informer.BroadcastRoom(ctx, oldRoomID, live_feed_model.FeedLiveOnUserLeave, data)
	}

	if newRoomID != "" {
		count, err = live_feed_repo.GetLiveFeedRepo().AddRoomAudienceCount(ctx, newRoomID, 1)
		if err != nil {
			logs.CtxError(ctx, "AddRoomAudienceCount err: %v", err)
			return nil, err
		}
		data := &live_feed_model.InformUserJoin{
			UserID:        userID,
			AudienceCount: count,
			UserName:      userName,
		}
		informer.BroadcastRoom(ctx, newRoomID, live_feed_model.FeedLiveOnUserJoin, data)
	}

	return map[string]int64{"audience_count": count}, nil
}
