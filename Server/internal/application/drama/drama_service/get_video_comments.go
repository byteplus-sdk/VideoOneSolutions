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
	"math/rand"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_model"
	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_repo"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
)

func GetVideoComments(ctx context.Context, vid string) ([]*drama_model.Comments, error) {
	videos, err := drama_repo.GetDramaRepo().GetCommentsByVid(ctx, vid)
	if err != nil {
		logs.CtxError(ctx, "err: %v", err)
		return nil, err
	}
	if len(videos) == 0 {
		return nil, nil
	}

	var res = make([]*drama_model.Comments, 0)
	for _, v := range videos {
		res = append(res, &drama_model.Comments{
			Content:    v.Content,
			Name:       v.Name,
			Uid:        util.Hashcode(v.Name),
			CreateTime: v.CreateTime.Format(time.RFC3339),
			Like:       rand.Int63n(100) + 800,
		})
	}
	return res, nil
}
