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
	"math/rand"
	"strconv"
	"sync"

	"github.com/byteplus-sdk/byteplus-sdk-golang/service/vod/models/request"
	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_entity"
	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_models"
	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_repo"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"github.com/byteplus/VideoOneServer/internal/pkg/vod_openapi"
)

func GetFeedStreamWithPlayAuthToken(ctx context.Context, req vod_models.GetFeedStreamRequest) ([]*vod_models.VideoDetail, error) {
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
	return getVideoPlayAuthToken(ctx, req, videos)
}

func getVideoPlayAuthToken(ctx context.Context, req vod_models.GetFeedStreamRequest, videos []*vod_entity.VideoInfo) ([]*vod_models.VideoDetail, error) {
	defer util.CheckPanic()
	var resp []*vod_models.VideoDetail
	instance := vod_openapi.GetInstance()
	tokenExpires := 86400
	lock := sync.Mutex{}
	var wg sync.WaitGroup
	for _, video := range videos {
		if video == nil {
			continue
		}
		wg.Add(1)
		go func(vv *vod_entity.VideoInfo) {
			defer wg.Done()
			defer util.CheckPanic()
			playInfoReq := req
			playInfoReq.Vid = vv.Vid
			rowReq := ComposeVodGetPlayInfoRequest(playInfoReq)
			rowToken, err := instance.GetPlayAuthToken(rowReq, tokenExpires)
			if err != nil {
				logs.CtxError(ctx, "GetPlayAuthToken Failed! *Error is: %v", err)
				return
			}
			info, _, err := instance.GetPlayInfo(rowReq)
			if err != nil {
				logs.CtxError(ctx, "GetPlayInfo Failed! *Error is: %v", err)
				return
			}
			if info.Result == nil {
				logs.CtxWarn(ctx, "empty result")
				return
			}
			var subtitleToken string
			if len(info.Result.SubtitleInfoList) != 0 {
				subtitleToken, err = instance.GetSubtitleAuthToken(&request.VodGetSubtitleInfoListRequest{Vid: vv.Vid}, tokenExpires)
				if err != nil {
					logs.CtxError(ctx, "GetSubtitleAuthToken Failed! *Error is: %v", err)
				}
			}
			mediaInfo, _, err := instance.GetMediaInfos(&request.VodGetMediaInfosRequest{Vids: vv.Vid})
			if err != nil {
				logs.CtxError(ctx, "GetMediaInfos Failed! *Error is: %v", err)
				return
			}
			if mediaInfo.GetResponseMetadata().Error != nil {
				logs.CtxError(ctx, "GetMediaInfos Failed! *Error is: %v", err)
				return
			}
			if len(mediaInfo.GetResult().MediaInfoList) == 0 {
				logs.CtxWarn(ctx, "result is nil")
				return
			}
			name := getRandomName()
			lock.Lock()
			defer lock.Unlock()
			resp = append(resp, &vod_models.VideoDetail{
				Vid:               vv.Vid,
				Caption:           mediaInfo.Result.MediaInfoList[0].BasicInfo.Title,
				Duration:          float64(info.Result.Duration),
				CoverUrl:          info.Result.PosterUrl,
				PlayAuthToken:     rowToken,
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
		}(video)
	}
	wg.Wait()
	return resp, nil
}

var commonName = []string{"Oliver", "Jack", "Harry", "Jacob", "Charlie", "Thomas", "George", "Oscar", "James", "William", "Abigail", "Madison"}

func getRandomName() string {
	index := rand.Int63n(int64(len(commonName)))
	return commonName[index]
}

func ComposeVodGetPlayInfoRequest(req vod_models.GetFeedStreamRequest) *request.VodGetPlayInfoRequest {
	if len(req.Vid) == 0 {
		return nil
	}
	resp := &request.VodGetPlayInfoRequest{
		Vid:      req.Vid,
		FileType: req.FileType,
		Ssl:      "1",
	}
	if req.Format > 0 {
		formatStr := ""
		switch req.Format {
		case vod_models.Format_MP4Format:
			formatStr = "mp4"
		case vod_models.Format_M4AFormat:
			formatStr = "m4a"
		case vod_models.Format_M3U8Format:
			formatStr = "m3u8"
		case vod_models.Format_GIFFormat:
			formatStr = "gif"
		case vod_models.Format_DASHFormat:
			formatStr = "dash"
		case vod_models.Format_OGGFormat:
			formatStr = "ogg"
		case vod_models.Format_FMP4Format:
			formatStr = "fmp4"
		case vod_models.Format_HLSFormat:
			formatStr = "hls"
		case vod_models.Format_MP3Format:
			formatStr = "mp3"
		}
		if len(formatStr) > 0 {
			resp.Format = formatStr
		}
	}

	codecStr := ""
	switch req.Codec {
	case vod_models.Codec_H264Codec:
	case vod_models.Codec_MByteVC1Codec:
		codecStr = "h265"
	case vod_models.Codec_OByteVC1Codec:
		codecStr = "h265"
	case vod_models.Codec_OPUSCodec:
		codecStr = "opus"
	case vod_models.Codec_AACCodec:
		codecStr = "aac"
	case vod_models.Codec_MP3Codec:
		codecStr = "mp3"
	case vod_models.Codec_ByteVC1Codec:
		codecStr = "bytevc1"
	case vod_models.Codec_H266Codec:
		codecStr = "h266"
	}
	if len(codecStr) > 0 {
		resp.Codec = codecStr
	}

	definitionStr := ""
	switch req.Definition {
	case vod_models.Definition_V360PDefinition:
		definitionStr = "360p"
	case vod_models.Definition_V480PDefinition:
		definitionStr = "480p"
	case vod_models.Definition_V720PDefinition:
		definitionStr = "720p"
	case vod_models.Definition_V1080PDefinition:
		definitionStr = "1080p"
	case vod_models.Definition_V240PDefinition:
		definitionStr = "240p"
	case vod_models.Definition_V540PDefinition:
		definitionStr = "540p"
	case vod_models.Definition_V420PDefinition:
		definitionStr = "420p"
	case vod_models.Definition_V2KDefinition:
		definitionStr = "2k"
	case vod_models.Definition_V4KDefinition:
		definitionStr = "4k"
	}
	if len(definitionStr) > 0 {
		resp.Definition = definitionStr
	}
	if req.NeedThumbs {
		resp.NeedThumbs = "1"
	}
	if len(req.LogoType) > 0 {
		resp.LogoType = req.LogoType
	}
	if req.NeedBarrageMask {
		resp.NeedBarrageMask = "1"
	}
	if int32(req.CdnType) > 0 {
		resp.CdnType = strconv.Itoa(int(req.CdnType))
	}
	if len(req.UnionInfo) > 0 {
		resp.UnionInfo = req.UnionInfo
		if len(req.DrmExpireTimestamp) > 0 {
			resp.DrmExpireTimestamp = req.DrmExpireTimestamp
		}
	}
	if len(req.HdrDefinition) > 0 {
		resp.HDRDefinition = req.HdrDefinition
	}
	if len(req.Quality) > 0 {
		resp.Quality = req.Quality
	}
	return resp
}
