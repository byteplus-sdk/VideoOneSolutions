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

package vod_repo

import (
	"context"
	"math/rand"

	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_entity"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/db"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
)

const (
	VideoInfo     = "video_info"
	VideoComments = "video_comments"
)

type VodRepoImpl struct{}

func (v *VodRepoImpl) GetVideoInfoListFromTMVideoInfoByUser(ctx context.Context, vid string, offset, pageSize, videoType int,
	antiScreenshotAndRecord, supportSmartSubtitle *bool) ([]*vod_entity.VideoInfo, error) {
	var ignoreVideoType = false
	var resp []*vod_entity.VideoInfo
	query := db.Client.WithContext(ctx).Debug().Table(VideoInfo)
	if antiScreenshotAndRecord != nil {
		query = query.Where("anti_screenshot_and_record = ?", util.Bool2Int(*antiScreenshotAndRecord))
		ignoreVideoType = true
	}
	if supportSmartSubtitle != nil {
		query = query.Where("support_smart_subtitle = ?", util.Bool2Int(*supportSmartSubtitle))
		ignoreVideoType = true
	}
	if !ignoreVideoType {
		query = query.Where("video_type = ?", videoType)
	}
	if vid != "" {
		query = query.Where("vid = ?", vid)
	}
	err := query.Order("id asc").Offset(offset).Limit(pageSize).Find(&resp).Error
	if err != nil {
		logs.CtxError(ctx, "DB Op Failed! *Error is: %v", err)
		return nil, err
	}
	//disrupt_order
	rand.Shuffle(len(resp), func(i, j int) {
		resp[i], resp[j] = resp[j], resp[i]
	})
	return resp, nil
}

func (v *VodRepoImpl) GetCommentsByVid(ctx context.Context, vid string) ([]*vod_entity.VideoComments, error) {
	var resp []*vod_entity.VideoComments
	query := db.Client.WithContext(ctx).Debug().Table(VideoComments).Where("vid = ''")

	if vid != "" {
		query = query.Or("vid = ?", vid)
	}
	err := query.Order("id asc").Find(&resp).Error
	if err != nil {
		logs.CtxError(ctx, "DB Op Failed! *Error is: %v", err)
		return nil, err
	}
	//disrupt_order
	rand.Shuffle(len(resp), func(i, j int) {
		resp[i], resp[j] = resp[j], resp[i]
	})
	if len(resp) > public.VideoCommentNum {
		resp = resp[:public.VideoCommentNum]
	}
	return resp, nil
}

func (v *VodRepoImpl) GetSimilarVideoInfoList(ctx context.Context, similarVid string, offset, pageSize, videoType int) ([]*vod_entity.VideoInfo, error) {
	var resp []*vod_entity.VideoInfo
	query := db.Client.WithContext(ctx).Debug().Table(VideoInfo).Where("video_type = ?", videoType)

	if similarVid != "" {
		query = query.Where("vid != ?", similarVid)
	}
	err := query.Order("id asc").Offset(offset).Limit(pageSize).Find(&resp).Error
	if err != nil {
		logs.CtxError(ctx, "DB Op Failed! *Error is: %v", err)
		return nil, err
	}
	//disrupt_order
	rand.Shuffle(len(resp), func(i, j int) {
		resp[i], resp[j] = resp[j], resp[i]
	})
	return resp, nil
}
