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
	"encoding/json"
	"math/rand"

	"github.com/byteplus-sdk/byteplus-sdk-golang/service/vod/models/request"
	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_models"
	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_repo"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"github.com/byteplus/VideoOneServer/internal/pkg/vod_openapi"
)

func GetFeedStreamWithVideoModel(ctx context.Context, req *vod_models.GetFeedStreamRequest) ([]*vod_models.VideoDetail, error) {
	repo := vod_repo.GetVodRepo()
	videos, err := repo.GetVideoInfoListFromTMVideoInfoByUser(ctx, req.Vid, req.Offset, req.PageSize, req.VideoType,
		req.AntiScreenshotAndRecord, req.SupportSmartSubtitle)
	if err != nil {
		logs.CtxError(ctx, "err: %v", err)
		return nil, err
	}
	if len(videos) == 0 {
		return nil, nil
	}
	var resp []*vod_models.VideoDetail
	instance := vod_openapi.GetInstance(ctx, req.AppID)

	for _, video := range videos {
		if video == nil {
			continue
		}
		req.Vid = video.Vid
		rowReq := ComposeVodGetPlayInfoRequest(req)
		info, _, err := instance.GetPlayInfo(rowReq)
		if err != nil {
			logs.CtxError(ctx, "GetPlayInfo Failed! *Error is: %v", err)
			continue
		}
		if info.Result == nil {
			logs.CtxWarn(ctx, "result is nil")
		}

		videoModel, err := json.Marshal(info.Result)
		if err != nil {
			logs.CtxError(ctx, "Marshal VideoModel String Error:%v")
			continue
		}

		var subtitleToken string
		if len(info.Result.SubtitleInfoList) != 0 {
			tokenExpires := 86400
			subtitleToken, err = instance.GetSubtitleAuthToken(&request.VodGetSubtitleInfoListRequest{
				Vid: video.Vid,
			}, tokenExpires)
			if err != nil {
				logs.CtxError(ctx, "GetSubtitleAuthToken Failed! *Error is: %v", err)
			}
		}

		mediaInfo, _, err := instance.GetMediaInfos(&request.VodGetMediaInfosRequest{Vids: video.Vid})
		if err != nil {
			logs.CtxError(ctx, "GetMediaInfos Failed! *Error is: %v", err)
			continue
		}
		if mediaInfo.GetResponseMetadata().Error != nil {
			logs.CtxError(ctx, "GetMediaInfos Failed! *Error is: %v", err)
			continue
		}
		if len(mediaInfo.GetResult().MediaInfoList) == 0 {
			logs.CtxWarn(ctx, "result is nil")
			continue
		}
		name := getRandomName()
		resp = append(resp, &vod_models.VideoDetail{
			Vid:               video.Vid,
			Caption:           mediaInfo.Result.MediaInfoList[0].BasicInfo.Title,
			Duration:          float64(info.Result.Duration),
			CoverUrl:          info.Result.PosterUrl,
			VideoModel:        string(videoModel),
			SubtitleAuthToken: subtitleToken,
			CreateTime:        mediaInfo.Result.MediaInfoList[0].BasicInfo.CreateTime,
			Subtitle:          mediaInfo.Result.MediaInfoList[0].BasicInfo.Description,
			PlayTimes:         rand.Int63n(20) + 20,
			Like:              rand.Int63n(20) + 20,
			Comment:           public.VideoCommentNum,
			Height:            mediaInfo.Result.MediaInfoList[0].SourceInfo.Height,
			Width:             mediaInfo.Result.MediaInfoList[0].SourceInfo.Width,
			Name:              name,
			Uid:               util.Hashcode(name),
		})
	}
	return resp, nil
}
