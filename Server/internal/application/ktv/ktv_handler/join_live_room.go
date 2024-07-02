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
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
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
	RoomInfo      *ktv_service.Room             `json:"room_info"`
	UserInfo      *ktv_service.User             `json:"user_info"`
	HostInfo      *ktv_service.User             `json:"host_info"`
	SeatList      map[int]*ktv_service.SeatInfo `json:"seat_list"`
	RtcToken      string                        `json:"rtc_token"`
	AudienceCount int                           `json:"audience_count"`
	CurSong       *ktv_service.Song             `json:"cur_song"`
}

func JoinLiveRoom(ctx *gin.Context) (resp interface{}, err error) {
	var p joinLiveRoomReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		logs.CtxError(ctx, "param error,err:"+err.Error())
		return nil, err
	}

	roomFactory := ktv_service.GetRoomFactory()
	userFactory := ktv_service.GetUserFactory()
	seatFactory := ktv_service.GetSeatFactory()

	roomService := ktv_service.GetRoomService()
	err = roomService.JoinRoom(ctx, p.AppID, p.RoomID, p.UserID, p.UserName, "")
	if err != nil {
		logs.CtxError(ctx, "join room failed,error:%s", err)
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

	seats, _ := seatFactory.GetSeatsByRoomID(ctx, p.RoomID)
	seatList := make(map[int]*ktv_service.SeatInfo)
	for _, seat := range seats {
		if seat.GetOwnerUserID() != "" {
			u, _ := userFactory.GetActiveUserByRoomIDUserID(ctx, p.AppID, seat.GetRoomID(), seat.GetOwnerUserID())
			seatList[seat.SeatID] = &ktv_service.SeatInfo{
				Status:    seat.Status,
				GuestInfo: u,
			}
		} else {
			seatList[seat.SeatID] = &ktv_service.SeatInfo{
				Status:    seat.Status,
				GuestInfo: nil,
			}
		}
	}

	userCountMap, err := roomFactory.GetRoomsAudienceCount(ctx, []string{room.GetRoomID()})
	if err != nil {
		logs.CtxError(ctx, "get user count failed,error:"+err.Error())
	}
	userCount := userCountMap[room.GetRoomID()]
	room.AudienceCount = userCount
	songService := ktv_service.GetSongService()
	curSong, err := songService.GetCurSong(ctx, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get cur song failed,error:%s", err)
		return nil, err
	}
	appInfoService := login_service.GetAppInfoService()
	appInfo, _ := appInfoService.ReadAppInfoByAppId(ctx, p.AppID)

	resp = &joinLiveRoomResp{
		RoomInfo:      room,
		HostInfo:      host,
		UserInfo:      user,
		SeatList:      seatList,
		RtcToken:      room.GenerateToken(ctx, p.UserID, appInfo.AppId, appInfo.AppKey),
		AudienceCount: userCount,
		CurSong:       curSong,
	}

	return resp, nil
}
