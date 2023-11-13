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

var roomUserRepo RoomUserRepoInterface

func GetRoomUserRepo() RoomUserRepoInterface {
	if roomUserRepo == nil {
		roomUserRepo = &live_implement.RoomUserRepoImpl{}
	}
	return roomUserRepo
}

type RoomUserRepoInterface interface {
	Save(ctx context.Context, user *live_entity.LiveRoomUser) error

	GetActiveUser(ctx context.Context, appID, roomID, userID string) (*live_entity.LiveRoomUser, error)

	GetUser(ctx context.Context, appID, roomID, userID string) (*live_entity.LiveRoomUser, error)

	GetUsersByRoomIDUserIDs(ctx context.Context, appID, roomID string, userIDs []string) (map[string]*live_entity.LiveRoomUser, error)

	GetAudiencesByRoomID(ctx context.Context, appID, roomID string) ([]*live_entity.LiveRoomUser, error)

	GetAnchors(ctx context.Context, appID string) ([]*live_entity.LiveRoomUser, error)

	GetUsersByUserID(ctx context.Context, appID, userID string) ([]*live_entity.LiveRoomUser, error)

	UpdateUsersByRoomID(ctx context.Context, appID, roomID string, ups map[string]interface{}) error
}
