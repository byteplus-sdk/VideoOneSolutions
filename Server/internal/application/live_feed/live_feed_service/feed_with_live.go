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
	"math/rand"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_cdn_service"
	"github.com/byteplus/VideoOneServer/internal/application/live_feed/live_feed_model"
	"github.com/byteplus/VideoOneServer/internal/application/live_feed/live_feed_repo"
	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_models"
	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/token"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
)

const (
	FeedLiveNum = 2
)

func GetFeedStreamWithLive(ctx context.Context, offset, pageSize int, userID string) ([]*live_feed_model.GetFeedStreamWithLiveResp, error) {
	result := make([]*live_feed_model.GetFeedStreamWithLiveResp, 0)

	// 1. Select regular vod medias
	vodList, err := vod_service.GetFeedStreamWithPlayAuthToken(ctx, vod_models.GetFeedStreamRequest{
		Offset:   offset,
		PageSize: pageSize,
	})
	if err != nil {
		logs.CtxError(ctx, "GetFeedStreamWithPlayAuthToken err: %v", err)
		return nil, err
	}

	// 2. Select live streams
	liveList, err := live_feed_repo.GetLiveFeedRepo().GetLiveFeed(ctx, offset/2, FeedLiveNum, "")
	if err != nil {
		logs.CtxError(ctx, "GetLiveFeed err: %v", err)
		return nil, err
	}

	//3. Randomly merge a vod and live stream
	remove := false
	for _, v := range vodList {
		remove = true
		result = append(result, &live_feed_model.GetFeedStreamWithLiveResp{
			VideoType:  live_feed_model.VideoTypeVod,
			UserStatus: live_feed_model.UserStatusOffline,
			VideoInfo: &live_feed_model.VideoDetail{
				Vid:               v.Vid,
				Caption:           v.Caption,
				Duration:          v.Duration,
				CoverUrl:          v.CoverUrl,
				PlayAuthToken:     v.PlayAuthToken,
				SubtitleAuthToken: v.SubtitleAuthToken,
				PlayTimes:         v.PlayTimes,
				Subtitle:          v.Subtitle,
				CreateTime:        v.CreateTime,
				Name:              v.Name,
				Uid:               v.Uid,
				Like:              v.Like,
				Comment:           v.Comment,
				Height:            v.Height,
				Width:             v.Width,
			},
		})
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
		room := &live_feed_model.RoomDetail{
			LiveFeed:          *l,
			RtsToken:          rtcToken,
			HostUserID:        util.Hashcode(l.HostName),
			StreamPullUrlList: live_cdn_service.GenPullUrl(l.StreamID),
		}

		if remove {
			// Replace the first VOD video
			result[0].UserStatus = live_feed_model.UserStatusLiving
			result[0].RoomInfo = room
			remove = false
		} else {
			result = append(result, &live_feed_model.GetFeedStreamWithLiveResp{
				VideoType:  live_feed_model.VideoTypeLive,
				UserStatus: live_feed_model.UserStatusLiving,
				RoomInfo:   room,
			})
		}

	}

	//4. Crop according to the limit and return data
	rand.Shuffle(len(result), func(i, j int) {
		result[i], result[j] = result[j], result[i]
	})
	if len(result) > pageSize {
		result = result[:pageSize]
	}
	return result, nil
}
