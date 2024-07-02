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

package live_implement

import (
	"context"
	"errors"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_linker_models"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/db"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

const (
	LinkerTable = "live_linker"
)

type LinkerRepoImpl struct{}

func (impl *LinkerRepoImpl) GetAudienceLinkerByRoomIDAndUserID(ctx context.Context, roomID, userID string) (*live_entity.LiveLinker, error) {
	var rs *live_entity.LiveLinker
	err := db.Client.WithContext(ctx).Debug().Table(LinkerTable).Where("from_room_id = ? and from_user_id=?  and linker_status != ?", roomID, userID, live_linker_models.LinkerStatusNotValid).First(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}
	return rs, nil
}

func (impl *LinkerRepoImpl) GetLinkersByRoomIDScene(ctx context.Context, roomID string, scene int) ([]*live_entity.LiveLinker, error) {
	var rs []*live_entity.LiveLinker
	err := db.Client.WithContext(ctx).Debug().Table(LinkerTable).Where("( from_room_id=? or to_room_id = ? ) and scene=?  and linker_status != ?", roomID, roomID, scene, live_linker_models.LinkerStatusNotValid).Find(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return make([]*live_entity.LiveLinker, 0), custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}
	return rs, nil
}

func (impl *LinkerRepoImpl) GetActiveLinkersByRoomIDScene(ctx context.Context, roomID string, scene int) ([]*live_entity.LiveLinker, error) {
	var rs []*live_entity.LiveLinker
	err := db.Client.WithContext(ctx).Debug().Table(LinkerTable).Where("( from_room_id=? or to_room_id = ? ) and scene=?  and linker_status = ?", roomID, roomID, scene, live_linker_models.LinkerStatusAudienceLinked).Find(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return make([]*live_entity.LiveLinker, 0), custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}
	return rs, nil
}

func (impl *LinkerRepoImpl) GetLinkedUsersByLinkerID(ctx context.Context, linkerID string) ([]*live_entity.LiveRoomUser, error) {
	var rs *live_entity.LiveLinker
	err := db.Client.WithContext(ctx).Debug().Table(LinkerTable).Where("linker_id = ? and linker_status != ?", linkerID, live_linker_models.LinkerStatusNotValid).First(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}
	var users []*live_entity.LiveRoomUser
	err = db.Client.WithContext(ctx).Debug().Table(RoomUserTable).Where("(user_id = ? and room_id = ?) or (user_id = ? and room_id = ?)",
		rs.FromUserID, rs.FromRoomID, rs.ToUserID, rs.ToRoomID).Find(&users).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}
	return users, nil
}

func (impl *LinkerRepoImpl) GetValidInvitee(ctx context.Context, linkerID, roomID, userID string) (*live_entity.LiveLinker, error) {
	var rs *live_entity.LiveLinker
	err := db.Client.WithContext(ctx).Debug().Table(LinkerTable).Where("linker_id = ? and linker_status != ?", linkerID, live_linker_models.LinkerStatusNotValid).First(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}
	return rs, nil
}

func (impl *LinkerRepoImpl) SaveLinker(ctx context.Context, linker *live_entity.LiveLinker) error {
	defer util.CheckPanic()
	err := db.Client.WithContext(ctx).Debug().Table(LinkerTable).
		Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "linker_id"}},
			UpdateAll: true,
		}).Create(&linker).Error
	if err != nil {
		return custom_error.InternalError(err)
	}
	return nil
}

func (impl *LinkerRepoImpl) GetLinker(ctx context.Context, linkerID string) (*live_entity.LiveLinker, error) {
	var rs *live_entity.LiveLinker
	err := db.Client.WithContext(ctx).Debug().Table(LinkerTable).Where("linker_id = ? and linker_status != ?", linkerID, live_linker_models.LinkerStatusNotValid).First(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, custom_error.ErrRecordNotFound
		}
		return nil, custom_error.InternalError(err)
	}
	return rs, nil
}

func (impl *LinkerRepoImpl) UpdateLinker(ctx context.Context, linkerID string, ups map[string]interface{}) error {
	defer util.CheckPanic()
	err := db.Client.WithContext(ctx).Debug().Table(LinkerTable).Where("linker_id = ?", linkerID).Updates(ups).Error
	if err != nil {
		return custom_error.InternalError(err)
	}
	return nil
}
