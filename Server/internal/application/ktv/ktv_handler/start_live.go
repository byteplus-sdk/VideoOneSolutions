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
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type startLiveReq struct {
	AppID               string `json:"app_id" binding:"required"`
	UserID              string `json:"user_id"`
	UserName            string `json:"user_name"`
	RoomName            string `json:"room_name"`
	BackgroundImageName string `json:"background_image_name"`
}

type startLiveResp struct {
	RoomInfo *ktv_service.Room `json:"room_info"`
	UserInfo *ktv_service.User `json:"user_info"`
	RtcToken string            `json:"rtc_token"`
}

func StartLive(ctx *gin.Context) (resp interface{}, err error) {
	var p startLiveReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	userFactory := ktv_service.GetUserFactory()
	userOld, err := userFactory.GetActiveUserByUserID(ctx, p.AppID, p.UserID)
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return nil, err
	}
	if userOld != nil {
		logs.CtxError(ctx, "user is active")
		return nil, custom_error.ErrUserInUse
	}

	roomService := ktv_service.GetRoomService()

	room, host, err := roomService.CreateRoom(ctx, p.AppID, p.RoomName, p.BackgroundImageName, p.UserID, p.UserName, "")
	if err != nil {
		logs.CtxError(ctx, "create room failed,error:%s", err)
		return nil, err
	}

	err = roomService.StartLive(ctx, room.GetAppID(), room.GetRoomID())
	if err != nil {
		logs.CtxError(ctx, "room start live failed,error:%s", err)
		return nil, err
	}

	resp = &startLiveResp{
		RoomInfo: room,
		UserInfo: host,
		RtcToken: room.GenerateToken(ctx, host.GetUserID(), config.Configs().RTCAppID, config.Configs().RTCAppKey),
	}

	return resp, nil
}
