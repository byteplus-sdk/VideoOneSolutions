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

	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"

	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type updateResolutionReq struct {
	RoomID     string `json:"room_id"`
	UserID     string `json:"user_id"`
	Width      int    `json:"width"`
	Height     int    `json:"height"`
	LoginToken string `json:"login_token"`
}

type updateResolutionResp struct {
}

func (eh *EventHandler) UpdateResolution(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveUpdateResolution param:%+v", param)
	var p updateResolutionReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	roomUserRepo := live_facade.GetRoomUserRepo()
	user, err := roomUserRepo.GetActiveUser(ctx, param.AppID, p.RoomID, p.UserID)
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return nil, err
	}

	extra := &live_entity.LiveRoomUserExtra{
		Width:  p.Width,
		Height: p.Height,
	}
	extraString, _ := json.Marshal(extra)
	user.Extra = string(extraString)

	err = roomUserRepo.Save(ctx, user)
	if err != nil {
		logs.CtxError(ctx, "save user failed,error:%s", err)
		return nil, err
	}

	return nil, nil

}
