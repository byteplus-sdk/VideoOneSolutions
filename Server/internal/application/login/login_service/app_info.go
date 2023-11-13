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

package login_service

import (
	"context"

	"github.com/byteplus/VideoOneServer/internal/application/login/login_entity"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_repository/login_facade"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type AppInfoService struct {
	appInfoRepo login_facade.AppInfoRepositoryInterface
}

var appInfoService *AppInfoService

func GetAppInfoService() *AppInfoService {
	if appInfoService == nil {
		appInfoService = &AppInfoService{
			appInfoRepo: login_facade.GetAppInfoRepository(),
		}
	}
	return appInfoService
}

func (s *AppInfoService) WriteAppInfo(ctx context.Context, appInfo *login_entity.AppInfo) error {
	err := s.appInfoRepo.Save(ctx, appInfo)
	if err != nil {
		return err
	}
	return nil
}

func (s *AppInfoService) ReadAppInfoByAppId(ctx context.Context, appID string) (*login_entity.AppInfo, error) {
	appInfo, err := s.appInfoRepo.GetAppInfoByAppID(ctx, appID)
	if err != nil {
		logs.CtxError(ctx, "get app info error,err:%s", err)
		return nil, custom_error.ErrGetAppInfo
	}

	return appInfo, nil
}
