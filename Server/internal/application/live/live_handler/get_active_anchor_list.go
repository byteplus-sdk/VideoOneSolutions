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
	"github.com/byteplus/VideoOneServer/internal/application/live/live_util"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type getActiveAnchorListReq struct {
	RoomID     string `json:"room_id"`
	LoginToken string `json:"login_token"`
}

type getActiveAnchorListResp struct {
	AnchorList []*live_return_models.User `json:"anchor_list"`
}

func (eh *EventHandler) GetActiveAnchorList(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveGetActiveAnchorList param:%+v", param)
	var p getActiveAnchorListReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	anchors, err := live_util.GetReturnUserAnchors(ctx, param.AppID)
	if err != nil {
		logs.CtxError(ctx, "get audiences failed,error:%s", err)
		return nil, err
	}

	returnAnchorList := make([]*live_return_models.User, 0)
	for _, anchor := range anchors {
		if anchor.UserID != param.UserID {
			returnAnchorList = append(returnAnchorList, anchor)
		}
	}

	resp = &getActiveAnchorListResp{
		AnchorList: returnAnchorList,
	}

	return resp, nil

}
