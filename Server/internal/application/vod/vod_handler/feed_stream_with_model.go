/*
 * Copyright 2023 CloudWeGo Authors
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

package vod_handler

import (
	"net/http"

	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_models"
	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/response"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"github.com/gin-gonic/gin"
)

func GetFeedStreamWithVideoModel(httpCtx *gin.Context) {
	ctx := util.EnsureID(httpCtx)
	req := &vod_models.GetFeedStreamRequest{}
	err := httpCtx.ShouldBindJSON(req)
	if err != nil {
		logs.CtxError(ctx, "param error,err:%s", err)
		httpCtx.String(http.StatusBadRequest, response.NewVodCommonResponse(ctx, "", "", custom_error.ErrInput))
		return
	}

	if req.PageSize <= 0 || req.PageSize > 100 {
		req.PageSize = 100
	}
	if req.AppID == "" {
		req.AppID = config.Configs().AppID
	}

	resp, err := vod_service.GetFeedStreamWithVideoModel(ctx, req)
	if err != nil {
		httpCtx.String(http.StatusInternalServerError, response.NewVodCommonResponse(ctx, "", "", custom_error.InternalError(err)))
		return
	}
	httpCtx.String(http.StatusOK, response.NewVodCommonResponse(ctx, "", resp, nil))
	return
}
