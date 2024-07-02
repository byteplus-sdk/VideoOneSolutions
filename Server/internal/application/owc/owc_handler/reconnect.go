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

type reconnectReq struct {
	AppID  string `json:"app_id" binding:"required"`
	RoomID string `json:"room_id" binding:"required"`
	UserID string `json:"user_id" binding:"required"`
}

type reconnectResp struct {
	RoomInfo      *owc_service.Room `json:"room_info"`
	UserInfo      *owc_service.User `json:"user_info"`
	HostInfo      *owc_service.User `json:"host_info"`
	RtcToken      string            `json:"rtc_token"`
	CurSong       *owc_service.Song `json:"cur_song"`
	NextSong      *owc_service.Song `json:"next_song"`
	AudienceCount int               `json:"audience_count"`
	LeaderUser    *owc_service.User `json:"leader_user"`
	SuccentorUser *owc_service.User `json:"succentor_user"`
}

func Reconnect(ctx *gin.Context) (resp interface{}, err error) {
	var p reconnectReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	roomFactory := owc_service.GetRoomFactory()
	userFactory := owc_service.GetUserFactory()

	room, err := roomFactory.GetRoomByRoomID(ctx, p.AppID, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		return nil, err
	}
	if room == nil {
		logs.CtxError(ctx, "room is not exist")
		return nil, custom_error.ErrRoomNotExist
	}

	userCountMap, err := roomFactory.GetRoomsAudienceCount(ctx, []string{room.GetRoomID()})
	if err != nil {
		logs.CtxError(ctx, "get user count failed,error:"+err.Error())
	}
	userCount := userCountMap[room.GetRoomID()]
	room.AudienceCount = userCount
	user, err := userFactory.GetActiveUserByUserID(ctx, p.AppID, p.UserID)
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return nil, custom_error.ErrUserIsInactive
	}
	if user == nil {
		return nil, custom_error.InternalError(errors.New("user not found"))
	}
	host, err := userFactory.GetActiveUserByRoomIDUserID(ctx, p.AppID, room.GetRoomID(), room.GetHostUserID())
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
	}

	songService := owc_service.GetSongService()
	curSong, err := songService.GetCurSong(ctx, user.GetRoomID())
	if err != nil {
		logs.CtxError(ctx, "get cur song failed,error:%s", err)
		return nil, err
	}
	if curSong == nil {
		return &reconnectResp{
			RoomInfo:      room,
			HostInfo:      host,
			UserInfo:      user,
			RtcToken:      room.GenerateToken(ctx, p.UserID),
			AudienceCount: userCount,
			CurSong:       curSong,
			LeaderUser:    nil,
			SuccentorUser: nil,
			NextSong:      nil,
		}, nil
	}
	owcSongSingUser, err := songService.GetSongSingUser(ctx, p.RoomID, curSong)
	if err != nil {
		logs.CtxError(ctx, "get song user info error:"+err.Error())
		return nil, err
	}

	leadUser, err := userFactory.GetActiveUserByUserID(ctx, p.AppID, owcSongSingUser.LeaderUser)
	if err != nil {
		logs.CtxError(ctx, "get song leadUser error")
		return nil, err
	}
	var succentorUser *owc_service.User
	if owcSongSingUser.SuccentorUser == "" {
		succentorUser = nil
	} else {
		succentorUser, err = userFactory.GetActiveUserByUserID(ctx, p.AppID, owcSongSingUser.SuccentorUser)
		if err != nil {
			logs.CtxError(ctx, "get song succentorUser error")
			return nil, err
		}
	}
	nextSong, err := songService.GetNextSong(ctx, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get next error:%s", err)
		return &reconnectResp{
			RoomInfo:      room,
			HostInfo:      host,
			UserInfo:      user,
			RtcToken:      room.GenerateToken(ctx, p.UserID),
			AudienceCount: userCount,
			CurSong:       curSong,
			LeaderUser:    nil,
			SuccentorUser: nil,
			NextSong:      nil,
		}, nil
	}

	user.Reconnect()
	err = userFactory.Save(ctx, user)
	if err != nil {
		return
	}

	return &reconnectResp{
		RoomInfo:      room,
		HostInfo:      host,
		UserInfo:      user,
		RtcToken:      room.GenerateToken(ctx, p.UserID),
		AudienceCount: userCount,
		CurSong:       curSong,
		LeaderUser:    leadUser,
		SuccentorUser: succentorUser,
		NextSong:      nextSong,
	}, nil
}
