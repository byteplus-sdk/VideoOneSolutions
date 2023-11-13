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
	"context"
	"encoding/json"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_linker_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_api_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type anchorLinkmicReplyReq struct {
	LinkerID      string `json:"linker_id"`
	InviterRoomID string `json:"inviter_room_id"`
	InviterUserID string `json:"inviter_user_id"`
	InviteeRoomID string `json:"invitee_room_id"`
	InviteeUserID string `json:"invitee_user_id"`
	ReplyType     int    `json:"reply_type"`
	LoginToken    string `json:"login_token"`
}

type anchorLinkmicReplyResp struct {
	RtcRoomID   string                     `json:"rtc_room_id"`
	RtcToken    string                     `json:"rtc_token"`
	RtcUserList []*live_return_models.User `json:"rtc_user_list"`
	LinkedTime  time.Time                  `json:"linked_time"`
}

func (eh *EventHandler) AnchorLinkmicReply(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveAnchorLinkmicReply param:%+v", param)
	var p anchorLinkmicReplyReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	//check param
	if p.InviterRoomID == "" || p.InviterUserID == "" || p.InviteeRoomID == "" || p.InviteeUserID == "" || p.LinkerID == "" {
		logs.CtxError(ctx, "input error, param:%v", p)
		return nil, custom_error.ErrInput
	}

	replyResp, err := live_linkmic_api_service.AnchorReply(ctx, param.AppID, &live_linker_models.ApiAnchorReplyReq{
		LinkerID:      p.LinkerID,
		InviterRoomID: p.InviterRoomID,
		InviterUserID: p.InviterUserID,
		InviteeRoomID: p.InviteeRoomID,
		InviteeUserID: p.InviteeUserID,
		Reply:         p.ReplyType,
	})
	if err != nil {
		logs.CtxError(ctx, "invite failed,error:%s", err)
		return nil, err
	}

	resp = &anchorLinkmicReplyResp{
		RtcRoomID:   replyResp.RtcRoomID,
		RtcToken:    replyResp.RtcToken,
		RtcUserList: replyResp.RtcUserList,
		LinkedTime:  replyResp.LinkedTime,
	}
	return resp, nil

}
