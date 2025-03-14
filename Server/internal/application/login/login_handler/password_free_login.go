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

	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/models/response"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

const (
	PasswordFreeUserIDPrefix = "8848"
)

type passwordFreeLoginReq struct {
	UserName string `json:"user_name" binding:"required"`
}

type passwordFreeLoginResp struct {
	UserID     string `json:"user_id"`
	UserName   string `json:"user_name"`
	LoginToken string `json:"login_token"`
	CreatedAt  int64  `json:"created_at"`
}

func PasswordFreeLogin(ctx *gin.Context) {
	resp, err := PasswordFreeLoginLogic(ctx)
	ctx.String(200, response.NewCommonResponse(ctx, "", resp, err))
}

func PasswordFreeLoginLogic(ctx *gin.Context) (resp interface{}, err error) {
	var p passwordFreeLoginReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	userService := login_service.GetUserService()

	userID, err := userService.GenerateLocalUserIDWithRetry(ctx)
	if err != nil {
		logs.CtxError(ctx, "failed to generate userID, err: %v", err)
		return nil, err
	}
	userID = PasswordFreeUserIDPrefix + userID
	createdTime := time.Now().UnixNano()
	token := userService.GenerateLocalLoginToken(ctx, userID, createdTime)

	err = userService.Login(ctx, userID, token)
	if err != nil {
		logs.CtxError(ctx, "failed to login ,err: %v", err)
		return nil, err
	}
	err = userService.SetUserName(ctx, userID, p.UserName)
	if err != nil {
		logs.CtxError(ctx, "failed to set user name , err:%v", err)
		return nil, err
	}

	resp = &passwordFreeLoginResp{
		UserID:     userID,
		UserName:   p.UserName,
		LoginToken: token,
		CreatedAt:  createdTime,
	}

	return resp, nil
}
