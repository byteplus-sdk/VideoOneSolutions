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
	keyGenerateUserID = "rtc_demo:login:generate_user_id:"
)

func SetGeneratedUserID(ctx context.Context, userID int64) {
	redis_cli.Client.Set(ctx, keyGenerateUserID, userID, 0)
}

func DelGeneratedUserID(ctx context.Context) {
	redis_cli.Client.Del(ctx, keyGenerateUserID)
}

func GetGeneratedUserID(ctx context.Context) (int64, error) {
	userID, err := redis_cli.Client.Get(ctx, keyGenerateUserID).Int64()
	if errors.Is(err, redis.Nil) {
		return 0, nil
	}
	return userID, err
}
