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

package drama_handler

import (
	"net/http"

	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_model"
	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/response"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
)

func GetDramaList(httpCtx *gin.Context) {
	req := &drama_model.GetDramaListReq{}
	err := httpCtx.ShouldBindJSON(req)
	if err != nil {
		logs.CtxError(httpCtx, "param error,err:%s", err)
		httpCtx.String(http.StatusBadRequest, response.NewVodCommonResponse(httpCtx, "", "", custom_error.ErrInput))
		return
	}

	resp, err := drama_service.GetDramaList(httpCtx, req.UserID, req.DramaID, req.PlayInfoType)
	if err != nil {
		logs.CtxError(httpCtx, "GetDramaChannel err: %s", err)
		httpCtx.String(http.StatusInternalServerError, response.NewVodCommonResponse(httpCtx, "", "", custom_error.InternalError(err)))
		return
	}
	httpCtx.String(http.StatusOK, response.NewVodCommonResponse(httpCtx, "", resp, nil))
}
