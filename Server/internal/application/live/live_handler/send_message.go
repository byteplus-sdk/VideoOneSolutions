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

package live_handler

import (
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_inform_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_room_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/inform"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type sendMessageReq struct {
	RoomID  string `json:"room_id" binding:"required"`
	UserID  string `json:"user_id" binding:"required"`
	Message string `json:"message"`
	AppID   string `json:"app_id" binding:"required"`
}

type sendMessageResp struct {
}

func SendMessage(ctx *gin.Context) (resp interface{}, err error) {
	var p sendMessageReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		logs.CtxError(ctx, "param error,err:"+err.Error())
		return nil, err
	}

	userRepo := live_facade.GetRoomUserRepo()

	user, err := userRepo.GetActiveUser(ctx, p.AppID, p.RoomID, p.UserID)
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return nil, err
	}
	if user == nil {
		logs.CtxError(ctx, "user is not exist,error:%s", err)
		return nil, custom_error.ErrUserNotExist
	}
	roomService := live_room_service.GetRoomService()
	err = roomService.HandleMessage(ctx, p.AppID, p.RoomID, p.Message)
	if err != nil {
		logs.CtxInfo(ctx, "handle message error:%s", err)
		return nil, err
	}
	informer := inform.GetInformService(p.AppID)
	data := &live_inform_service.InformUserMsg{
		User:    user,
		Message: p.Message,
	}
	informer.BroadcastRoom(ctx, p.RoomID, live_inform_service.OnMessageSend, data)

	return nil, nil
}
