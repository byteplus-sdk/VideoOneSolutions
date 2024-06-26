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
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type getActiveLiveRoomListReq struct {
	LoginToken string `json:"login_token"`
}

type getActiveLiveRoomListResp struct {
	RoomList []*owc_service.Room `json:"room_list"`
}

func (eh *EventHandler) GetActiveLiveRoomList(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "owcGetActiveLiveRoomList param:%+v", param)
	var p getActiveLiveRoomListReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	roomFactory := owc_service.GetRoomFactory()
	roomList, err := roomFactory.GetActiveRoomListByAppID(ctx, param.AppID, true)
	if err != nil {
		logs.CtxError(ctx, "get active room list failed,error:%s", err)
		return nil, err
	}

	resp = &getActiveLiveRoomListResp{
		RoomList: roomList,
	}

	return resp, nil
}
