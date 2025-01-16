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

package drama_service

import (
	"context"
	"encoding/json"
	"errors"
	"sort"

	"github.com/byteplus-sdk/byteplus-sdk-golang/service/vod/models/request"
	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_model"
	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_repo"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/vod_openapi"
)

func GetDramaDetail(ctx context.Context, userID, dramaID string, VIDList []string, playInfoType int) ([]*drama_model.GetDramaDetailResp, error) {
	var result []*drama_model.GetDramaDetailResp
	instance := vod_openapi.GetInstance()
	vidOrderMap := make(map[string]int) // key: vid, value: order
	for _, vid := range VIDList {
		vidOrderMap[vid] = -1
	}

	// 1. get drama info though VOD OpenAPI
	resp, _, err := instance.GetPlaylists(&request.VodGetPlaylistsRequest{
		Ids: dramaID,
	})
	if err != nil {
		logs.CtxError(ctx, "GetDramaList err: %s", err.Error())
		return nil, err
	}
	if resp.ResponseMetadata.Error != nil {
		logs.CtxError(ctx, "GetDramaList err: %s", resp.ResponseMetadata.Error.Message)
		return nil, err
	}

	// 2. record vid order
	for index, video := range resp.Result.Playlists[0].VideoInfos {
		if _, exist := vidOrderMap[video.Vid]; exist {
			vidOrderMap[video.Vid] = index + 1 // vid order should start from 1
		}
	}

	// 3. get play auth token
	expireTime := 3600 * 24
	updateVIDs := make([]string, 0)
	for vid, index := range vidOrderMap {
		if index == -1 {
			continue
		}
		// generate subtitle auth token, this method is running locally
		subtitleToken, err := instance.GetSubtitleAuthToken(&request.VodGetSubtitleInfoListRequest{Vid: vid}, expireTime)
		if err != nil {
			logs.CtxError(ctx, "GetSubtitleAuthToken Failed! *Error is: %v", err)
		}

		var token, videoModel string
		switch playInfoType {
		case drama_model.PlayInfoTypeByVideoModel:
			info, _, err := instance.GetPlayInfo(&request.VodGetPlayInfoRequest{Vid: vid, Ssl: "1"})
			if err != nil {
				return nil, err
			}
			if info.Result == nil {
				return nil, errors.New("empty result")
			}
			model, err := json.Marshal(info.Result)
			if err != nil {
				return nil, err
			}
			videoModel = string(model)
		default:
			token, err = instance.GetPlayAuthToken(&request.VodGetPlayInfoRequest{Vid: vid}, expireTime)
			if err != nil {
				logs.CtxError(ctx, "GetPlayInfo err: %s", err.Error())
				return nil, err
			}
		}
		result = append(result, &drama_model.GetDramaDetailResp{
			VID:               vid,
			Order:             index,
			PlayAuthToken:     token,
			VideoModel:        videoModel,
			SubtitleAuthToken: subtitleToken,
		})
		updateVIDs = append(updateVIDs, vid)
	}

	// 4. sort by order
	sort.SliceStable(result, func(i, j int) bool {
		return result[i].Order < result[j].Order
	})

	// 4. update user drama unlock vid in DB
	err = drama_repo.GetDramaRepo().UpdateUserDramaUnlockVID(ctx, userID, dramaID, updateVIDs)
	if err != nil {
		logs.CtxError(ctx, "UpdateUserDramaUnlockVID err: %s", err.Error())
		return nil, err
	}
	return result, nil
}
