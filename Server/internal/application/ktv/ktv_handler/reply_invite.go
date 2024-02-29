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
	"context"
	"encoding/json"

	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type replyInviteReq struct {
	RoomID     string `json:"room_id"`
	UserID     string `json:"user_id"`
	Reply      int    `json:"reply"`
	LoginToken string `json:"login_token"`
}

type replyInviteResp struct {
}

func (eh *EventHandler) ReplyInvite(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveCreateLive param:%+v", param)
	var p replyInviteReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	if p.RoomID == "" || p.UserID == "" {
		logs.CtxError(ctx, "input error, param:%v", p)
		return nil, custom_error.ErrInput
	}

	roomFactory := ktv_service.GetRoomFactory()
	room, err := roomFactory.GetRoomByRoomID(ctx, param.AppID, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		return nil, err
	}
	if room == nil {
		logs.CtxError(ctx, "room is not exist")
		return nil, custom_error.ErrRoomNotExist
	}

	interactService := ktv_service.GetInteractService()

	err = interactService.AudienceReply(ctx, param.AppID, p.RoomID, room.GetHostUserID(), p.UserID, p.Reply)
	if err != nil {
		logs.CtxError(ctx, "invite failed,error:%s", err)
		return nil, err
	}

	return nil, nil
}
