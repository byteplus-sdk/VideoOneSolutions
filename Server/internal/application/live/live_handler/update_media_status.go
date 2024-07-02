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
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_inform_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_api_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/inform"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type updateMediaStatusReq struct {
	AppID  string `json:"app_id" binding:"required"`
	RoomID string `json:"room_id" binding:"required"`
	UserID string `json:"user_id" binding:"required"`
	Mic    int    `json:"mic"`
	Camera int    `json:"camera"`
}

type updateMediaStatusResp struct {
}

func UpdateMediaStatus(ctx *gin.Context) (resp interface{}, err error) {
	var p updateMediaStatusReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		logs.CtxError(ctx, "param error,err:"+err.Error())
		return nil, err
	}

	roomUserRepo := live_facade.GetRoomUserRepo()
	user, err := roomUserRepo.GetActiveUser(ctx, p.AppID, p.RoomID, p.UserID)
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return nil, err
	}

	if p.Mic != -1 {
		user.Mic = p.Mic
	}
	if p.Camera != -1 {
		user.Camera = p.Camera
	}

	err = roomUserRepo.Save(ctx, user)
	if err != nil {
		logs.CtxError(ctx, "save user failed,error:%s", err)
		return nil, err
	}

	informData := &live_inform_service.InformMediaChange{
		RoomID: p.RoomID,
		UserID: p.UserID,
		Camera: user.Camera,
		Mic:    user.Mic,
	}
	roomIDs := make(map[string]interface{}, 0)
	roomIDs[p.RoomID] = true

	linkmicInfo, err := live_linkmic_api_service.GetActiveRoomLinkmicInfo(ctx, p.RoomID)
	if err != nil {
		logs.CtxInfo(ctx, "get linkmic info failed,error:%s", err)
		return nil, err
	}

	if len(linkmicInfo.LinkedUsers) != 0 {
		for _, linker := range linkmicInfo.LinkedUsers[p.RoomID] {
			roomIDs[linker.ToRoomID] = true
			roomIDs[linker.FromRoomID] = true
		}
	}

	informer := inform.GetInformService(p.AppID)
	for roomID := range roomIDs {
		informer.BroadcastRoom(ctx, roomID, live_inform_service.OnMediaChange, informData)
	}

	return nil, nil

}
