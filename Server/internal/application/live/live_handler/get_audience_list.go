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
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_linker_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_api_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_util"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type getAudienceListReq struct {
	AppID  string `json:"app_id" binding:"required"`
	RoomID string `json:"room_id" binding:"required"`
}

type getAudienceListResp struct {
	AudienceList []*live_return_models.User `json:"audience_list"`
}

func GetAudienceList(ctx *gin.Context) (resp interface{}, err error) {
	var p getAudienceListReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	audiences, err := live_util.GetReturnUserAudience(ctx, p.AppID, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get audiences failed,error:%s", err)
		return nil, err
	}

	linkmicInfo, err := live_linkmic_api_service.GetActiveRoomLinkmicInfo(ctx, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get linkmic info failed,error:%s", err)
		return nil, err
	}

	for _, audience := range audiences {
		for _, linker := range linkmicInfo.LinkedUsers[p.RoomID] {
			if audience.UserID == linker.FromUserID {
				audience.LinkmicStatus = live_return_models.UserLinkmicStatusAudienceLinkmicLinked
				audience.LinkmicTime = linker.LinkedTime
			}
		}
		for _, linker := range linkmicInfo.ApplyUsers[p.RoomID] {
			if audience.UserID == linker.FromUserID {
				audience.LinkmicStatus = live_return_models.UserLinkmicStatusAudienceLinkmicApply
			}
		}

		for _, user := range linkmicInfo.InviteUsers[p.RoomID] {
			if audience.UserID == user.FromUserID {
				audience.LinkmicStatus = live_return_models.UserLinkmicStatusAudienceLinkmicInviting
			}
		}
		if audience.LinkmicStatus == live_return_models.UserLinkmicStatusUnknown {
			scene, err := live_linkmic_api_service.GetInvited(ctx, audience.RoomID, audience.UserID)
			if err != nil {
				continue
			}
			if scene == live_linker_models.LinkerSceneAudience {
				audience.LinkmicStatus = live_return_models.UserLinkmicStatusAudienceLinkmicInviting
			}
		}
	}

	resp = &getAudienceListResp{
		AudienceList: audiences,
	}
	return resp, nil
}
