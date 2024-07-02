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
	"github.com/gin-gonic/gin"
)

func Disconnect(ctx *gin.Context, appID, roomID, userID string) (err error) {
	return ktv_service.GetRoomService().Disconnect(ctx, appID, roomID, userID)
}
