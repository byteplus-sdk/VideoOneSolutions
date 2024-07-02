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

package ktv_handler

import (
	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type getApplyAudienceListReq struct {
	AppID  string `json:"app_id" binding:"required"`
	RoomID string `json:"room_id" binding:"required"`
}

type getApplyAudienceListResp struct {
	AudienceList []*ktv_service.User `json:"audience_list"`
}

func GetApplyAudienceList(ctx *gin.Context) (resp interface{}, err error) {
	var p getApplyAudienceListReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		logs.CtxError(ctx, "param error,err:"+err.Error())
		return nil, err
	}

	if p.RoomID == "" {
		logs.CtxError(ctx, "input error, param:%v", p)
		return nil, custom_error.ErrInput
	}

	userFactory := ktv_service.GetUserFactory()

	audienceList, err := userFactory.GetApplyAudiencesByRoomID(ctx, p.AppID, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get audience list failed,error:%s", err)
		return nil, err
	}

	resp = &getApplyAudienceListResp{
		AudienceList: audienceList,
	}

	return resp, nil
}
