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

var linkerRepo LinkerRepoInterface

func GetLinkerRepo() LinkerRepoInterface {
	if linkerRepo == nil {
		linkerRepo = &live_implement.LinkerRepoImpl{}
	}
	return linkerRepo
}

type LinkerRepoInterface interface {
	SaveLinker(ctx context.Context, linker *live_entity.LiveLinker) error
	GetLinker(ctx context.Context, linkerID string) (*live_entity.LiveLinker, error)
	UpdateLinker(ctx context.Context, linkerID string, ups map[string]interface{}) error
	GetLinkersByRoomIDScene(ctx context.Context, roomID string, scene int) ([]*live_entity.LiveLinker, error)
	GetActiveLinkersByRoomIDScene(ctx context.Context, roomID string, scene int) ([]*live_entity.LiveLinker, error)
	GetAudienceLinkerByRoomIDAndUserID(ctx context.Context, roomID, userID string) (*live_entity.LiveLinker, error)
	GetValidInvitee(ctx context.Context, linkerID, roomID, userID string) (*live_entity.LiveLinker, error)
	GetLinkedUsersByLinkerID(ctx context.Context, linkerID string) ([]*live_entity.LiveRoomUser, error)
}
