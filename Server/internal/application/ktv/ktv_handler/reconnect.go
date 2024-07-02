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
	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_redis"
	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_service"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type reconnectReq struct {
	AppID string `json:"app_id" binding:"required"`
}

type reconnectResp struct {
	RoomInfo *ktv_service.Room             `json:"room_info"`
	UserInfo *ktv_service.User             `json:"user_info"`
	HostInfo *ktv_service.User             `json:"host_info"`
	SeatList map[int]*ktv_service.SeatInfo `json:"seat_list"`
	RtcToken string                        `json:"rtc_token"`
	CurSong  *ktv_service.Song             `json:"cur_song"`
}

func Reconnect(ctx *gin.Context) (resp interface{}, err error) {
	var p reconnectReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		logs.CtxError(ctx, "param error,err:"+err.Error())
		return nil, err
	}

	roomFactory := ktv_service.GetRoomFactory()
	userFactory := ktv_service.GetUserFactory()
	seatFactory := ktv_service.GetSeatFactory()

	appInfoService := login_service.GetAppInfoService()
	appInfo, _ := appInfoService.ReadAppInfoByAppId(ctx, p.AppID)

	loginUserService := login_service.GetUserService()
	userID := loginUserService.GetUserID(ctx, ctx.GetHeader(public.HeaderLoginToken))

	user, err := userFactory.GetActiveUserByUserID(ctx, p.AppID, userID)
	if err != nil || user == nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return nil, custom_error.ErrUserIsInactive
	}
	user.Reconnect("")
	err = userFactory.Save(ctx, user)
	if err != nil {
		logs.CtxError(ctx, "save user failed,error:%s")
		return nil, err
	}

	room, err := roomFactory.GetRoomByRoomID(ctx, p.AppID, user.GetRoomID())
	if err != nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		return nil, err
	}
	if room == nil {
		logs.CtxError(ctx, "room is not exist")
		return nil, custom_error.ErrRoomNotExist
	}
	audienceCount, err := ktv_redis.GetRoomAudienceCount(ctx, room.GetRoomID())
	if err != nil {
		logs.CtxError(ctx, "ktv get room audience count err:%s", err)
		return nil, err
	}
	room.AudienceCount = audienceCount

	host, err := userFactory.GetActiveUserByRoomIDUserID(ctx, p.AppID, room.GetRoomID(), room.GetHostUserID())
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
	}

	seats, err := seatFactory.GetSeatsByRoomID(ctx, user.GetRoomID())
	if err != nil {
		logs.CtxError(ctx, "get seats failed,error:%s", err)
	}
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

	songService := ktv_service.GetSongService()
	curSong, err := songService.GetCurSong(ctx, user.GetRoomID())
	if err != nil {
		logs.CtxError(ctx, "get cur song failed,error:%s", err)
		return nil, err
	}

	resp = &reconnectResp{
		RoomInfo: room,
		HostInfo: host,
		UserInfo: user,
		SeatList: seatList,
		RtcToken: room.GenerateToken(ctx, user.GetUserID(), appInfo.AppId, appInfo.AppKey),
		CurSong:  curSong,
	}

	return resp, nil
}
