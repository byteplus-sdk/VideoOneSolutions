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
	"math/rand"
	"sync"

	"github.com/byteplus-sdk/byteplus-sdk-golang/service/vod/models/request"
	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_model"
	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_repo"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"github.com/byteplus/VideoOneServer/internal/pkg/vod_openapi"
)

func GetDramaFeed(ctx context.Context, pageSize, playInfoType int) ([]*drama_model.GetDramaFeedResp, error) {
	result := make([]*drama_model.GetDramaFeedResp, 0)

	instance := vod_openapi.GetInstance()
	defer util.CheckPanic()

	// 1. get all drama from DB
	dramaList, err := drama_repo.GetDramaRepo().GetAllDrama(ctx)
	if err != nil {
		return nil, err
	}
	dramaMap := make(map[string]drama_model.Drama)
	for _, d := range dramaList {
		dramaMap[d.DramaID] = d
	}

	// 2. get all vids for all drama, and remove vids which is not free
	var dramaIDS string
	for _, d := range dramaList {
		dramaIDS += d.DramaID + ","
	}
	resp, _, err := instance.GetPlaylists(&request.VodGetPlaylistsRequest{Ids: dramaIDS})
	if err != nil {
		logs.CtxError(ctx, "GetPlaylists error,err:%s", err)
		return nil, err
	}
	if resp.ResponseMetadata.Error != nil {
		logs.CtxError(ctx, "GetPlaylists error,err:%s", resp.ResponseMetadata.Error)
		return nil, err
	}

	var VIDList []string
	var vidDramaMap = make(map[string]drama_model.Drama) // key: vid, value: drama info
	var vidOrderMap = make(map[string]int)               // key: vid, value: order
	for _, drama := range resp.Result.Playlists {
		if dramaInfo, exist := dramaMap[drama.Id]; exist {
			// remove vids which is not free
			for i := 0; i < dramaInfo.FreeNumber; i++ {
				VIDList = append(VIDList, drama.VideoInfos[i].Vid)
				vidDramaMap[drama.VideoInfos[i].Vid] = dramaInfo
				vidOrderMap[drama.VideoInfos[i].Vid] = i + 1 // order 从 1 开始
			}
		}
	}

	// 3. shuffle and pick 'pageSize' vids
	rand.Shuffle(len(VIDList), func(i, j int) {
		VIDList[i], VIDList[j] = VIDList[j], VIDList[i]
	})
	if len(VIDList) > pageSize {
		VIDList = VIDList[:pageSize]
	}

	// 4. get vid detail from VOD OpenAPI
	videoMetaList, err := getVideoMetaInfo(ctx, VIDList, playInfoType)
	if err != nil {
		logs.CtxError(ctx, "getVideoPlayInfo error,err:%s", err)
		return nil, err
	}
	for _, v := range videoMetaList {
		r := &drama_model.GetDramaFeedResp{
			VideoMeta: v,
		}
		if mp, exist := vidDramaMap[v.Vid]; exist {
			r.VideoMeta.DramaID = mp.DramaID
			r.VideoMeta.Order = vidOrderMap[v.Vid]
			r.DramaMeta.DramaID = mp.DramaID
			r.DramaMeta.DramaTitle = mp.Title
			r.DramaMeta.DramaCoverURL = mp.CoverUrl
			r.DramaMeta.DramaPlayTimes = rand.Int63n(100000) + 100000
			r.DramaMeta.DramaLength = mp.TotalNumber
			r.DramaMeta.DramaVideoOrientation = mp.VideoOrientation
		} else {
			logs.CtxError(ctx, "vid not found,vid:%s", v.Vid)
		}
		result = append(result, r)
	}

	return result, nil
}

func getVideoMetaInfo(ctx context.Context, vids []string, playInfoType int) ([]drama_model.VideoMetaInfo, error) {
	defer util.CheckPanic()
	var resp []drama_model.VideoMetaInfo
	instance := vod_openapi.GetInstance()

	tokenExpires := 86400 // default expires time: 86400s = 1 day
	lock := sync.Mutex{}
	var wg sync.WaitGroup
	for _, videoID := range vids {
		wg.Add(1)
		go func(vid string) {
			defer wg.Done()
			defer util.CheckPanic()
			var rowToken, videoModel string
			rowReq := &request.VodGetPlayInfoRequest{Vid: vid, Ssl: "1"}
			info, _, err := instance.GetPlayInfo(rowReq)
			if err != nil {
				logs.CtxError(ctx, "GetPlayInfo Failed! *Error is: %v", err)
				return
			}
			if info.Result == nil {
				logs.CtxError(ctx, "empty result")
				return
			}

			switch playInfoType {
			case drama_model.PlayInfoTypeByVideoModel:
				model, err := json.Marshal(info.Result)
				if err != nil {
					logs.CtxError(ctx, "Marshal Failed! *Error is: %v", err)
					return
				}
				videoModel = string(model)
			default:
				rowToken, err = instance.GetPlayAuthToken(rowReq, tokenExpires)
				if err != nil {
					logs.CtxError(ctx, "GetPlayAuthToken Failed! *Error is: %v", err)
					return
				}
			}

			mediaInfo, _, err := instance.GetMediaInfos(&request.VodGetMediaInfosRequest{Vids: vid})
			if err != nil {
				logs.CtxError(ctx, "GetMediaInfos Failed! *Error is: %v", err)
				return
			}
			if mediaInfo.GetResponseMetadata().Error != nil {
				logs.CtxError(ctx, "GetMediaInfos Failed! *Error is: %v", err)
				return
			}

			// generate subtitle auth token, this method is running locally
			subtitleToken, err := instance.GetSubtitleAuthToken(&request.VodGetSubtitleInfoListRequest{Vid: vid}, tokenExpires)
			if err != nil {
				logs.CtxError(ctx, "GetSubtitleAuthToken Failed! *Error is: %v", err)
			}

			name := getRandomName()
			lock.Lock()
			defer lock.Unlock()
			resp = append(resp, drama_model.VideoMetaInfo{
				Vid:               vid,
				Caption:           mediaInfo.Result.MediaInfoList[0].BasicInfo.Title,
				Duration:          info.Result.Duration,
				CoverUrl:          info.Result.PosterUrl,
				PlayAuthToken:     rowToken,
				SubtitleAuthToken: subtitleToken,
				VideoModel:        videoModel,
				CreateTime:        mediaInfo.Result.MediaInfoList[0].BasicInfo.CreateTime,
				Subtitle:          mediaInfo.Result.MediaInfoList[0].BasicInfo.Description,
				PlayTimes:         rand.Int63n(20) + 20, //random
				Like:              rand.Int63n(20) + 20, //random
				Comment:           public.VideoCommentNum,
				Height:            mediaInfo.Result.MediaInfoList[0].SourceInfo.Height,
				Width:             mediaInfo.Result.MediaInfoList[0].SourceInfo.Width,
				Name:              name,
				Uid:               util.Hashcode(name),
				DisplayType:       int(rand.Int63n(2)), //random
			})
		}(videoID)
	}
	wg.Wait()
	return resp, nil
}

var commonName = []string{"Oliver", "Jack", "Harry", "Jacob", "Charlie", "Thomas", "George", "Oscar", "James", "William", "Abigail", "Madison"}

func getRandomName() string {
	index := rand.Int63n(int64(len(commonName)))
	return commonName[index]
}
