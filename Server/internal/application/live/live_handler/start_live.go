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

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_room_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type startLiveReq struct {
	RoomID     string `json:"room_id"`
	UserID     string `json:"user_id"`
	LoginToken string `json:"login_token"`
}

type startLiveResp struct {
	UserInfo *live_return_models.User `json:"user_info"`
}

func (eh *EventHandler) StartLive(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveStartLive param:%+v", param)
	var p startLiveReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	//check param
	if p.RoomID == "" || p.UserID == "" {
		logs.CtxError(ctx, "input error, param:%v", p)
		return nil, custom_error.ErrInput
	}

	roomService := live_room_service.GetRoomService()
	_, host, err := roomService.StartRoom(ctx, param.AppID, p.RoomID, p.UserID)
	if err != nil {
		logs.CtxError(ctx, "create room failed,error:%s", err)
		return nil, err
	}

	resp = startLiveResp{
		UserInfo: ConvertReturnUser(host),
	}

	return resp, nil

}
