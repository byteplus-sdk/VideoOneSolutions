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
	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type joinLiveRoomReq struct {
	AppID    string `json:"app_id" binding:"required"`
	UserID   string `json:"user_id" binding:"required"`
	UserName string `json:"user_name" binding:"required"`
	RoomID   string `json:"room_id" binding:"required"`
}

type joinLiveRoomResp struct {
	RoomInfo      *owc_service.Room             `json:"room_info"`
	UserInfo      *owc_service.User             `json:"user_info"`
	HostInfo      *owc_service.User             `json:"host_info"`
	SeatList      map[int]*owc_service.SeatInfo `json:"seat_list"`
	RtcToken      string                        `json:"rtc_token"`
	AudienceCount int                           `json:"audience_count"`
	CurSong       *owc_service.Song             `json:"cur_song"`
	LeaderUser    *owc_service.User             `json:"leader_user"`
	SuccentorUser *owc_service.User             `json:"succentor_user"`
	NextSong      *owc_service.Song             `json:"next_song"`
}

func JoinLiveRoom(ctx *gin.Context) (resp interface{}, err error) {
	var p joinLiveRoomReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	roomFactory := owc_service.GetRoomFactory()
	userFactory := owc_service.GetUserFactory()

	roomService := owc_service.GetRoomService()
	err = roomService.JoinRoom(ctx, p.AppID, p.RoomID, p.UserID, p.UserName, "")
	if err != nil {
		logs.CtxError(ctx, "join room failed,error: "+err.Error())
		return nil, err
	}

	room, err := roomFactory.GetRoomByRoomID(ctx, p.AppID, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		return nil, err
	}
	if room == nil {
		logs.CtxError(ctx, "room is not exist")
		return nil, custom_error.ErrRoomNotExist
	}
	host, _ := userFactory.GetUserByRoomIDUserID(ctx, p.AppID, room.GetRoomID(), room.GetHostUserID())
	user, _ := userFactory.GetActiveUserByRoomIDUserID(ctx, p.AppID, p.RoomID, p.UserID)

	userCountMap, err := roomFactory.GetRoomsAudienceCount(ctx, []string{room.GetRoomID()})
	if err != nil {
		logs.CtxError(ctx, "get user count failed,error"+err.Error())
	}
	userCount := userCountMap[room.GetRoomID()]
	room.AudienceCount = userCount
	songService := owc_service.GetSongService()
	curSong, err := songService.GetCurSong(ctx, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get cur song failed,error:%s", err)
		return nil, err
	}
	if curSong == nil {
		resp = &joinLiveRoomResp{
			RoomInfo:      room,
			HostInfo:      host,
			UserInfo:      user,
			RtcToken:      room.GenerateToken(ctx, p.UserID),
			AudienceCount: userCount,
			CurSong:       curSong,
			LeaderUser:    nil,
			SuccentorUser: nil,
			NextSong:      nil,
		}
		return resp, nil
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
		resp = &joinLiveRoomResp{
			RoomInfo:      room,
			HostInfo:      host,
			UserInfo:      user,
			RtcToken:      room.GenerateToken(ctx, p.UserID),
			AudienceCount: userCount,
			CurSong:       curSong,
			LeaderUser:    nil,
			SuccentorUser: nil,
			NextSong:      nil,
		}
		return resp, nil
	}
	resp = &joinLiveRoomResp{
		RoomInfo:      room,
		HostInfo:      host,
		UserInfo:      user,
		RtcToken:      room.GenerateToken(ctx, p.UserID),
		AudienceCount: userCount,
		CurSong:       curSong,
		LeaderUser:    leadUser,
		SuccentorUser: succentorUser,
		NextSong:      nextSong,
	}

	return resp, nil
}
