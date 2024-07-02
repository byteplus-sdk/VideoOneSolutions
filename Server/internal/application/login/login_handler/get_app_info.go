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

package login_handler

import (
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/login/login_entity"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type getAppInfoReq struct {
	AppId           string `json:"app_id"`
	AppKey          string `json:"app_key"`
	AccessKey       string `json:"access_key"`
	SecretAccessKey string `json:"secret_access_key"`
	VodSpace        string `json:"vod_space"`
	ScenesName      string `json:"scenes_name"`
	LivePullDomain  string `json:"live_pull_domain"`
	LivePushDomain  string `json:"live_push_domain"`
	LivePushKey     string `json:"live_push_key"`
	LiveAppName     string `json:"live_app_name"`
}

type getAppInfoResp struct {
	AppID string `json:"app_id"`
	BID   string `json:"bid"`
}

func GetAppInfo(ctx *gin.Context) (resp interface{}, err error) {
	var p getAppInfoReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		logs.CtxError(ctx, "param error,err:"+err.Error())
		return nil, err
	}

	appInfo := &login_entity.AppInfo{
		AppId:           p.AppId,
		AppKey:          p.AppKey,
		AccessKey:       p.AccessKey,
		SecretAccessKey: p.SecretAccessKey,
		VodSpace:        p.VodSpace,
		LivePushDomain:  p.LivePushDomain,
		LivePullDomain:  p.LivePullDomain,
		LiveStreamKey:   p.LivePushKey,
		LiveAppName:     p.LiveAppName,
		CreateTime:      time.Now(),
	}
	appInfoService := login_service.GetAppInfoService()
	err = appInfoService.WriteAppInfo(ctx, appInfo)
	if err != nil {
		return nil, err
	}
	if p.ScenesName != "" {
		bid, ok := public.BidMap[p.ScenesName]
		if ok != true || bid == "" {
			return nil, custom_error.ErrGetBID
		}

		resp = &getAppInfoResp{
			BID:   bid,
			AppID: appInfo.AppId,
		}
		return resp, nil
	}
	return nil, nil
}
