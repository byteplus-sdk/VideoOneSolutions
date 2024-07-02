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
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_room_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type startLiveReq struct {
	RoomID string `json:"room_id" binding:"required"`
	UserID string `json:"user_id" binding:"required"`
	AppID  string `json:"app_id" binding:"required"`
}

type startLiveResp struct {
	UserInfo *live_return_models.User `json:"user_info"`
}

func StartLive(ctx *gin.Context) (resp interface{}, err error) {
	var p startLiveReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		logs.CtxError(ctx, "param error,err:"+err.Error())
		return nil, err
	}

	roomService := live_room_service.GetRoomService()
	_, host, err := roomService.StartRoom(ctx, p.AppID, p.RoomID, p.UserID)
	if err != nil {
		logs.CtxError(ctx, "create room failed,error:%s", err)
		return nil, err
	}

	resp = startLiveResp{
		UserInfo: ConvertReturnUser(host),
	}

	return resp, nil

}
