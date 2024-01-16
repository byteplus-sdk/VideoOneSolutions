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

package vod_service

import (
	"context"

	"github.com/byteplus-sdk/byteplus-sdk-golang/service/vod/models/request"
	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_entity"
	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_models"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/vod_openapi"
)

const (
	PlayModeLinear = "linear" // 播放一次
	PlayModeLoop   = "loop"   // 循环播放
)

func GetPlayListDetail(ctx context.Context) (*vod_models.PlayListDetail, error) {
	result := &vod_models.PlayListDetail{}
	appID := config.Configs().AppID
	instance := vod_openapi.GetInstance(ctx, appID)
	resp, _, err := instance.GetPlaylists(&request.VodGetPlaylistsRequest{
		Ids: config.Configs().VodPlayListID,
	})
	if err != nil {
		logs.CtxError(ctx, "GetPlayListDetail err: %s", err.Error())
		return nil, err
	}
	if resp.ResponseMetadata.Error != nil {
		logs.CtxError(ctx, "GetPlayListDetail err: %s", resp.ResponseMetadata.Error.Message)
		return nil, err
	}

	var videos []*vod_entity.VideoInfo
	for _, list := range resp.Result.Playlists {
		for _, v := range list.VideoInfos {
			videos = append(videos, &vod_entity.VideoInfo{Vid: v.Vid})
		}
	}

	videoList, err := getVideoPlayAuthToken(ctx, &vod_models.GetFeedStreamRequest{AppID: appID}, videos)
	if err != nil {
		logs.CtxError(ctx, "getVideoPlayAuthToken err: %s", err.Error())
		return nil, err
	}
	result.PlayMode = PlayModeLoop
	result.VideoList = videoList
	return result, nil
}
