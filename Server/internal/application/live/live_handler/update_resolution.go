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
	"encoding/json"

	"github.com/gin-gonic/gin/binding"

	"github.com/gin-gonic/gin"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type updateResolutionReq struct {
	AppID  string `json:"app_id" binding:"required"`
	RoomID string `json:"room_id" binding:"required"`
	UserID string `json:"user_id" binding:"required"`
	Width  int    `json:"width"`
	Height int    `json:"height"`
}

type updateResolutionResp struct {
}

func UpdateResolution(ctx *gin.Context) (resp interface{}, err error) {
	var p updateResolutionReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	roomUserRepo := live_facade.GetRoomUserRepo()
	user, err := roomUserRepo.GetActiveUser(ctx, p.AppID, p.RoomID, p.UserID)
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
		return nil, err
	}

	return &updateResolutionResp{}, nil

}
