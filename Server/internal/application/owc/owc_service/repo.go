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

package owc_service

import (
	"context"

	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_db"
	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_entity"
	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_redis"
)

var roomRepoClient RoomRepo
var userRepoClient UserRepo
var songRepoClient SongRepo

func GetRoomRepo() RoomRepo {
	if roomRepoClient == nil {
		roomRepoClient = &owc_db.DbRoomRepo{}
	}
	return roomRepoClient
}

func GetUserRepo() UserRepo {
	if userRepoClient == nil {
		userRepoClient = &owc_db.DbUserRepo{}
	}
	return userRepoClient
}

func GetSongRepo() SongRepo {
	if songRepoClient == nil {
		songRepoClient = &owc_redis.RedisSongRepo{}
	}
	return songRepoClient
}

type RoomRepo interface {
	//create or update
	Save(ctx context.Context, room *owc_entity.OwcRoom) error

	//get
	GetRoomByRoomID(ctx context.Context, appID, roomID string) (*owc_entity.OwcRoom, error)
	GetActiveRooms(ctx context.Context, appID string) ([]*owc_entity.OwcRoom, error)
	GetAllActiveRooms(ctx context.Context) ([]*owc_entity.OwcRoom, error)
}

type UserRepo interface {
	//create or update
	Save(ctx context.Context, user *owc_entity.OwcUser) error

	//update users
	UpdateUsersWithMapByRoomID(ctx context.Context, appID, roomID string, ups map[string]interface{}) error

	//get user
	GetActiveUserByRoomIDUserID(ctx context.Context, appID, roomID, userID string) (*owc_entity.OwcUser, error)
	GetUserByRoomIDUserID(ctx context.Context, appID, roomID, userID string) (*owc_entity.OwcUser, error)
	GetActiveUserByUserID(ctx context.Context, appID, userID string) (*owc_entity.OwcUser, error)

	//get users
	GetActiveUsersByRoomID(ctx context.Context, appID, roomID string) ([]*owc_entity.OwcUser, error)
}

type SongRepo interface {
	List(ctx context.Context, roomID string) ([]*owc_entity.OwcSong, error)
	Push(ctx context.Context, roomID string, song *owc_entity.OwcSong) error
	UpdateTop(ctx context.Context, roomID string, song *owc_entity.OwcSong) error
	Pop(ctx context.Context, roomID string) (*owc_entity.OwcSong, error)
	LIndex(ctx context.Context, roomID string, index int64) (*owc_entity.OwcSong, error)
	SetUser(ctx context.Context, roomID string, song *owc_entity.OwcSong, userId string) error
	GetUser(ctx context.Context, roomID string, song *owc_entity.OwcSong) (*owc_redis.OwcSongSingUser, error)
	DelUser(ctx context.Context, roomID string, song *owc_entity.OwcSong)
}

type SongInfoRepo interface {
	OwcGetPresetSong(ctx context.Context) ([]owc_entity.PresetSong, error)
}
