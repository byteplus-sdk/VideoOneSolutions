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

package owc_handler

import (
	"context"
	"encoding/json"

	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/inform"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type sendMessageReq struct {
	RoomID     string `json:"room_id"`
	UserID     string `json:"user_id"`
	Message    string `json:"message"`
	LoginToken string `json:"login_token"`
}

type sendMessageResp struct {
}

func (eh *EventHandler) SendMessage(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveCreateLive param:%+v", param)
	var p sendMessageReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	userFactory := owc_service.GetUserFactory()

	user, err := userFactory.GetActiveUserByRoomIDUserID(ctx, param.AppID, p.RoomID, p.UserID)
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return nil, err
	}
	if user == nil {
		logs.CtxError(ctx, "user is not exist,error:%s", err)
		return nil, custom_error.ErrUserNotExist
	}

	informer := inform.GetInformService(param.AppID)
	data := &owc_service.InformMessage{
		UserInfo: user,
		Message:  p.Message,
	}
	informer.BroadcastRoom(ctx, p.RoomID, owc_service.OnMessage, data)

	return nil, nil
}
