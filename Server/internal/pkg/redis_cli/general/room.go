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

package general

import (
	"context"
	"errors"

	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli"
	"github.com/go-redis/redis/v8"
)

const (
	keyGenerateRoomID = "rtc_demo:generate_room_id:"
)

func SetGeneratedRoomID(ctx context.Context, bizID string, roomID int64) {
	redis_cli.Client.Set(ctx, keyGenerateRoomID+bizID, roomID, 0)
}

func GetGeneratedRoomID(ctx context.Context, bizID string) (int64, error) {
	roomID, err := redis_cli.Client.Get(ctx, keyGenerateRoomID+bizID).Int64()
	if errors.Is(err, redis.Nil) {
		return 0, nil
	}
	return roomID, err
}
