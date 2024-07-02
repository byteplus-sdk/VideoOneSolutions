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
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_api_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_room_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_util"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type joinLiveRoomReq struct {
	AppID    string `json:"app_id" binding:"required"`
	RoomID   string `json:"room_id" binding:"required"`
	UserID   string `json:"user_id" binding:"required"`
	UserName string `json:"user_name" binding:"required"`
}

type joinLiveRoomResp struct {
	LiveRoomInfo *live_return_models.Room `json:"live_room_info"`
	UserInfo     *live_return_models.User `json:"user_info"`
	HostUserInfo *live_return_models.User `json:"host_user_info"`
	RtmToken     string                   `json:"rtm_token"`
}

func JoinLiveRoom(ctx *gin.Context) (resp interface{}, err error) {
	var p joinLiveRoomReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	//clear old user
	oldUsers, _ := live_facade.GetRoomUserRepo().GetUsersByUserID(ctx, p.AppID, p.UserID)
	for _, oldUser := range oldUsers {
		DisconnectLogic(ctx, oldUser.RoomID, oldUser.UserID, p.AppID)
	}

	roomService := live_room_service.GetRoomService()
	room, audience, err := roomService.JoinRoom(ctx, p.AppID, p.RoomID, p.UserID, p.UserName)
	if err != nil {
		logs.CtxError(ctx, "join room failed,error:%s", err)
		return nil, err
	}

	host, err := live_facade.GetRoomUserRepo().GetActiveUser(ctx, p.AppID, room.RoomID, room.HostUserID)
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
		if !linkmicInfo.IsAnchorLink && linkmicInfo.IsLinked {
			hostReturn.LinkmicStatus = live_return_models.UserLinkmicStatusAudienceLinkmicLinked
		}
		if linkmicInfo.IsAnchorLink && linkmicInfo.IsLinked {
			hostReturn.LinkmicStatus = live_return_models.UserLinkmicStatusAnchorLinkmicLinked
		}
	}

	resp = &joinLiveRoomResp{
		LiveRoomInfo: ConvertReturnRoom(room),
		UserInfo:     ConvertReturnUser(audience),
		HostUserInfo: hostReturn,
		RtmToken:     live_util.GenToken(p.RoomID, p.UserID),
	}

	return resp, nil
}
