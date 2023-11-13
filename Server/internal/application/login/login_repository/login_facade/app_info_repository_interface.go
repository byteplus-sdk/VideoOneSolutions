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

package login_facade

import (
	"context"

	"github.com/byteplus/VideoOneServer/internal/application/login/login_entity"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_repository/login_implement"
)

var appInfoRepository AppInfoRepositoryInterface

func GetAppInfoRepository() AppInfoRepositoryInterface {
	if appInfoRepository == nil {
		appInfoRepository = &login_implement.AppInfoRepositoryImpl{}
	}
	return appInfoRepository
}

type AppInfoRepositoryInterface interface {
	Save(ctx context.Context, appInfo *login_entity.AppInfo) error
	ExistAppInfo(ctx context.Context, appID string) (bool, error)
	GetAppInfoByAppID(ctx context.Context, appID string) (*login_entity.AppInfo, error)
}
