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
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_api_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type anchorLinkmicInviteReq struct {
	AppID         string `json:"app_id" binding:"required"`
	InviterRoomID string `json:"inviter_room_id" binding:"required"`
	InviterUserID string `json:"inviter_user_id" binding:"required"`
	InviteeRoomID string `json:"invitee_room_id" binding:"required"`
	InviteeUserID string `json:"invitee_user_id" binding:"required"`
	Extra         string `json:"extra"`
}

type anchorLinkmicInviteResp struct {
	LinkerID string `json:"linker_id"`
}

func AnchorLinkmicInvite(ctx *gin.Context) (resp interface{}, err error) {
	var p anchorLinkmicInviteReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		logs.CtxError(ctx, "param error,err:"+err.Error())
		return nil, err
	}

	inviteResp, err := live_linkmic_api_service.AnchorInvite(ctx, p.AppID, &live_linker_models.ApiAnchorInviteReq{
		InviterRoomID: p.InviterRoomID,
		InviterUserID: p.InviterUserID,
		InviteeRoomID: p.InviteeRoomID,
		InviteeUserID: p.InviteeUserID,
		Extra:         p.Extra,
	})
	if err != nil {
		logs.CtxError(ctx, "invite failed,error:%s", err)
		return nil, err
	}

	resp = &anchorLinkmicInviteResp{
		LinkerID: inviteResp.LinkerID,
	}

	return resp, nil
}
