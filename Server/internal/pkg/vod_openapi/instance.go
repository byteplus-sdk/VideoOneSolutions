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

package vod_openapi

import (
	"context"

	"github.com/byteplus-sdk/byteplus-sdk-golang/service/vod"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

var vodInstanceMap map[string]*vod.Vod

func GetInstance(ctx context.Context, appID string) *vod.Vod {
	logs.CtxInfo(ctx, "get instance appID:%s", appID)
	if vodInstanceMap == nil {
		vodInstanceMap = make(map[string]*vod.Vod, 10)
	}
	instance, ok := vodInstanceMap[appID]
	if ok {
		return instance
	} else {
		userInfoService := login_service.GetAppInfoService()
		userInfo, err := userInfoService.ReadAppInfoByAppId(ctx, appID)
		if err != nil {
			logs.CtxError(ctx, "get app info error:%s", err)
			return instance
		}
		instance = vod.NewInstance()
		instance.SetAccessKey(userInfo.AccessKey)
		instance.SetSecretKey(userInfo.SecretAccessKey)
		vodInstanceMap[appID] = instance
	}
	return instance
}
