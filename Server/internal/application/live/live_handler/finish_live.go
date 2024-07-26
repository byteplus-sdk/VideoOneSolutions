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

	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_room_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_api_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_room_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli/lock"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type finishLiveReq struct {
	AppID      string `json:"app_id" binding:"required"`
	RoomID     string `json:"room_id" binding:"required"`
	UserID     string `json:"user_id" binding:"required"`
	FinishType string `json:"finish_type"`
}

type finishLiveResp struct {
	LiveRoomInfo *live_return_models.Room `json:"live_room_info"`
}

func FinishLive(ctx *gin.Context) (resp interface{}, err error) {
	var p finishLiveReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	return FinishLiveLogic(ctx, p.AppID, p)
}

func FinishLiveLogic(ctx context.Context, appID string, p finishLiveReq) (resp interface{}, err error) {
	// if room hae been finished, return Error
	roomRepo := live_facade.GetRoomRepo()
	r, err := roomRepo.GetRoomByRoomID(ctx, appID, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed, error:%s", err)
		return nil, err
	}
	if r.IsFinished() {
		logs.CtxWarn(ctx, "room: "+p.RoomID+" has been finished")
		return nil, custom_error.ErrRoomIsInactive
	}

	ok, lt := lock.LockRoom(ctx, r.RoomID)
	if !ok {
		return nil, custom_error.ErrLockRedis
	}
	defer lock.UnLockRoom(ctx, r.RoomID, lt)

	err = live_linkmic_api_service.FinishHostLinkmic(ctx, appID, p.RoomID, p.UserID)
	if err != nil {
		logs.CtxError(ctx, "finish linkmic failed,error:%s", err.Error())
		return nil, err
	}

	roomService := live_room_service.GetRoomService()
	var room *live_entity.LiveRoom
	if p.FinishType == live_room_models.RoomFinishTimeOut {
		room, err = roomService.FinishRoom(ctx, appID, p.RoomID, p.UserID, live_room_models.RoomFinishTypeTimeout)
	} else {
		room, err = roomService.FinishRoom(ctx, appID, p.RoomID, p.UserID, live_room_models.RoomFinishTypeNormal)
	}
	if err != nil {
		logs.CtxError(ctx, "finish room failed,error:%s", err)
		return nil, err
	}

	resp = &finishLiveResp{
		LiveRoomInfo: ConvertReturnRoom(room),
	}

	return resp, nil
}
