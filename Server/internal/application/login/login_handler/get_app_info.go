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

package login_handler

import (
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type getAppInfoReq struct {
	ScenesName string `json:"scenes_name"`
}

type getAppInfoResp struct {
	AppID string `json:"app_id"`
	BID   string `json:"bid"`
}

func GetAppInfo(ctx *gin.Context) (resp interface{}, err error) {
	var p getAppInfoReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	bid, ok := public.BidMap[p.ScenesName]
	if !ok || bid == "" {
		return nil, custom_error.ErrGetBID
	}

	return &getAppInfoResp{
		BID:   bid,
		AppID: config.Configs().RTCAppID,
	}, nil
}
