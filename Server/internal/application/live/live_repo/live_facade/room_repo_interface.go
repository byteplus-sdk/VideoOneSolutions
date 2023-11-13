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

package live_facade

import (
	"context"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_implement"
)

var roomRepo RoomRepoInterface

func GetRoomRepo() RoomRepoInterface {
	if roomRepo == nil {
		roomRepo = &live_implement.RoomRepoImpl{}
	}
	return roomRepo
}

type RoomRepoInterface interface {
	Save(ctx context.Context, room *live_entity.LiveRoom) error

	GetActiveRoom(ctx context.Context, appID, roomID string) (*live_entity.LiveRoom, error)

	GetRoom(ctx context.Context, appID, roomID string) (*live_entity.LiveRoom, error)
	GetRoomByRoomID(ctx context.Context, appID, roomID string) (*live_entity.LiveRoom, error)

	GetActiveRooms(ctx context.Context, appID string) ([]*live_entity.LiveRoom, error)
	GetAllActiveRooms(ctx context.Context) ([]*live_entity.LiveRoom, error)

	GetRooms(ctx context.Context, appID string) ([]*live_entity.LiveRoom, error)

	AddRoomAudienceCount(ctx context.Context, roomID string) error

	SubRoomAudienceCount(ctx context.Context, roomID string) error

	GetRoomAudienceCount(ctx context.Context, roomID string) (int, error)

	SetRoomRtcRoomID(ctx context.Context, roomID string, rtcRoomID string)
	GetRoomRtcRoomID(ctx context.Context, roomID string) string
	DelRoomRtcRoomID(ctx context.Context, roomID string)
}
