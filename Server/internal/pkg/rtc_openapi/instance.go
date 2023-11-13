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

package rtc_openapi

import (
	"context"

	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

var instanceMap map[string]*RTC

func GetInstance(ctx context.Context, appID string) *RTC {
	logs.CtxInfo(ctx, "get instance appID:%s", appID)
	logs.CtxInfo(ctx, "instanceMap:%s", instanceMap)
	if instanceMap == nil {
		instanceMap = make(map[string]*RTC, 10)
	}
	instance, ok := instanceMap[appID]
	logs.CtxInfo(ctx, "instance:%s,%s", instance, ok)
	if ok {
		return instance
	} else {
		userInfoService := login_service.GetAppInfoService()
		userInfo, _ := userInfoService.ReadAppInfoByAppId(ctx, appID)
		logs.CtxInfo(ctx, "userinfo:%s", userInfo)
		instance = NewInstance()
		instance.SetAccessKey(userInfo.AccessKey)
		instance.SetSecretKey(userInfo.SecretAccessKey)
		instanceMap[appID] = instance
	}
	logs.CtxInfo(ctx, "instance:%s", instance)
	return instance
}
