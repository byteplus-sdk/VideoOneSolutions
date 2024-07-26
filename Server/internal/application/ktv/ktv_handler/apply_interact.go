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

type applyInteractReq struct {
	AppID  string `json:"app_id" binding:"required"`
	RoomID string `json:"room_id" binding:"required"`
	UserID string `json:"user_id" binding:"required"`
	SeatID int    `json:"seat_id"`
}

type applyInteractResp struct {
	IsNeedApply bool `json:"is_need_apply"`
}

func ApplyInteract(ctx *gin.Context) (resp interface{}, err error) {
	var p applyInteractReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	roomFactory := ktv_service.GetRoomFactory()
	userFactory := ktv_service.GetUserFactory()

	room, err := roomFactory.GetRoomByRoomID(ctx, p.AppID, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		return nil, err
	}
	if room == nil {
		logs.CtxError(ctx, "room is not exist")
		return nil, custom_error.ErrRoomNotExist
	}

	interactService := ktv_service.GetInteractService()

	err = interactService.Apply(ctx, p.AppID, room.GetRoomID(), room.GetHostUserID(), p.UserID, p.SeatID)
	if err != nil {
		logs.CtxError(ctx, "invite failed,error:%s", err)
		return nil, err
	}

	if !room.IsNeedApply() {
		err = interactService.HostReply(ctx, p.AppID, room.GetRoomID(), room.GetHostUserID(), p.UserID, ktv_service.InteractReplyTypeAccept)
		if err != nil {
			logs.CtxError(ctx, "host reply failed,error:%s", err)
			return nil, err
		}
	} else {
		informer := inform.GetInformService(p.AppID)
		user, err := userFactory.GetUserByRoomIDUserID(ctx, p.AppID, p.RoomID, p.UserID)
		if err != nil {
			logs.CtxError(ctx, "get user failed,error:%s", err)
		}
		data := &ktv_service.InformApplyInteract{
			UserInfo: user,
			SeatID:   p.SeatID,
		}
		informer.UnicastRoomUser(ctx, room.GetRoomID(), room.GetHostUserID(), ktv_service.OnApplyInteract, data)
	}

	resp = &applyInteractResp{
		IsNeedApply: room.IsNeedApply(),
	}

	return resp, nil
}
