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
	"github.com/byteplus/VideoOneServer/internal/pkg/inform"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type sendMessageReq struct {
	AppID   string `json:"app_id" binding:"required"`
	RoomID  string `json:"room_id" binding:"required"`
	UserID  string `json:"user_id" binding:"required"`
	Message string `json:"message"`
}

type sendMessageResp struct {
}

func SendMessage(ctx *gin.Context) (resp interface{}, err error) {
	var p sendMessageReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		logs.CtxError(ctx, "param error,err:"+err.Error())
		return nil, err
	}

	userFactory := ktv_service.GetUserFactory()

	user, err := userFactory.GetActiveUserByRoomIDUserID(ctx, p.AppID, p.RoomID, p.UserID)
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return nil, err
	}
	if user == nil {
		logs.CtxError(ctx, "user is not exist,error:%s", err)
		return nil, custom_error.ErrUserNotExist
	}

	informer := inform.GetInformService(p.AppID)
	data := &ktv_service.InformMessage{
		UserInfo: user,
		Message:  p.Message,
	}
	informer.BroadcastRoom(ctx, p.RoomID, ktv_service.OnMessage, data)

	return nil, nil
}
