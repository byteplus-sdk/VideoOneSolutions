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

package live_linkmic_api_service

import (
	"context"
	"errors"
	"time"

	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli"
	"github.com/go-redis/redis/v8"
)

const (
	invitingPrefix = "live:inviting:"
	invitedPrefix  = "live:invited:"
	applyingPrefix = "live:applying"
)

const expireTime = 10 * time.Second

func SetInviting(ctx context.Context, roomID, userID string, scene int) bool {
	ok, err := redis_cli.Client.SetNX(ctx, getInvitingKey(roomID, userID), scene, expireTime).Result()
	if err != nil {
		return false
	}
	return ok
}

func GetInviting(ctx context.Context, roomID, userID string) (int, error) {
	scene, err := redis_cli.Client.Get(ctx, getInvitingKey(roomID, userID)).Int64()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return 0, custom_error.ErrRecordNotFound
		}
		return 0, custom_error.InternalError(err)
	}
	return int(scene), nil
}

func DelInviting(ctx context.Context, roomID, userID string) {
	redis_cli.Client.Del(ctx, getInvitingKey(roomID, userID))
}

func SetInvited(ctx context.Context, roomID, userID string, scene int) bool {
	ok, err := redis_cli.Client.SetNX(ctx, getInvitedKey(roomID, userID), scene, expireTime).Result()
	if err != nil {
		return false
	}
	return ok
}

func GetInvited(ctx context.Context, roomID, userID string) (int, error) {
	scene, err := redis_cli.Client.Get(ctx, getInvitedKey(roomID, userID)).Int64()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return 0, custom_error.ErrRecordNotFound
		}
		return 0, custom_error.InternalError(err)
	}
	return int(scene), nil
}

func DelInvited(ctx context.Context, roomID, userID string) {
	redis_cli.Client.Del(ctx, getInvitedKey(roomID, userID))
}

func getInvitingKey(roomID, userID string) string {
	return invitingPrefix + roomID + userID
}

func getInvitedKey(roomID, userID string) string {
	return invitedPrefix + roomID + userID
}

func SetAudienceApplying(ctx context.Context, roomID, userID string, scene int) bool {
	ok, err := redis_cli.Client.SetNX(ctx, getAudienceApplyingKey(roomID, userID), scene, expireTime).Result()
	if err != nil {
		return false
	}
	return ok
}

func GetAudienceApplying(ctx context.Context, roomID, userID string) (int, error) {
	scene, err := redis_cli.Client.Get(ctx, getAudienceApplyingKey(roomID, userID)).Int64()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return 0, custom_error.ErrRecordNotFound
		}
		return 0, custom_error.InternalError(err)
	}
	return int(scene), nil
}

func DelAudienceApplying(ctx context.Context, roomID, userID string) {
	redis_cli.Client.Del(ctx, getAudienceApplyingKey(roomID, userID))
}

func getAudienceApplyingKey(roomID, userID string) string {
	return applyingPrefix + roomID + userID
}
