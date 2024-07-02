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
	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_cdn_service"
)

func ConvertReturnRoom(room *live_entity.LiveRoom) *live_return_models.Room {
	resp := &live_return_models.Room{
		RtcAppID:          room.RtcAppID,
		RoomID:            room.RoomID,
		RoomName:          room.RoomName,
		HostUserID:        room.HostUserID,
		HostUserName:      room.HostUserName,
		Status:            room.Status,
		AudienceCount:     room.AudienceCount,
		StreamPullUrlList: live_cdn_service.GenPullUrl(room.StreamID),
		Extra:             room.Extra,
	}
	return resp
}

func ConvertReturnUser(roomUser *live_entity.LiveRoomUser) *live_return_models.User {
	resp := &live_return_models.User{}
	resp.RoomID = roomUser.RoomID
	resp.UserID = roomUser.UserID
	resp.UserName = roomUser.UserName
	resp.UserRole = roomUser.UserRole
	resp.Mic = roomUser.Mic
	resp.Camera = roomUser.Camera
	resp.Extra = roomUser.Extra

	return resp
}
