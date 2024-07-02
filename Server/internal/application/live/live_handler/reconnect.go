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
	"errors"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_cdn_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_api_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_util"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type reconnectReq struct {
	AppID  string `json:"app_id" binding:"required"`
	RoomID string `json:"room_id" binding:"required"`
	UserID string `json:"user_id" binding:"required"`
}

type reconnectInfo struct {
	LiveRoomInfo    *live_return_models.Room   `json:"live_room_info"`
	StreamPushUrl   string                     `json:"stream_push_url"`
	RtcRoomID       string                     `json:"rtc_room_id"`
	RtcToken        string                     `json:"rtc_token"`
	LinkmicUserList []*live_return_models.User `json:"linkmic_user_list"`
	LinkerID        string                     `json:"linker_id"`
}

type reconnectResp struct {
	User          *live_return_models.User `json:"user"`
	LinkmicStatus int                      `json:"linkmic_status"`
	ReconnectInfo *reconnectInfo           `json:"reconnect_info"`
}

func Reconnect(ctx *gin.Context) (resp interface{}, err error) {
	var p reconnectReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	roomRepo := live_facade.GetRoomRepo()
	roomUserRepo := live_facade.GetRoomUserRepo()
	room, err := roomRepo.GetActiveRoom(ctx, p.AppID, p.RoomID)
	if err != nil {
		if errors.Is(err, custom_error.ErrRecordNotFound) {
			return nil, custom_error.ErrRoomNotExist
		}
		logs.CtxError(ctx, "get room failed,roomID:%s,error:%s", p.RoomID, err)
		return nil, err
	}

	if room == nil {
		return nil, custom_error.ErrRoomNotExist
	}
	user, err := roomUserRepo.GetActiveUser(ctx, p.AppID, p.RoomID, p.UserID)
	if err != nil {
		if errors.Is(err, custom_error.ErrRecordNotFound) {
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
		StreamPushUrl: live_cdn_service.GenPushUrl(room.StreamID),
	}
	linkmicStatus := live_return_models.UserLinkmicStatusUnknown
	if activeRoomLinkmicInfo.IsLinked {
		if activeRoomLinkmicInfo.IsAnchorLink {
			linkmicStatus = live_return_models.UserLinkmicStatusAnchorLinkmicLinked
			if len(activeRoomLinkmicInfo.Linkers) != 0 {
				reconnectInfo.LinkerID = activeRoomLinkmicInfo.Linkers[0].LinkerID
			}
		} else {
			linkmicStatus = live_return_models.UserLinkmicStatusAudienceLinkmicLinked
			var linkmicUserList = make([]*live_return_models.User, 0)
			if len(activeRoomLinkmicInfo.LinkedUsers) != 0 {
				var userIDs []string
				for _, linker := range activeRoomLinkmicInfo.LinkedUsers[p.RoomID] {
					userIDs = append(userIDs, linker.FromUserID)
					if !util.StringInSlice(linker.ToUserID, userIDs) {
						userIDs = append(userIDs, linker.ToUserID)
					}
				}
				roomUsers, err := live_facade.GetRoomUserRepo().GetUsersByRoomIDUserIDs(ctx, p.AppID, p.RoomID, userIDs)
				if err != nil {
					logs.CtxError(ctx, "get room users failed,error:%s", err.Error())
					return nil, err
				}

				for _, roomUser := range roomUsers {
					user := &live_return_models.User{
						RoomID:   roomUser.RoomID,
						UserID:   roomUser.UserID,
						UserName: roomUser.UserName,
						UserRole: roomUser.UserRole,
						Mic:      roomUser.Mic,
						Camera:   roomUser.Camera,
						Extra:    roomUser.Extra,
					}
					linkmicUserList = append(linkmicUserList, user)
				}
				reconnectInfo.LinkmicUserList = linkmicUserList
			}
		}
		reconnectInfo.RtcRoomID = roomRepo.GetRoomRtcRoomID(ctx, p.RoomID)
		reconnectInfo.RtcToken = live_util.GenToken(roomRepo.GetRoomRtcRoomID(ctx, p.RoomID), p.UserID)
	}

	resp = &reconnectResp{
		User:          ConvertReturnUser(user),
		LinkmicStatus: linkmicStatus,
		ReconnectInfo: reconnectInfo,
	}

	return resp, nil
}
