/*
 * Copyright 2023 CloudWeGo Authors
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

package vod_service

import (
	"context"
	"fmt"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_models"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/vod_openapi"
)

func GenUploadToken(ctx context.Context, appID, expireTime string) (*vod_models.STS2, error) {
	m, err := time.ParseDuration(fmt.Sprintf("%sm", expireTime))
	if err != nil {
		logs.CtxError(ctx, "time parse error %v", err)
		return nil, err
	}

	appInfoService := login_service.GetAppInfoService()
	appInfo, err := appInfoService.ReadAppInfoByAppId(ctx, appID)
	instance := vod_openapi.GetInstance(ctx, appID)
	ret2, _ := instance.GetUploadAuthWithExpiredTime(m)
	return &vod_models.STS2{
		AccessKeyID:     ret2.AccessKeyID,
		SecretAccessKey: ret2.SecretAccessKey,
		SessionToken:    ret2.SessionToken,
		ExpiredTime:     ret2.ExpiredTime,
		CurrentTime:     ret2.CurrentTime,
		SpaceName:       appInfo.VodSpace,
	}, nil
}
