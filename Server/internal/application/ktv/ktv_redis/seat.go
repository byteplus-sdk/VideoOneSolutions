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
	"strconv"

	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_entity"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli"
	"github.com/go-redis/redis/v8"
)

const (
	keyRoomSeatPrefix = "ktv:vccontrol:room_seat:"
)

type RedisSeatRepo struct{}

func (repo *RedisSeatRepo) Save(ctx context.Context, seat *ktv_entity.KtvSeat) error {
	data, _ := json.Marshal(seat)
	err := redis_cli.Client.HSet(ctx, roomSeatKey(seat.RoomID), strconv.Itoa(seat.SeatID), data).Err()
	if err != nil {
		return err
	}
	redis_cli.Client.Expire(ctx, roomSeatKey(seat.RoomID), expireTime)
	return nil
}

func (repo *RedisSeatRepo) GetSeatByRoomIDSeatID(ctx context.Context, roomID string, seatID int) (*ktv_entity.KtvSeat, error) {
	data, err := redis_cli.Client.HGet(ctx, roomSeatKey(roomID), strconv.Itoa(seatID)).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return nil, nil
		}
		return nil, err
	}
	rs := &ktv_entity.KtvSeat{}
	err = json.Unmarshal([]byte(data), rs)
	if err != nil {
		return nil, err
	}
	return rs, nil
}

func (repo *RedisSeatRepo) GetSeatsByRoomID(ctx context.Context, roomID string) ([]*ktv_entity.KtvSeat, error) {
	dataMap, err := redis_cli.Client.HGetAll(ctx, roomSeatKey(roomID)).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return nil, nil
		}
		return nil, err
	}

	res := make([]*ktv_entity.KtvSeat, 0)
	for _, data := range dataMap {
		rs := &ktv_entity.KtvSeat{}
		err = json.Unmarshal([]byte(data), rs)
		if err != nil {
			return nil, err
		}
		res = append(res, rs)
	}
	return res, nil
}

func roomSeatKey(roomID string) string {
	return keyRoomSeatPrefix + roomID
}
