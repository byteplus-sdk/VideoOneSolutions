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
	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type requestSongReq struct {
	AppID        string  `json:"app_id" binding:"required"`
	UserID       string  `json:"user_id" binding:"required"`
	RoomID       string  `json:"room_id" binding:"required"`
	SongID       string  `json:"song_id" binding:"required"`
	SongName     string  `json:"song_name" binding:"required"`
	SongDuration float64 `json:"song_duration"`
	CoverUrl     string  `json:"cover_url"`
}

type requestSongResp struct {
}

func RequestSong(ctx *gin.Context) (resp interface{}, err error) {
	var p requestSongReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	userFactory := ktv_service.GetUserFactory()

	user, err := userFactory.GetActiveUserByRoomIDUserID(ctx, p.AppID, p.RoomID, p.UserID)
	if err != nil || user == nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return nil, custom_error.ErrUserIsInactive
	}

	if !(user.IsHost() || user.IsInteract()) {
		logs.CtxError(ctx, "user role not match")
		return nil, custom_error.ErrRequestSongUserRoleNotMatch
	}

	songService := ktv_service.GetSongService()
	err = songService.RequestSong(ctx, p.AppID, p.RoomID, p.UserID, p.SongID, p.SongName, p.CoverUrl, p.SongDuration)
	if err != nil {
		return nil, err
	}

	return &requestSongResp{}, nil

}
