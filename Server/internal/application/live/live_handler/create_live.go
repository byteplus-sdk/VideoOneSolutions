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
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_cdn_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_room_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_util"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type createLiveReq struct {
	AppID        string `json:"app_id" binding:"required"`
	UserID       string `json:"user_id" binding:"required"`
	UserName     string `json:"user_name" binding:"required"`
	RoomName     string `json:"room_name"`
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

func CreateLive(ctx *gin.Context) (resp interface{}, err error) {
	var p createLiveReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	appInfoService := login_service.GetAppInfoService()
	appInfo, _ := appInfoService.ReadAppInfoByAppId(ctx, p.AppID)

	//clear old user
	oldUsers, _ := live_facade.GetRoomUserRepo().GetUsersByUserID(ctx, p.AppID, p.UserID)
	for _, oldUser := range oldUsers {
		DisconnectLogic(ctx, p.AppID, oldUser.RoomID, oldUser.UserID)
	}

	roomService := live_room_service.GetRoomService()
	room, host, err := roomService.CreateRoom(ctx, p.AppID, p.RoomName, p.UserID, p.UserName, p.LiveCdnAppID)
	if err != nil {
		logs.CtxError(ctx, "create room failed,error:%s", err)
		return nil, err
	}

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
