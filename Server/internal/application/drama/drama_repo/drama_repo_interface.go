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

package drama_repo

import (
	"context"

	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_model"
)

var dramaFeedRepo DramaRepoInterface

func GetDramaRepo() DramaRepoInterface {
	if dramaFeedRepo == nil {
		dramaFeedRepo = &DramaRepoImpl{}
	}
	return dramaFeedRepo
}

type DramaRepoInterface interface {
	GetAllDrama(ctx context.Context) ([]drama_model.Drama, error)
	GetDramaInfo(ctx context.Context, dramaID string) (*drama_model.Drama, error)
	GetUserDramaUnlockVID(ctx context.Context, userID, dramaID string) ([]string, error)
	UpdateUserDramaUnlockVID(ctx context.Context, userID, dramaID string, VIDList []string) error
	GetCommentsByVid(ctx context.Context, vid string) ([]*drama_model.VideoComments, error)
}
