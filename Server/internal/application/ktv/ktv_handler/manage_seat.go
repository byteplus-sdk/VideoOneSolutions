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

type manageSeatReq struct {
	RoomID     string `json:"room_id"`
	UserID     string `json:"user_id"`
	SeatID     int    `json:"seat_id"`
	Type       int    `json:"type"`
	LoginToken string `json:"login_token"`
}

type manageSeatResp struct {
}

func (eh *EventHandler) ManageSeat(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveCreateLive param:%+v", param)
	var p manageSeatReq
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
	if err != nil || room == nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		return nil, custom_error.ErrRoomNotExist
	}
	if room.GetHostUserID() != p.UserID {
		logs.CtxError(ctx, "user is not host of room")
		return nil, custom_error.ErrUserIsNotOwner
	}

	interactService := ktv_service.GetInteractService()
	switch p.Type {
	case ktv_service.InteractManageTypeLockSeat:
		err = interactService.LockSeat(ctx, param.AppID, p.RoomID, p.SeatID)
	case ktv_service.InteractManageTypeUnlockSeat:
		err = interactService.UnlockSeat(ctx, param.AppID, p.RoomID, p.SeatID)
	case ktv_service.InteractManageTypeMute:
		err = interactService.Mute(ctx, param.AppID, p.RoomID, p.SeatID)

	case ktv_service.InteractManageTypeUnmute:
		err = interactService.Unmute(ctx, param.AppID, p.RoomID, p.SeatID)
	case ktv_service.InteractManageTypeKick:
		err = interactService.FinishInteract(ctx, param.AppID, p.RoomID, p.SeatID, ktv_service.InteractFinishTypeHost)
	}
	if err != nil {
		logs.CtxError(ctx, "manage failed,error:%s", err)
		return nil, err
	}

	return nil, nil
}
