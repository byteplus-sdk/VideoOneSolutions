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

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_room_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"

	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

func (eh *EventHandler) Disconnect(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveDisconnect param:%+v", param)
	//var p reconnectReq
	//if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
	//	logs.CtxWarn(ctx, "input format error, err: %v", err)
	//	return nil, custom_error.ErrInput
	//}
	if param.AppID == "" || param.RoomID == "" || param.UserID == "" {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	DisconnectLogic(ctx, param.AppID, param.RoomID, param.UserID)

	return nil, nil

}

func DisconnectLogic(ctx context.Context, appID, roomID, userID string) error {
	roomRepo := live_facade.GetRoomRepo()
	roomUserRepo := live_facade.GetRoomUserRepo()
	_, err := roomRepo.GetActiveRoom(ctx, appID, roomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,roomID:%s,error:%s", roomID, err)
		return err
	}

	user, err := roomUserRepo.GetActiveUser(ctx, appID, roomID, userID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,roomID:%s,error:%s", userID, err)
		return err
	}

	if user.UserRole == live_room_models.RoomUserRoleHost {
		FinishLiveLogic(ctx, appID, finishLiveReq{
			RoomID: roomID,
			UserID: userID,
		})

	}

	if user.UserRole == live_room_models.RoomUserRoleAudience {
		LeaveRoomLogic(ctx, appID, leaveLiveRoomReq{
			RoomID: roomID,
			UserID: userID,
		})
	}

	return nil
}
