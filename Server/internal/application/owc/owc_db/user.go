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

package owc_db

import (
	"context"
	"errors"

	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_entity"
	"github.com/byteplus/VideoOneServer/internal/pkg/db"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

const UserTable = "owc_user"

const (
	UserRoleHost     = 1
	UserRoleAudience = 2
)
const (
	UserNetStatusOnline       = 1
	UserNetStatusOffline      = 2
	UserNetStatusReconnecting = 3
)

type DbUserRepo struct{}

func (repo *DbUserRepo) Save(ctx context.Context, user *owc_entity.OwcUser) error {
	defer util.CheckPanic()
	err := db.Client.WithContext(ctx).Debug().Table(UserTable).
		Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "app_id"}, {Name: "room_id"}, {Name: "user_id"}},
			UpdateAll: true,
		}).Create(&user).Error
	return err
}

func (repo *DbUserRepo) UpdateUsersWithMapByRoomID(ctx context.Context, appID, roomID string, ups map[string]interface{}) error {
	defer util.CheckPanic()
	return db.Client.WithContext(ctx).Debug().Table(UserTable).Where("app_id=? and room_id = ?", appID, roomID).Updates(ups).Error
}

func (repo *DbUserRepo) GetActiveUserByRoomIDUserID(ctx context.Context, appID, roomID, userID string) (*owc_entity.OwcUser, error) {
	defer util.CheckPanic()
	var rs *owc_entity.OwcUser
	err := db.Client.WithContext(ctx).Debug().Table(UserTable).Where("app_id=? and room_id = ? and user_id = ? and net_status in ?", appID, roomID, userID, []int{UserNetStatusOnline, UserNetStatusReconnecting}).First(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return rs, nil
}

func (repo *DbUserRepo) GetUserByRoomIDUserID(ctx context.Context, appID, roomID, userID string) (*owc_entity.OwcUser, error) {
	defer util.CheckPanic()
	var rs *owc_entity.OwcUser
	err := db.Client.WithContext(ctx).Debug().Table(UserTable).Where("app_id =? and room_id = ? and user_id = ?", appID, roomID, userID).First(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return rs, nil
}

func (repo *DbUserRepo) GetActiveUserByUserID(ctx context.Context, appID, userID string) (*owc_entity.OwcUser, error) {
	defer util.CheckPanic()
	var rs *owc_entity.OwcUser
	err := db.Client.WithContext(ctx).Debug().Table(UserTable).Where("app_id=? and user_id = ? and net_status in ?", appID, userID, []int{UserNetStatusOnline, UserNetStatusReconnecting}).First(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return rs, nil
}

func (repo *DbUserRepo) GetActiveUsersByRoomID(ctx context.Context, appID, roomID string) ([]*owc_entity.OwcUser, error) {
	defer util.CheckPanic()
	var rs []*owc_entity.OwcUser
	err := db.Client.WithContext(ctx).Debug().Table(UserTable).Where("app_id=? and room_id = ? and net_status = ?", appID, roomID, UserNetStatusOnline).Order("create_time desc").Find(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return rs, nil
}
