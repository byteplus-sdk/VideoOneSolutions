/*
 * Copyright 2023 CloudWeGo Authors
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

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_cdn_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_room_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_util"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type createLiveReq struct {
	UserID       string `json:"user_id"`
	UserName     string `json:"user_name"`
	RoomName     string `json:"room_name"`
	LoginToken   string `json:"login_token"`
	LiveCdnAppID string `json:"live_cdn_app_id"`
}

type createLiveResp struct {
	LiveRoomInfo  *live_return_models.Room `json:"live_room_info"`
	UserInfo      *live_return_models.User `json:"user_info"`
	StreamPushUrl string                   `json:"stream_push_url"`
	RtmToken      string                   `json:"rtm_token"`
	RtcToken      string                   `json:"rtc_token"`
	RtcRoomID     string                   `json:"rtc_room_id"`
}

func (eh *EventHandler) CreateLive(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveCreateLive param:%+v", param)
	var p createLiveReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	userService := login_service.GetUserService()
	if userService.CheckLoginToken(ctx, p.LoginToken) != nil {
		return nil, err
	}
	//check param
	if p.UserID == "" || p.UserName == "" {
		logs.CtxError(ctx, "input error, param:%v", p)
		return nil, custom_error.ErrInput
	}
	appInfoService := login_service.GetAppInfoService()
	appInfo, _ := appInfoService.ReadAppInfoByAppId(ctx, param.AppID)

	//clear old user
	oldUsers, _ := live_facade.GetRoomUserRepo().GetUsersByUserID(ctx, param.AppID, p.UserID)
	for _, oldUser := range oldUsers {
		DisconnectLogic(ctx, param.AppID, oldUser.RoomID, oldUser.UserID)
	}

	roomService := live_room_service.GetRoomService()
	room, host, err := roomService.CreateRoom(ctx, param.AppID, p.RoomName, p.UserID, p.UserName, p.LiveCdnAppID)
	if err != nil {
		logs.CtxError(ctx, "create room failed,error:%s", err)
		return nil, err
	}

	//err = live_linkmic_api_service.AudienceInit(ctx, param.AppID, &live_linker_models.ApiAudienceInitReq{
	//	HostRoomID: room.RoomID,
	//	HostUserID: room.HostUserID,
	//})
	if err != nil {
		logs.CtxError(ctx, "init audience linkmic failed,error:%s", err)
		return nil, err
	}

	roomRepo := live_facade.GetRoomRepo()

	resp = &createLiveResp{
		LiveRoomInfo:  ConvertReturnRoom(room),
		UserInfo:      ConvertReturnUser(host),
		StreamPushUrl: live_cdn_service.GenPushUrl(ctx, room.RtcAppID, room.StreamID),
		RtmToken:      live_util.GenToken(room.RoomID, p.UserID, appInfo.AppId, appInfo.AppKey),
		RtcToken:      live_util.GenToken(roomRepo.GetRoomRtcRoomID(ctx, room.RoomID), p.UserID, appInfo.AppId, appInfo.AppKey),
		RtcRoomID:     roomRepo.GetRoomRtcRoomID(ctx, room.RoomID),
	}

	return resp, nil

}
