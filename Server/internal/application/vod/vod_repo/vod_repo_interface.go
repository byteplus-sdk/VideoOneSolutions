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

	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_entity"
)

var vodRepo VodRepoInterface

func GetVodRepo() VodRepoInterface {
	if vodRepo == nil {
		vodRepo = &VodRepoImpl{}
	}
	return vodRepo
}

type VodRepoInterface interface {
	GetVideoInfoListFromTMVideoInfoByUser(ctx context.Context, vid string, offset, pageSize, videoType int,
		antiScreenshotAndRecord, supportSmartSubtitle *bool) ([]*vod_entity.VideoInfo, error)
	GetCommentsByVid(ctx context.Context, vid string) ([]*vod_entity.VideoComments, error)
	GetSimilarVideoInfoList(ctx context.Context, similarVid string, offset, pageSize, videoType int) ([]*vod_entity.VideoInfo, error)
}
