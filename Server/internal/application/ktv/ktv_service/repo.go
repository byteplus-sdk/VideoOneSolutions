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

package ktv_service

import (
	"context"

	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_db"
	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_entity"
	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_redis"
)

var roomRepoClient RoomRepo
var userRepoClient UserRepo
var seatRepoClient SeatRepo
var songRepoClient SongRepo
var presetSongRepoClient SongInfoRepo

func GetRoomRepo() RoomRepo {
	if roomRepoClient == nil {
		roomRepoClient = &ktv_db.DbRoomRepo{}
	}
	return roomRepoClient
}

func GetUserRepo() UserRepo {
	if userRepoClient == nil {
		userRepoClient = &ktv_db.DbUserRepo{}
	}
	return userRepoClient
}

func GetSeatRepo() SeatRepo {
	if seatRepoClient == nil {
		seatRepoClient = &ktv_redis.RedisSeatRepo{}
	}
	return seatRepoClient
}

func GetSongRepo() SongRepo {
	if songRepoClient == nil {
		songRepoClient = &ktv_redis.RedisSongRepo{}
	}
	return songRepoClient
}

func GetPresetSongRepo() SongInfoRepo {
	if presetSongRepoClient == nil {
		presetSongRepoClient = &ktv_db.DbPresetSongRepo{}
	}
	return presetSongRepoClient
}

type RoomRepo interface {
	//create or update
	Save(ctx context.Context, room *ktv_entity.KtvRoom) error

	//get
	GetRoomByRoomID(ctx context.Context, appID, roomID string) (*ktv_entity.KtvRoom, error)
	GetActiveRooms(ctx context.Context, appID string) ([]*ktv_entity.KtvRoom, error)
	GetAllActiveRooms(ctx context.Context) ([]*ktv_entity.KtvRoom, error)
}

type UserRepo interface {
	//create or update
	Save(ctx context.Context, user *ktv_entity.KtvUser) error

	//update users
	UpdateUsersWithMapByRoomID(ctx context.Context, appID, roomID string, ups map[string]interface{}) error

	//get user
	GetActiveUserByRoomIDUserID(ctx context.Context, appID, roomID, userID string) (*ktv_entity.KtvUser, error)
	GetUserByRoomIDUserID(ctx context.Context, appID, roomID, userID string) (*ktv_entity.KtvUser, error)
	GetActiveUserByUserID(ctx context.Context, appID, userID string) (*ktv_entity.KtvUser, error)

	//get users
	GetActiveUsersByRoomID(ctx context.Context, appID, roomID string) ([]*ktv_entity.KtvUser, error)
	GetAudiencesWithoutApplyByRoomID(ctx context.Context, appID, roomID string) ([]*ktv_entity.KtvUser, error)
	GetApplyAudiencesByRoomID(ctx context.Context, appID, roomID string) ([]*ktv_entity.KtvUser, error)
}

type SeatRepo interface {
	//create or update
	Save(ctx context.Context, seat *ktv_entity.KtvSeat) error

	//get
	GetSeatByRoomIDSeatID(ctx context.Context, roomID string, seatID int) (*ktv_entity.KtvSeat, error)
	GetSeatsByRoomID(ctx context.Context, roomID string) ([]*ktv_entity.KtvSeat, error)
}

type SongRepo interface {
	List(ctx context.Context, roomID string) ([]*ktv_entity.KtvSong, error)
	Push(ctx context.Context, roomID string, song *ktv_entity.KtvSong) error
	UpdateTop(ctx context.Context, roomID string, song *ktv_entity.KtvSong) error
	Pop(ctx context.Context, roomID string) (*ktv_entity.KtvSong, error)
	LIndex(ctx context.Context, roomID string, index int64) (*ktv_entity.KtvSong, error)
}

type SongInfoRepo interface {
	GetPresetSong(ctx context.Context) ([]ktv_entity.PresetSong, error)
}
