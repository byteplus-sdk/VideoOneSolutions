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
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_util"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type getActiveAnchorListReq struct {
	AppID string `json:"app_id" binding:"required"`
}

type getActiveAnchorListResp struct {
	AnchorList []*live_return_models.User `json:"anchor_list"`
}

func GetActiveAnchorList(ctx *gin.Context) (resp interface{}, err error) {
	var p getActiveAnchorListReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		logs.CtxError(ctx, "param error,err:"+err.Error())
		return nil, err
	}

	anchors, err := live_util.GetReturnUserAnchors(ctx, p.AppID)
	if err != nil {
		logs.CtxError(ctx, "get audiences failed,error:%s", err)
		return nil, err
	}
	loginToken := ctx.GetHeader(public.HeaderLoginToken)
	userID := login_service.GetUserService().GetUserID(ctx, loginToken)

	returnAnchorList := make([]*live_return_models.User, 0)
	for _, anchor := range anchors {
		if anchor.UserID != userID {
			returnAnchorList = append(returnAnchorList, anchor)
		}
	}

	resp = &getActiveAnchorListResp{
		AnchorList: returnAnchorList,
	}

	return resp, nil

}
