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
	"context"
	"encoding/json"

	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type getApplyAudienceListReq struct {
	RoomID     string `json:"room_id"`
	LoginToken string `json:"login_token"`
}

type getApplyAudienceListResp struct {
	AudienceList []*ktv_service.User `json:"audience_list"`
}

func (eh *EventHandler) GetApplyAudienceList(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "ktvGetApplyAudienceList param:%+v", param)
	var p getApplyAudienceListReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	if p.RoomID == "" {
		logs.CtxError(ctx, "input error, param:%v", p)
		return nil, custom_error.ErrInput
	}

	userFactory := ktv_service.GetUserFactory()

	audienceList, err := userFactory.GetApplyAudiencesByRoomID(ctx, param.AppID, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get audience list failed,error:%s", err)
		return nil, err
	}

	resp = &getAudienceListResp{
		AudienceList: audienceList,
	}

	return resp, nil
}
