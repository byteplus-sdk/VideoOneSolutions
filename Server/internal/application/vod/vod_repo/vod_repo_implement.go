/*
 * Copyright 2023 CloudWeGo Authors
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
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_entity"
	"github.com/byteplus/VideoOneServer/internal/pkg/db"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

const (
	VideoInfo = "video_info"
)

type VodRepoImpl struct{}

func (v *VodRepoImpl) GetVideoInfoListFromTMVideoInfoByUser(ctx context.Context, vid string, offset, pageSize, videoType int) ([]*vod_entity.VideoInfo, error) {
	var resp []*vod_entity.VideoInfo
	query := db.Client.WithContext(ctx).Debug().Table(VideoInfo).Where("video_type = ?", videoType)
	if vid != "" {
		query = query.Where("vid = ?", vid)
	}
	err := query.Order("id asc").Offset(offset).Limit(pageSize).Find(&resp).Error
	if err != nil {
		logs.CtxError(ctx, "DB Op Failed! *Error is: %v", err)
		return nil, err
	}
	//disrupt_order
	rand.Seed(time.Now().UnixNano())
	rand.Shuffle(len(resp), func(i, j int) {
		resp[i], resp[j] = resp[j], resp[i]
	})
	return resp, nil
}
