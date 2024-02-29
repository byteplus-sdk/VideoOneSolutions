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
	"context"
	"encoding/json"

	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_service"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type joinLiveRoomReq struct {
	UserID     string `json:"user_id"`
	UserName   string `json:"user_name"`
	RoomID     string `json:"room_id"`
	LoginToken string `json:"login_token"`
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

func (eh *EventHandler) JoinLiveRoom(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "ktvJoinLiveRoom param:%+v", param)
	var p joinLiveRoomReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	if p.UserID == "" || p.UserName == "" || p.RoomID == "" {
		logs.CtxError(ctx, "input error, param:%v", p)
		return nil, custom_error.ErrInput
	}
	if err := login_service.GetUserService().CheckUserID(ctx, p.LoginToken, p.UserID); err != nil {
		logs.CtxInfo(ctx, "check userid error:%s", err)
		return nil, err
	}

	roomFactory := ktv_service.GetRoomFactory()
	userFactory := ktv_service.GetUserFactory()
	seatFactory := ktv_service.GetSeatFactory()

	roomService := ktv_service.GetRoomService()
	err = roomService.JoinRoom(ctx, param.AppID, p.RoomID, p.UserID, p.UserName, param.DeviceID)
	if err != nil {
		logs.CtxError(ctx, "join room failed,error:%s", err)
		return nil, err
	}

	room, err := roomFactory.GetRoomByRoomID(ctx, param.AppID, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		return nil, err
	}
	if room == nil {
		logs.CtxError(ctx, "room is not exist")
		return nil, custom_error.ErrRoomNotExist
	}
	host, _ := userFactory.GetUserByRoomIDUserID(ctx, param.AppID, room.GetRoomID(), room.GetHostUserID())
	user, _ := userFactory.GetActiveUserByRoomIDUserID(ctx, param.AppID, p.RoomID, p.UserID)

	seats, _ := seatFactory.GetSeatsByRoomID(ctx, p.RoomID)
	seatList := make(map[int]*ktv_service.SeatInfo)
	for _, seat := range seats {
		if seat.GetOwnerUserID() != "" {
			u, _ := userFactory.GetActiveUserByRoomIDUserID(ctx, param.AppID, seat.GetRoomID(), seat.GetOwnerUserID())
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
	appInfo, _ := appInfoService.ReadAppInfoByAppId(ctx, param.AppID)

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
