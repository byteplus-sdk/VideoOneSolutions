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
	"errors"

	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type cutOffSongReq struct {
	AppID  string `json:"app_id" binding:"required"`
	UserID string `json:"user_id" binding:"required"`
	RoomID string `json:"room_id" binding:"required"`
}

type cutOffSongResp struct {
}

func CutOffSong(ctx *gin.Context) (resp interface{}, err error) {
	var p cutOffSongReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	userFactory := owc_service.GetUserFactory()
	songService := owc_service.GetSongService()

	curSong, err := songService.GetCurSong(ctx, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get cur song failed,error:%s", err)
		return nil, err
	}
	if curSong == nil {
		return nil, custom_error.InternalError(errors.New("song list is empty"))
	}

	user, err := userFactory.GetActiveUserByRoomIDUserID(ctx, p.AppID, p.RoomID, p.UserID)
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return nil, custom_error.ErrUserIsInactive
	}
	if user == nil {
		return nil, custom_error.InternalError(errors.New("user not found"))
	}

	if !(user.IsHost() || user.GetUserID() == curSong.OwnerUserID) {
		logs.CtxError(ctx, "user role not match")
		return nil, custom_error.ErrRequestSongUserRoleNotMatch
	}

	err = songService.CutOffSong(ctx, p.AppID, p.RoomID, p.UserID)
	if err != nil {
		return nil, err
	}

	return &cutOffSongResp{}, nil
}
