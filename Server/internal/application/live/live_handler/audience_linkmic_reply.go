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
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_api_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type audienceLinkmicReplyReq struct {
	AppID     string `json:"app_id" binding:"required"`
	LinkerID  string `json:"linker_id" binding:"required"`
	RoomID    string `json:"room_id" binding:"required"`
	UserID    string `json:"user_id" binding:"required"`
	ReplyType int    `json:"reply_type"`
}

type audienceLinkmicReplyResp struct {
	RtcRoomID   string                     `json:"rtc_room_id"`
	RtcToken    string                     `json:"rtc_token"`
	RtcUserList []*live_return_models.User `json:"rtc_user_list"`
}

func AudienceLinkmicReply(ctx *gin.Context) (resp interface{}, err error) {
	var p audienceLinkmicReplyReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	roomRepo := live_facade.GetRoomRepo()
	room, err := roomRepo.GetActiveRoom(ctx, p.AppID, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		if custom_error.Equal(err, custom_error.ErrRecordNotFound) {
			return nil, custom_error.ErrRoomNotExist
		}
		return nil, err
	}

	replyResp, err := live_linkmic_api_service.AudienceReply(ctx, p.AppID, &live_linker_models.ApiAudienceReplyReq{
		HostRoomID:     room.RoomID,
		HostUserID:     room.HostUserID,
		AudienceRoomID: p.RoomID,
		AudienceUserID: p.UserID,
		Reply:          p.ReplyType,
	})
	if err != nil {
		logs.CtxError(ctx, "reply failed,error:%s", err)
		return nil, err
	}

	resp = &audienceLinkmicReplyResp{
		RtcRoomID:   replyResp.RtcRoomID,
		RtcToken:    replyResp.RtcToken,
		RtcUserList: replyResp.LinkedUserList,
	}

	return resp, nil

}
