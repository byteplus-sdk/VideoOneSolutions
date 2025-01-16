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

	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/response"
	"github.com/gin-gonic/gin"
)

func GetVideoComments(httpCtx *gin.Context) {
	vid := httpCtx.Query("vid")
	if vid == "" {
		httpCtx.String(http.StatusBadRequest, response.NewCommonResponse(httpCtx, "", "vid is empty", custom_error.ErrInput))
		return
	}

	resp, err := drama_service.GetVideoComments(httpCtx, vid)
	if err != nil {
		httpCtx.String(http.StatusInternalServerError, response.NewCommonResponse(httpCtx, "", "", custom_error.InternalError(err)))
		return
	}

	httpCtx.String(http.StatusOK, response.NewCommonResponse(httpCtx, "", resp, nil))
}
