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
	"context"
	"encoding/json"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_cdn_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_api_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_util"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"

	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

const (
	LinkmicStatusOther           = 1
	LinkmicStatusAudienceLinkmic = 3
	LinkmicStatusAnchorLinkmic   = 4
)

type reconnectReq struct {
	RoomID     string `json:"room_id"`
	UserID     string `json:"user_id"`
	LoginToken string `json:"login_token"`
}

type reconnectInfo struct {
	LiveRoomInfo    *live_return_models.Room   `json:"live_room_info"`
	StreamPushUrl   string                     `json:"stream_push_url"`
	RtcRoomID       string                     `json:"rtc_room_id"`
	RtcToken        string                     `json:"rtc_token"`
	LinkmicUserList []*live_return_models.User `json:"linkmic_user_list"`
}

type reconnectResp struct {
	User          *live_return_models.User `json:"user"`
	LinkmicStatus int                      `json:"linkmic_status"`
	ReconnectInfo *reconnectInfo           `json:"reconnect_info"`
}

func (eh *EventHandler) Reconnect(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveReconnect param:%+v", param)
	var p reconnectReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	appInfoService := login_service.GetAppInfoService()
	appInfo, _ := appInfoService.ReadAppInfoByAppId(ctx, param.AppID)

	roomRepo := live_facade.GetRoomRepo()
	roomUserRepo := live_facade.GetRoomUserRepo()
	room, err := roomRepo.GetActiveRoom(ctx, param.AppID, p.RoomID)
	if err != nil {
		if err == custom_error.ErrRecordNotFound {
			return nil, custom_error.ErrRoomNotExist
		}
		logs.CtxError(ctx, "get room failed,roomID:%s,error:%s", p.RoomID, err)
		return nil, err
	}

	if room == nil {
		return nil, custom_error.ErrRoomNotExist
	}
	user, err := roomUserRepo.GetActiveUser(ctx, param.AppID, p.RoomID, p.UserID)
	if err != nil {
		if err == custom_error.ErrRecordNotFound {
			return nil, custom_error.ErrUserIsInactive
		}
		logs.CtxError(ctx, "get room failed,roomID:%s,error:%s", p.UserID, err)
		return nil, err
	}

	activeRoomLinkmicInfo, err := live_linkmic_api_service.GetActiveRoomLinkmicInfo(ctx, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get active room linkmic info failed,error:%s", err)
		return nil, err
	}

	reconnectInfo := &reconnectInfo{
		LiveRoomInfo:  ConvertReturnRoom(room),
		StreamPushUrl: live_cdn_service.GenPushUrl(ctx, room.RtcAppID, room.StreamID),
	}
	linkmicStatus := LinkmicStatusOther
	if activeRoomLinkmicInfo.IsLinked {
		if activeRoomLinkmicInfo.IsAnchorLink {
			linkmicStatus = LinkmicStatusAnchorLinkmic
		} else {
			linkmicStatus = LinkmicStatusAudienceLinkmic
		}
		reconnectInfo.RtcRoomID = roomRepo.GetRoomRtcRoomID(ctx, p.RoomID)
		reconnectInfo.RtcToken = live_util.GenToken(roomRepo.GetRoomRtcRoomID(ctx, p.RoomID), p.UserID, appInfo.AppId, appInfo.AppKey)
	}

	resp = &reconnectResp{
		User:          ConvertReturnUser(user),
		LinkmicStatus: linkmicStatus,
		ReconnectInfo: reconnectInfo,
	}

	return resp, nil
}
