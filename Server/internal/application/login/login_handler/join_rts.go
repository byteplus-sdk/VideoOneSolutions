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

package login_handler

import (
	"context"
	"encoding/json"

	"github.com/byteplus/VideoOneServer/internal/application/login/login_entity"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/token"
)

type joinRtsReq struct {
	AppId           string `json:"app_id"`
	AppKey          string `json:"app_key"`
	AccessKey       string `json:"access_key"`
	SecretAccessKey string `json:"secret_access_key"`
	VodSpace        string `json:"vod_space"`
	LoginToken      string `json:"login_token"`
	ScenesName      string `json:"scenes_name"`
	LivePullDomain  string `json:"live_pull_domain"`
	LivePushDomain  string `json:"live_push_domain"`
	LivePushKey     string `json:"live_push_key"`
	LiveAppName     string `json:"live_app_name"`
}

type joinRtsResp struct {
	AppID           string `json:"app_id"`
	RtmToken        string `json:"rtm_token"`
	ServerUrl       string `json:"server_url"`
	ServerSignature string `json:"server_signature"`
	BID             string `json:"bid"`
	Status          string `json:"status"`
}

func (h *EventHandler) JoinRts(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	var p joinRtsReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		return nil, custom_error.ErrInput
	}

	if p.AppId == "" || p.AppKey == "" || p.AccessKey == "" || p.SecretAccessKey == "" {
		return nil, custom_error.ErrInput
	}

	if p.LiveAppName == "" || p.LivePushKey == "" || p.LivePushDomain == "" || p.LivePullDomain == "" {
		return nil, custom_error.ErrInput
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
	}
	appInfoService := login_service.GetAppInfoService()
	err = appInfoService.WriteAppInfo(ctx, appInfo)
	if err != nil {
		return nil, err
	}
	if p.ScenesName != "" && p.LoginToken != "" {
		userService := login_service.GetUserService()

		err = userService.CheckLoginToken(ctx, p.LoginToken)
		if err != nil {
			logs.CtxWarn(ctx, "login token expiry")
			return nil, err
		}
		bid, ok := public.BidMap[p.ScenesName]
		if ok != true || bid == "" {
			return nil, custom_error.ErrGetBID
		}

		userID := userService.GetUserID(ctx, p.LoginToken)
		rtcToken, err := token.GenerateToken(&token.GenerateParam{
			AppID:        appInfo.AppId,
			AppKey:       appInfo.AppKey,
			RoomID:       "",
			UserID:       userID,
			ExpireAt:     7 * 24 * 3600,
			CanPublish:   true,
			CanSubscribe: true,
		})
		if err != nil {
			logs.CtxError(ctx, "generate token failed,error:%s", err)
			return nil, custom_error.InternalError(err)
		}
		resp = &joinRtsResp{
			Status:          "success",
			BID:             bid,
			AppID:           appInfo.AppId,
			RtmToken:        rtcToken,
			ServerUrl:       config.Configs().ServerUrl,
			ServerSignature: p.LoginToken,
		}
		return resp, nil
	}
	return nil, nil
}
