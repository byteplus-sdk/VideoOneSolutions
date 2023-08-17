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

	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_api_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_room_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"

	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type leaveLiveRoomReq struct {
	RoomID     string `json:"room_id"`
	UserID     string `json:"user_id"`
	LoginToken string `json:"login_token"`
}

type leaveLiveRoomResp struct {
}

//api leave room
func (eh *EventHandler) LeaveLiveRoom(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveLeaveLiveRoom param:%+v", param)
	var p leaveLiveRoomReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	//check param
	if p.RoomID == "" || p.UserID == "" {
		logs.CtxError(ctx, "input error, param:%v", p)
		return nil, custom_error.ErrInput
	}

	return LeaveRoomLogic(ctx, param.AppID, p)

}

//logic
func LeaveRoomLogic(ctx context.Context, appID string, p leaveLiveRoomReq) (resp interface{}, err error) {
	err = live_linkmic_api_service.FinishAudienceLinkmic(ctx, appID, p.RoomID, p.UserID)
	if err != nil {
		logs.CtxError(ctx, "finish linkmic failed,error:%s", err)
		return nil, err
	}
	roomService := live_room_service.GetRoomService()
	err = roomService.LeaveRoom(ctx, appID, p.RoomID, p.UserID)
	if err != nil {
		logs.CtxError(ctx, "leave room failed,error:%s", err)
		return nil, err
	}

	resp = &leaveLiveRoomResp{}

	return resp, nil
}
