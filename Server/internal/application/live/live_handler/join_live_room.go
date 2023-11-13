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
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_api_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_room_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_util"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"

	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type joinLiveRoomReq struct {
	RoomID     string `json:"room_id"`
	UserID     string `json:"user_id"`
	UserName   string `json:"user_name"`
	LoginToken string `json:"login_token"`
}

type joinLiveRoomResp struct {
	LiveRoomInfo *live_return_models.Room `json:"live_room_info"`
	UserInfo     *live_return_models.User `json:"user_info"`
	HostUserInfo *live_return_models.User `json:"host_user_info"`
	RtmToken     string                   `json:"rtm_token"`
}

func (eh *EventHandler) JoinLiveRoom(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveJoinLiveRoom param:%+v", param)
	var p joinLiveRoomReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	//check param
	if p.RoomID == "" || p.UserID == "" || p.UserName == "" {
		logs.CtxError(ctx, "input error, param:%v", p)
		return nil, custom_error.ErrInput
	}

	//clear old user
	oldUsers, _ := live_facade.GetRoomUserRepo().GetUsersByUserID(ctx, param.AppID, p.UserID)
	for _, oldUser := range oldUsers {
		DisconnectLogic(ctx, oldUser.RoomID, oldUser.UserID, param.AppID)
	}

	roomService := live_room_service.GetRoomService()
	room, audience, err := roomService.JoinRoom(ctx, param.AppID, p.RoomID, p.UserID, p.UserName)
	if err != nil {
		logs.CtxError(ctx, "join room failed,error:%s", err)
		return nil, err
	}

	host, err := live_facade.GetRoomUserRepo().GetActiveUser(ctx, param.AppID, room.RoomID, room.HostUserID)
	if err != nil {
		logs.CtxError(ctx, "get host failed,error:%s", err)
		return nil, err
	}
	hostReturn := ConvertReturnUser(host)

	linkmicInfo, err := live_linkmic_api_service.GetActiveRoomLinkmicInfo(ctx, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get linkmic info failed,error:%s", err)
		return nil, err
	}

	if linkmicInfo != nil {
		if linkmicInfo.IsAnchorLink == false && linkmicInfo.IsLinked {
			hostReturn.LinkmicStatus = live_return_models.UserLinkmicStatusAudienceLinkmicLinked
		}
		if linkmicInfo.IsAnchorLink && linkmicInfo.IsLinked {
			hostReturn.LinkmicStatus = live_return_models.UserLinkmicStatusAnchorLinkmicLinked
		}
	}

	appInfoService := login_service.GetAppInfoService()
	appInfo, _ := appInfoService.ReadAppInfoByAppId(ctx, param.AppID)

	resp = &joinLiveRoomResp{
		LiveRoomInfo: ConvertReturnRoom(room),
		UserInfo:     ConvertReturnUser(audience),
		HostUserInfo: hostReturn,
		RtmToken:     live_util.GenToken(p.RoomID, p.UserID, appInfo.AppId, appInfo.AppKey),
	}

	return resp, nil

}
