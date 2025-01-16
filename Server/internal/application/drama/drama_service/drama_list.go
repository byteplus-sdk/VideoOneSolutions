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
	"math/rand"
	"strings"

	"github.com/byteplus-sdk/byteplus-sdk-golang/service/vod/models/business"
	"github.com/byteplus-sdk/byteplus-sdk-golang/service/vod/models/request"
	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_model"
	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_repo"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"github.com/byteplus/VideoOneServer/internal/pkg/vod_openapi"
)

func GetDramaList(ctx context.Context, userID, dramaID string, playInfoType int) ([]*drama_model.VideoMetaInfo, error) {
	instance := vod_openapi.GetInstance()

	// 1. get drama	info and unlock info from db
	dramaInfo, err := drama_repo.GetDramaRepo().GetDramaInfo(ctx, dramaID)
	if err != nil {
		logs.CtxError(ctx, "GetDramaList err: %s", err.Error())
		return nil, err
	}

	unlockVIDs, err := drama_repo.GetDramaRepo().GetUserDramaUnlockVID(ctx, userID, dramaID)
	if err != nil {
		logs.CtxError(ctx, "GetUserDramaUnlockVID err: %s", err.Error())
		return nil, err
	}

	// 2. get drama play list
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

	// 3. build result: vid, order, vip, and poster_url
	var videos []*drama_model.VideoMetaInfo
	var allVID []string
	order := 0
	for _, list := range resp.Result.Playlists {
		for _, v := range list.VideoInfos {
			order++
			vip := true
			if order <= dramaInfo.FreeNumber || util.StringInSlice(v.Vid, unlockVIDs) {
				vip = false
			}

			videos = append(videos, &drama_model.VideoMetaInfo{
				Vid:      v.Vid,
				Order:    order,
				VIP:      vip,
				CoverUrl: v.PosterUrl,
				DramaID:  dramaID,
				Like:     rand.Int63n(20) + 20, //random
				Comment:  public.VideoCommentNum,
			})
			allVID = append(allVID, v.Vid)
		}
	}

	// 4. get video meta info by VID
	vidQueryList := createVIDSlice(allVID)
	var metaMap = make(map[string]*business.VodMediaInfo)
	for _, vidList := range vidQueryList {
		mediaInfo, _, err := instance.GetMediaInfos(&request.VodGetMediaInfosRequest{Vids: vidList})
		if err != nil {
			logs.CtxError(ctx, "GetMediaInfos Failed! *Error is: %v", err)
			return nil, err
		}
		if mediaInfo.GetResponseMetadata().Error != nil {
			logs.CtxError(ctx, "GetDramaList err: %s", mediaInfo.GetResponseMetadata().Error.Message)
			return nil, err
		}
		for _, v := range mediaInfo.GetResult().MediaInfoList {
			metaMap[v.BasicInfo.Vid] = v
		}
	}

	// fill video meta info
	for _, v := range videos {
		if _, exist := metaMap[v.Vid]; !exist {
			continue
		}
		name := getRandomName()
		v.Duration = metaMap[v.Vid].SourceInfo.Duration
		v.Caption = metaMap[v.Vid].BasicInfo.Title
		v.PlayTimes = rand.Int63n(1000000) + 100000 //random
		v.Height = metaMap[v.Vid].SourceInfo.Height
		v.Width = metaMap[v.Vid].SourceInfo.Width
		v.CreateTime = metaMap[v.Vid].BasicInfo.CreateTime
		v.Name = name
		v.Uid = util.Hashcode(name)
	}

	// 4. for non-vip video, get play_auth_token or video_model, and get subtitle token
	expireTime := 3600 * 24
	for _, v := range videos {
		if v.VIP {
			continue
		}
		// generate subtitle auth token, this method is running locally
		subtitleToken, err := instance.GetSubtitleAuthToken(&request.VodGetSubtitleInfoListRequest{Vid: v.Vid}, expireTime)
		if err != nil {
			logs.CtxError(ctx, "GetSubtitleAuthToken Failed! *Error is: %v", err)
		}
		v.SubtitleAuthToken = subtitleToken

		// get play_auth_token or video_model
		switch playInfoType {
		case drama_model.PlayInfoTypeByVideoModel:
			info, _, err := instance.GetPlayInfo(&request.VodGetPlayInfoRequest{Vid: v.Vid, Ssl: "1"})
			if err != nil {
				return nil, err
			}
			if info.Result == nil {
				return nil, errors.New("empty result")
			}
			videoModel, err := json.Marshal(info.Result)
			if err != nil {
				return nil, err
			}
			v.VideoModel = string(videoModel)
		default:
			token, err := instance.GetPlayAuthToken(&request.VodGetPlayInfoRequest{Vid: v.Vid}, expireTime)
			if err != nil {
				logs.CtxError(ctx, "GetPlayInfo Failed! *Error is: %v", err)
				return nil, err
			}
			v.PlayAuthToken = token
		}
	}
	return videos, nil
}

func createVIDSlice(vids []string) []string {
	size := 20
	var output []string
	for i := 0; i < len(vids); i += size {
		end := i + size
		if end > len(vids) {
			end = len(vids)
		}
		segment := vids[i:end]
		output = append(output, strings.Join(segment, ","))
	}
	return output
}
