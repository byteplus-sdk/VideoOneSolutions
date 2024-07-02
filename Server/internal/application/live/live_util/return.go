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

package live_util

import (
	"context"
	"sort"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_cdn_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

func GetReturnActiveRooms(ctx context.Context, appID string) ([]*live_return_models.Room, error) {
	resp := make([]*live_return_models.Room, 0)
	rooms, err := live_facade.GetRoomRepo().GetActiveRooms(ctx, appID)
	if err != nil {
		logs.CtxError(ctx, "get rooms failed,error:%s", err)
		return nil, err
	}
	sort.SliceStable(rooms, func(i, j int) bool {
		return rooms[i].StartTime.After(rooms[j].StartTime)
	})
	for _, room := range rooms {
		returnRoom := &live_return_models.Room{
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
		resp = append(resp, returnRoom)
	}

	return resp, nil
}

func GetReturnUser(ctx context.Context, appID, roomID, userID string) (*live_return_models.User, error) {
	resp := &live_return_models.User{
		RoomID: roomID,
		UserID: userID,
	}
	roomUser, err := live_facade.GetRoomUserRepo().GetActiveUser(ctx, appID, roomID, userID)
	if err != nil {
		logs.CtxError(ctx, "get room user failed,error:%s", err)
	} else {
		resp.UserName = roomUser.UserName
		resp.UserRole = roomUser.UserRole
		resp.Mic = roomUser.Mic
		resp.Camera = roomUser.Camera
		resp.Extra = roomUser.Extra
	}

	return resp, nil
}

func GetReturnUserAudience(ctx context.Context, appID, roomID string) ([]*live_return_models.User, error) {
	roomUsers, err := live_facade.GetRoomUserRepo().GetAudiencesByRoomID(ctx, appID, roomID)
	if err != nil {
		logs.CtxError(ctx, "get room user failed,error:%s", err)
		return nil, err
	}
	resp := make([]*live_return_models.User, 0)
	for _, roomUser := range roomUsers {
		user := &live_return_models.User{
			RoomID:   roomUser.RoomID,
			UserID:   roomUser.UserID,
			UserName: roomUser.UserName,
			UserRole: roomUser.UserRole,
			Mic:      roomUser.Mic,
			Camera:   roomUser.Camera,
			Extra:    roomUser.Extra,
		}
		resp = append(resp, user)
	}

	return resp, nil
}

func GetReturnUserAnchors(ctx context.Context, appID string) ([]*live_return_models.User, error) {
	roomUsers, err := live_facade.GetRoomUserRepo().GetAnchors(ctx, appID)
	if err != nil {
		logs.CtxError(ctx, "get room user failed,error:%s", err)
		return nil, err
	}
	sort.SliceStable(roomUsers, func(i, j int) bool {
		return roomUsers[i].CreateTime.After(roomUsers[j].CreateTime)
	})

	resp := make([]*live_return_models.User, 0)
	for _, roomUser := range roomUsers {
		user := &live_return_models.User{
			RoomID:   roomUser.RoomID,
			UserID:   roomUser.UserID,
			UserName: roomUser.UserName,
			UserRole: roomUser.UserRole,
			Mic:      roomUser.Mic,
			Camera:   roomUser.Camera,
			Extra:    roomUser.Extra,
		}
		resp = append(resp, user)
	}

	return resp, nil
}
