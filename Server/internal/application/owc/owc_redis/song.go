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

package owc_redis

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_entity"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli"
	"github.com/go-redis/redis/v8"
)

type OwcSongSingUser struct {
	LeaderUser    string
	SuccentorUser string
}

const (
	keyRoomSongListPrefix = "owc:vccontrol:room_song_list:"
	keyRoomSongPrefix     = "owc:vccontrol:room_song:"
	LeaderSing            = "LeaderSing"
	SuccentorUser         = "SuccentorUser"
)

type RedisSongRepo struct{}

func (repo *RedisSongRepo) List(ctx context.Context, roomID string) ([]*owc_entity.OwcSong, error) {
	strSongs, err := redis_cli.Client.LRange(ctx, getSongListKey(roomID), 0, -1).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return nil, nil
		}
		return nil, err
	}
	rs := make([]*owc_entity.OwcSong, 0)
	for _, strSong := range strSongs {
		song := &owc_entity.OwcSong{}
		err = json.Unmarshal([]byte(strSong), song)
		if err != nil {
			return nil, err
		}
		rs = append(rs, song)
	}
	return rs, nil

}
func (repo *RedisSongRepo) Push(ctx context.Context, roomID string, song *owc_entity.OwcSong) error {
	data, _ := json.Marshal(song)
	err := redis_cli.Client.RPush(ctx, getSongListKey(roomID), data).Err()
	if err != nil {
		return err
	}
	redis_cli.Client.Expire(ctx, getSongListKey(roomID), expireTime)
	return nil
}

func (repo *RedisSongRepo) UpdateTop(ctx context.Context, roomID string, song *owc_entity.OwcSong) error {
	data, _ := json.Marshal(song)
	err := redis_cli.Client.LSet(ctx, getSongListKey(roomID), 0, data).Err()
	if err != nil {
		return err
	}
	redis_cli.Client.Expire(ctx, getSongListKey(roomID), expireTime)
	return nil
}
func (repo *RedisSongRepo) Pop(ctx context.Context, roomID string) (*owc_entity.OwcSong, error) {
	data, err := redis_cli.Client.LPop(ctx, getSongListKey(roomID)).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return nil, nil
		}
		return nil, err
	}
	rs := &owc_entity.OwcSong{}
	err = json.Unmarshal([]byte(data), rs)
	if err != nil {
		return nil, err
	}
	return rs, nil
}
func (repo *RedisSongRepo) LIndex(ctx context.Context, roomID string, index int64) (*owc_entity.OwcSong, error) {
	data, err := redis_cli.Client.LIndex(ctx, getSongListKey(roomID), index).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return nil, nil
		}
		return nil, err
	}
	rs := &owc_entity.OwcSong{}
	err = json.Unmarshal([]byte(data), rs)
	if err != nil {
		return nil, err
	}
	return rs, nil
}

func (repo *RedisSongRepo) SetUser(ctx context.Context, roomID string, song *owc_entity.OwcSong, userId string) error {
	redis_cli.Client.HSet(ctx, getSongKey(song.OwnerUserID, song.SongID), LeaderSing, song.OwnerUserID)
	redis_cli.Client.HSet(ctx, getSongKey(song.OwnerUserID, song.SongID), SuccentorUser, userId)
	return nil

}

func (repo *RedisSongRepo) GetUser(ctx context.Context, roomID string, song *owc_entity.OwcSong) (*OwcSongSingUser, error) {
	leaderUser, err := redis_cli.Client.HGet(ctx, getSongKey(song.OwnerUserID, song.SongID), LeaderSing).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			leaderUser = ""
		} else {
			return nil, err
		}

	}
	succentorUser, err := redis_cli.Client.HGet(ctx, getSongKey(song.OwnerUserID, song.SongID), SuccentorUser).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			succentorUser = ""
		} else {
			return nil, err
		}

	}
	owcSongSingUser := &OwcSongSingUser{
		LeaderUser:    leaderUser,
		SuccentorUser: succentorUser,
	}
	return owcSongSingUser, nil

}

func (repo *RedisSongRepo) DelUser(ctx context.Context, roomID string, song *owc_entity.OwcSong) {
	redis_cli.Client.Del(ctx, getSongKey(song.OwnerUserID, song.SongID))

}

func getSongListKey(roomID string) string {
	return keyRoomSongListPrefix + roomID
}

func getSongKey(userID, songID string) string {
	return keyRoomSongPrefix + userID + ":" + songID
}
