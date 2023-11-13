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

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_linker_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_api_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type audienceLinkmicPermitReq struct {
	LinkerID       string `json:"linker_id"`
	HostRoomID     string `json:"host_room_id"`
	HostUserID     string `json:"host_user_id"`
	AudienceRoomID string `json:"audience_room_id"`
	AudienceUserID string `json:"audience_user_id"`
	PermitType     int    `json:"permit_type"`
	LoginToken     string `json:"login_token"`
}

type audienceLinkmicPermitResp struct {
	LinkerID    string                     `json:"linker_id"`
	RtcRoomID   string                     `json:"rtc_room_id"`
	RtcToken    string                     `json:"rtc_token"`
	RtcUserList []*live_return_models.User `json:"rtc_user_list"`
}

func (eh *EventHandler) AudienceLinkmicPermit(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveAudienceLinkmicPermit param:%+v", param)
	var p audienceLinkmicPermitReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	//check param
	if p.HostRoomID == "" || p.HostUserID == "" || p.AudienceRoomID == "" || p.AudienceUserID == "" {
		logs.CtxError(ctx, "input error, param:%v", p)
		return nil, custom_error.ErrInput
	}

	roomRepo := live_facade.GetRoomRepo()
	room, err := roomRepo.GetActiveRoom(ctx, param.AppID, p.HostRoomID)
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

	permitResp, err := live_linkmic_api_service.AudiencePermit(ctx, param.AppID, &live_linker_models.ApiAudiencePermitReq{
		LinkerID:       p.LinkerID,
		HostRoomID:     p.HostRoomID,
		HostUserID:     p.HostUserID,
		AudienceRoomID: p.AudienceRoomID,
		AudienceUserID: p.AudienceUserID,
		Permit:         p.PermitType,
	})
	if err != nil {
		logs.CtxError(ctx, "permit failed,error:%s", err)
		return nil, err
	}

	resp = &audienceLinkmicPermitResp{
		LinkerID:    permitResp.LinkerID,
		RtcRoomID:   permitResp.RtcRoomID,
		RtcToken:    permitResp.RtcToken,
		RtcUserList: permitResp.LinkedUserList,
	}

	return resp, nil

}
