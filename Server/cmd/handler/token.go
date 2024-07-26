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

package handler

import (
	"context"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/models/response"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/token"
	"github.com/gin-gonic/gin"
)

func HandleGetRTCJoinRoomToken(httpCtx *gin.Context) {
	p := &public.RTCJoinRoomTokenParam{}
	err := httpCtx.BindJSON(p)
	ctx := context.Background()
	if err != nil {
		httpCtx.String(200, response.NewCommonResponse(ctx, "", "", custom_error.ErrMissParam))
		return
	}

	userService := login_service.GetUserService()
	err = userService.CheckLoginToken(ctx, p.LoginToken)
	if err != nil {
		logs.CtxError(ctx, "login_token invalid")
		httpCtx.String(400, response.NewCommonResponse(ctx, "", "", err))
		return
	}

	if p.Expire == 0 {
		p.Expire = 24 * 60 * 60
	}
	expireAt := time.Unix(time.Now().Unix()+p.Expire, 0)
	rtcToken, err := token.GenerateToken(&token.GenerateParam{
		AppID:        p.AppID,
		AppKey:       p.AppKey,
		RoomID:       p.RoomID,
		UserID:       p.UserID,
		ExpireAt:     p.Expire,
		CanPublish:   p.Pub,
		CanSubscribe: true,
	})
	if err != nil {
		logs.CtxError(ctx, "generate token failed,error:%s", err)
		httpCtx.String(500, response.NewCommonResponse(ctx, "", "", err))
		return
	}

	res := map[string]interface{}{
		"Token":     rtcToken,
		"ExpiredAt": expireAt.Unix(),
	}
	httpCtx.String(200, response.NewCommonResponse(ctx, "", res, err))
}
