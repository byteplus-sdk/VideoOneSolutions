/*
 * Copyright 2023 CloudWeGo Authors
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
	"context"
	"encoding/json"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_linker_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_api_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type anchorLinkmicInviteReq struct {
	InviterRoomID string `json:"inviter_room_id"`
	InviterUserID string `json:"inviter_user_id"`
	InviteeRoomID string `json:"invitee_room_id"`
	InviteeUserID string `json:"invitee_user_id"`
	Extra         string `json:"extra"`
	LoginToken    string `json:"login_token"`
}

type anchorLinkmicInviteResp struct {
	LinkerID string `json:"linker_id"`
}

func (eh *EventHandler) AnchorLinkmicInvite(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveAnchorLinkmicInvite param:%+v", param)
	var p anchorLinkmicInviteReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	//check param
	if p.InviterRoomID == "" || p.InviterUserID == "" || p.InviteeRoomID == "" || p.InviteeUserID == "" {
		logs.CtxError(ctx, "input error, param:%v", p)
		return nil, custom_error.ErrInput
	}

	inviteResp, err := live_linkmic_api_service.AnchorInvite(ctx, param.AppID, &live_linker_models.ApiAnchorInviteReq{
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
