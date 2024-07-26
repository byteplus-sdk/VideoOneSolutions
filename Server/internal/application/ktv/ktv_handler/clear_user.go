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

package ktv_handler

import (
	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type clearUserReq struct {
	AppID  string `json:"app_id" binding:"required"`
	UserID string `json:"user_id" binding:"required"`
}

type clearUserResp struct {
}

func ClearUser(ctx *gin.Context) (resp interface{}, err error) {
	var p clearUserReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	userFactory := ktv_service.GetUserFactory()
	user, err := userFactory.GetActiveUserByUserID(ctx, p.AppID, p.UserID)
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return nil, custom_error.ErrInput
	}

	if user == nil {
		return nil, nil
	}

	roomService := ktv_service.GetRoomService()
	if user.IsHost() {
		err = roomService.FinishLive(ctx, p.AppID, user.GetRoomID(), ktv_service.FinishTypeNormal)
		if err != nil {
			logs.CtxError(ctx, "finish live failed,error:%s", err)
			return nil, err
		}
	} else if user.IsAudience() {
		err = roomService.LeaveRoom(ctx, p.AppID, user.GetRoomID(), user.GetUserID())
		if err != nil {
			logs.CtxError(ctx, "leave room failed,error:%s", err)
			return nil, err
		}
	}

	user, _ = userFactory.GetActiveUserByUserID(ctx, p.AppID, p.UserID)
	if user != nil {
		user.LeaveRoom()
		userFactory.Save(ctx, user)
	}

	return &clearUserResp{}, nil
}
