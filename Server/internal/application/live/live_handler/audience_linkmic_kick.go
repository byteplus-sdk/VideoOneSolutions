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
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_linker_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_api_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type audienceLinkmicKickReq struct {
	AppID          string `json:"app_id" binding:"required"`
	HostRoomID     string `json:"host_room_id" binding:"required"`
	HostUserID     string `json:"host_user_id" binding:"required"`
	AudienceRoomID string `json:"audience_room_id" binding:"required"`
	AudienceUserID string `json:"audience_user_id" binding:"required"`
}

type audienceLinkmicKickResp struct {
}

func AudienceLinkmicKick(ctx *gin.Context) (resp interface{}, err error) {
	var p audienceLinkmicKickReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		logs.CtxError(ctx, "param error,err:"+err.Error())
		return nil, err
	}

	roomRepo := live_facade.GetRoomRepo()
	room, err := roomRepo.GetActiveRoom(ctx, p.AppID, p.HostRoomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		if custom_error.Equal(err, custom_error.ErrRecordNotFound) {
			return nil, custom_error.ErrRoomNotExist
		}
		return nil, err
	}
	if room.HostUserID != p.HostUserID {
		return nil, custom_error.ErrUserIsNotHost
	}

	_, err = live_linkmic_api_service.AudienceKick(ctx, p.AppID, &live_linker_models.ApiAudienceKickReq{
		HostRoomID:     p.HostRoomID,
		HostUserID:     p.HostUserID,
		AudienceRoomID: p.AudienceRoomID,
		AudienceUserID: p.AudienceUserID,
	})
	if err != nil {
		logs.CtxError(ctx, "kick failed,error:%s", err)
		return nil, err
	}

	resp = &audienceLinkmicKickResp{}

	return resp, nil

}
