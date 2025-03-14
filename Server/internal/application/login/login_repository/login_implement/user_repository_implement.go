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

package login_implement

import (
	"context"
	"errors"
	"time"

	"gorm.io/gorm"

	"github.com/byteplus/VideoOneServer/internal/application/login/login_entity"
	"github.com/byteplus/VideoOneServer/internal/pkg/db"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"gorm.io/gorm/clause"
)

const UserProfileTable = "user_profile"

type UserRepositoryImpl struct {
}

func (impl *UserRepositoryImpl) Save(ctx context.Context, user *login_entity.UserProfile) error {
	defer util.CheckPanic()

	user.UpdatedAt = time.Now()
	err := db.Client.WithContext(ctx).Debug().Table(UserProfileTable).
		Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "user_id"}},
			UpdateAll: true,
		}).Create(&user).Error
	return err
}

func (impl *UserRepositoryImpl) GetUser(ctx context.Context, userID string) (*login_entity.UserProfile, error) {
	defer util.CheckPanic()

	var rs *login_entity.UserProfile
	err := db.Client.WithContext(ctx).Debug().Table(UserProfileTable).Where("user_id = ?", userID).Order("id desc").First(&rs).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return rs, nil
}
