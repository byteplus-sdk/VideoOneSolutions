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

package login_implement

import (
	"context"
	"errors"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/login/login_entity"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli"
	"github.com/go-redis/redis/v8"
)

const (
	fieldUserID      = "user_id"
	fieldCreatedTime = "created_time"
	keyPrefixLogin   = "rtc_demo:login:login_token:"
	TokenExpiration  = 24 * 7 * time.Hour
)

type LoginTokenRepositoryImpl struct{}

func (impl *LoginTokenRepositoryImpl) Save(ctx context.Context, token *login_entity.LoginToken) error {
	key := redisKeyLogin(token.Token)

	redis_cli.Client.Expire(ctx, key, TokenExpiration)
	redis_cli.Client.HSet(ctx, key, fieldUserID, token.UserID)
	redis_cli.Client.HSet(ctx, key, fieldCreatedTime, token.CreateTime)
	return nil
}

func (impl *LoginTokenRepositoryImpl) ExistToken(ctx context.Context, token string) (bool, error) {
	key := redisKeyLogin(token)

	val, err := redis_cli.Client.Exists(ctx, key).Result()
	switch {
	case err == nil:
		return val == 1, nil
	case errors.Is(err, redis.Nil):
		return false, nil
	default:
		return false, err
	}
}

func (impl *LoginTokenRepositoryImpl) GetUserID(ctx context.Context, token string) string {
	r := redis_cli.Client.HGet(ctx, redisKeyLogin(token), fieldUserID).Val()
	logs.CtxInfo(ctx, "get login userID: %s", r)

	return r
}

func redisKeyLogin(token string) string {
	return keyPrefixLogin + token
}
