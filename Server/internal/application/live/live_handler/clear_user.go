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
	"errors"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type clearUserReq struct {
	AppID  string `json:"app_id" binding:"required"`
	UserID string `json:"user_id" binding:"required"`
}

type clearUserResp struct {
}

func ClearUser(ctx *gin.Context) (resp interface{}, err error) {
	var p clearUserReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		logs.CtxError(ctx, "param error,err:"+err.Error())
		return nil, err
	}

	oldUsers, _ := live_facade.GetRoomUserRepo().GetUsersByUserID(ctx, p.AppID, p.UserID)
	for _, oldUser := range oldUsers {
		DisconnectLogic(ctx, p.AppID, oldUser.RoomID, oldUser.UserID)
		// force clean
		user, err := live_facade.GetRoomUserRepo().GetActiveUser(ctx, p.AppID, oldUser.RoomID, oldUser.UserID)
		if err != nil && !errors.Is(err, custom_error.ErrRecordNotFound) {
			logs.CtxInfo(ctx, "get error:%s", err)
			continue
		}
		if user != nil {
			user.Leave()
			live_facade.GetRoomUserRepo().Save(ctx, user)
		}
	}

	return nil, nil
}
