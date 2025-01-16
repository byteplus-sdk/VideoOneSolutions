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
	"errors"
	"math/rand"
	"strings"

	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_model"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/db"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"gorm.io/gorm"
)

type DramaRepoImpl struct{}

const (
	TableDrama         = "drama"
	TableUnlock        = "drama_unlock"
	TableVideoComments = "video_comments"
)

// GetAllDrama get all drama
func (d *DramaRepoImpl) GetAllDrama(ctx context.Context) ([]drama_model.Drama, error) {
	var resp []drama_model.Drama
	err := db.Client.WithContext(ctx).Debug().Table(TableDrama).Find(&resp).Error
	if err != nil {
		logs.CtxError(ctx, "DB Op Failed! *Error is: %v", err)
		return nil, err
	}
	rand.Shuffle(len(resp), func(i, j int) {
		resp[i], resp[j] = resp[j], resp[i]
	})
	return resp, nil
}

// GetDramaInfo get drama info by drama id
func (d *DramaRepoImpl) GetDramaInfo(ctx context.Context, dramaID string) (*drama_model.Drama, error) {
	var resp drama_model.Drama
	query := db.Client.WithContext(ctx).Debug().Table(TableDrama).Where("drama_id = ?", dramaID)

	err := query.First(&resp).Error
	if err != nil {
		logs.CtxError(ctx, "DB Op Failed! *Error is: %v", err)
		return nil, err
	}

	return &resp, nil
}

// GetUserDramaUnlockVID get user's unlocked vids by user id and drama id
func (d *DramaRepoImpl) GetUserDramaUnlockVID(ctx context.Context, userID, dramaID string) ([]string, error) {
	var unlock drama_model.DramaUnlock
	err := db.Client.WithContext(ctx).Debug().Table(TableUnlock).
		Where("user_id =? and drama_id =?", userID, dramaID).First(&unlock).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return []string{}, nil
		}
		logs.CtxError(ctx, "DB Op Failed! *Error is: %v", err)
		return nil, err
	}
	return strings.Split(unlock.VIDList, ","), nil
}

// UpdateUserDramaUnlockVID update user's unlocked vids by user id and drama id
func (d *DramaRepoImpl) UpdateUserDramaUnlockVID(ctx context.Context, userID, dramaID string, VIDList []string) error {
	vids := "," + strings.Join(VIDList, ",")
	result := db.Client.WithContext(ctx).Debug().Table(TableUnlock).
		Where("user_id =? and drama_id =?", userID, dramaID).
		Update("vid_list", gorm.Expr("concat(vid_list, ?)", vids))
	if result.Error != nil {
		logs.CtxError(ctx, "DB Op Failed! *Error is: %v", result.Error)
		return result.Error
	}

	// update 0 rows, insert a new record
	if result.RowsAffected == 0 {
		err := db.Client.WithContext(ctx).Debug().Table(TableUnlock).Create(&drama_model.DramaUnlock{
			UserID:  userID,
			DramaID: dramaID,
			VIDList: strings.Join(VIDList, ","),
		}).Error
		if err != nil {
			logs.CtxError(ctx, "DB Op Failed! *Error is: %v", err)
			return err
		}
	}
	return nil
}

// GetCommentsByVid get comments by vid
func (d *DramaRepoImpl) GetCommentsByVid(ctx context.Context, vid string) ([]*drama_model.VideoComments, error) {
	var resp []*drama_model.VideoComments
	query := db.Client.WithContext(ctx).Debug().Table(TableVideoComments).Where("vid = ''")

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
