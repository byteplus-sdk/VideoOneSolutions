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

	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_inform_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/inform"

	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type manageGuestMediaMediaReq struct {
	HostRoomID  string `json:"host_room_id"`
	HostUserID  string `json:"host_user_id"`
	GuestRoomID string `json:"guest_room_id"`
	GuestUserID string `json:"guest_user_id"`
	Mic         int    `json:"mic"`
	Camera      int    `json:"camera"`
	LoginToken  string `json:"login_token"`
}

type manageGuestMediaMediaResp struct {
}

func (eh *EventHandler) ManageGuestMedia(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveUpdateMediaStatus param:%+v", param)
	var p manageGuestMediaMediaReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	roomRepo := live_facade.GetRoomRepo()
	room, err := roomRepo.GetActiveRoom(ctx, param.AppID, p.HostRoomID)
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
	informer := inform.GetInformService(param.AppID)
	informer.UnicastRoomUser(ctx, p.GuestRoomID, p.GuestUserID, live_inform_service.OnManageGuestMedia, informData)

	resp = &manageGuestMediaMediaResp{}
	return nil, nil

}
