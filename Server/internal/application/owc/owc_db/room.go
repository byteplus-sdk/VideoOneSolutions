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

const RoomTable = "owc_room"

const (
	RoomStatusPrepare = 1
	RoomStatusStart   = 2
	RoomStatusFinish  = 3
)

type DbRoomRepo struct{}

func (repo *DbRoomRepo) Save(ctx context.Context, liveRoom *owc_entity.OwcRoom) error {
	defer util.CheckPanic()
	err := db.Client.WithContext(ctx).Debug().Table(RoomTable).
		Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "app_id"}, {Name: "room_id"}},
			UpdateAll: true,
		}).Create(&liveRoom).Error
	return err
}

func (repo *DbRoomRepo) GetRoomByRoomID(ctx context.Context, appID, roomID string) (*owc_entity.OwcRoom, error) {
	defer util.CheckPanic()
	var rs *owc_entity.OwcRoom
	err := db.Client.WithContext(ctx).Debug().Table(RoomTable).Where("app_id =? and room_id = ? and status <> ?", appID, roomID, RoomStatusFinish).First(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return rs, nil
}

func (repo *DbRoomRepo) GetActiveRooms(ctx context.Context, appID string) ([]*owc_entity.OwcRoom, error) {
	defer util.CheckPanic()
	var rs []*owc_entity.OwcRoom
	err := db.Client.WithContext(ctx).Debug().Table(RoomTable).Where("app_id=? and status = ?", appID, RoomStatusStart).Order("create_time desc").Limit(200).Find(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return rs, nil
}

func (repo *DbRoomRepo) GetAllActiveRooms(ctx context.Context) ([]*owc_entity.OwcRoom, error) {
	defer util.CheckPanic()
	var rs []*owc_entity.OwcRoom
	err := db.Client.WithContext(ctx).Debug().Table(RoomTable).Where("status = ?", RoomStatusStart).Order("create_time desc").Limit(200).Find(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return rs, nil
}
