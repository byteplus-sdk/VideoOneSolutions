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

package ktv_redis

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_entity"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli"
	"github.com/go-redis/redis/v8"
)

const (
	keyRoomSongListPrefix = "ktv:vccontrol:room_song_list:"
)

type RedisSongRepo struct{}

func (repo *RedisSongRepo) List(ctx context.Context, roomID string) ([]*ktv_entity.KtvSong, error) {
	strSongs, err := redis_cli.Client.LRange(ctx, getSongListKey(roomID), 0, -1).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return nil, nil
		}
		return nil, err
	}
	rs := make([]*ktv_entity.KtvSong, 0)
	for _, strSong := range strSongs {
		song := &ktv_entity.KtvSong{}
		err = json.Unmarshal([]byte(strSong), song)
		if err != nil {
			return nil, err
		}
		rs = append(rs, song)
	}
	return rs, nil
}
func (repo *RedisSongRepo) Push(ctx context.Context, roomID string, song *ktv_entity.KtvSong) error {
	data, _ := json.Marshal(song)
	err := redis_cli.Client.RPush(ctx, getSongListKey(roomID), data).Err()
	if err != nil {
		return err
	}
	redis_cli.Client.Expire(ctx, getSongListKey(roomID), expireTime)
	return nil
}

func (repo *RedisSongRepo) UpdateTop(ctx context.Context, roomID string, song *ktv_entity.KtvSong) error {
	data, _ := json.Marshal(song)
	err := redis_cli.Client.LSet(ctx, getSongListKey(roomID), 0, data).Err()
	if err != nil {
		return err
	}
	redis_cli.Client.Expire(ctx, getSongListKey(roomID), expireTime)
	return nil
}
func (repo *RedisSongRepo) Pop(ctx context.Context, roomID string) (*ktv_entity.KtvSong, error) {
	data, err := redis_cli.Client.LPop(ctx, getSongListKey(roomID)).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return nil, nil
		}
		return nil, err
	}
	rs := &ktv_entity.KtvSong{}
	err = json.Unmarshal([]byte(data), rs)
	if err != nil {
		return nil, err
	}
	return rs, nil
}
func (repo *RedisSongRepo) LIndex(ctx context.Context, roomID string, index int64) (*ktv_entity.KtvSong, error) {
	data, err := redis_cli.Client.LIndex(ctx, getSongListKey(roomID), index).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return nil, nil
		}
		return nil, err
	}
	rs := &ktv_entity.KtvSong{}
	err = json.Unmarshal([]byte(data), rs)
	if err != nil {
		return nil, err
	}
	return rs, nil
}

func getSongListKey(roomID string) string {
	return keyRoomSongListPrefix + roomID
}
