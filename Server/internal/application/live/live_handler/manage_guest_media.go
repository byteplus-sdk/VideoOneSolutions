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
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/inform"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type manageGuestMediaMediaReq struct {
	AppID       string `json:"app_id" binding:"required"`
	HostRoomID  string `json:"host_room_id" binding:"required"`
	HostUserID  string `json:"host_user_id" binding:"required"`
	GuestRoomID string `json:"guest_room_id" binding:"required"`
	GuestUserID string `json:"guest_user_id" binding:"required"`
	Mic         int    `json:"mic"`
	Camera      int    `json:"camera"`
}

type manageGuestMediaMediaResp struct {
}

func ManageGuestMedia(ctx *gin.Context) (resp interface{}, err error) {
	var p manageGuestMediaMediaReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	roomRepo := live_facade.GetRoomRepo()
	room, err := roomRepo.GetActiveRoom(ctx, p.AppID, p.HostRoomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		return nil, custom_error.ErrRoomNotExist
	}
	if room.HostUserID != p.HostUserID {
		return nil, custom_error.ErrUserIsNotHost
	}

	informData := &live_inform_service.InformManageGuestMedia{
		GuestRoomID: p.GuestRoomID,
		GuestUserID: p.GuestUserID,
		Mic:         p.Mic,
		Camera:      p.Camera,
	}
	informer := inform.GetInformService(p.AppID)
	informer.UnicastRoomUser(ctx, p.GuestRoomID, p.GuestUserID, live_inform_service.OnManageGuestMedia, informData)

	return &manageGuestMediaMediaResp{}, nil

}
