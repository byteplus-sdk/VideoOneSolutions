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
	"errors"

	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type inviteInteractReq struct {
	AppID          string `json:"app_id" binding:"required"`
	RoomID         string `json:"room_id" binding:"required"`
	UserID         string `json:"user_id" binding:"required"`
	AudienceUserID string `json:"audience_user_id" binding:"required"`
	SeatID         int    `json:"seat_id"`
}

type inviteInteractResp struct {
}

func InviteInteract(ctx *gin.Context) (resp interface{}, err error) {
	var p inviteInteractReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	if p.SeatID < 0 {
		p.SeatID = 1
	}

	roomFactory := ktv_service.GetRoomFactory()
	room, err := roomFactory.GetRoomByRoomID(ctx, p.AppID, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		return nil, custom_error.ErrRoomNotExist
	}
	if room == nil {
		return nil, custom_error.InternalError(errors.New("room is empty"))
	}
	if room.GetHostUserID() != p.UserID {
		logs.CtxError(ctx, "user is not host of room")
		return nil, custom_error.ErrUserIsNotOwner
	}

	interactService := ktv_service.GetInteractService()

	err = interactService.Invite(ctx, p.AppID, p.RoomID, p.UserID, p.AudienceUserID, p.SeatID)
	if err != nil {
		logs.CtxError(ctx, "invite failed,error:%s", err)
		return nil, err
	}

	return &inviteInteractResp{}, nil
}
