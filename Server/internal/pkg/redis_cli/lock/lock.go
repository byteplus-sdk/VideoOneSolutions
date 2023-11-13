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

package lock

import (
	"context"
	"errors"
	"time"

	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli"
	"github.com/go-redis/redis/v8"
)

const (
	lockTimeout    = 1000 // milliseconds
	tryPeriod      = 10 * time.Millisecond
	lockExpiration = 2 * time.Second
)

const (
	csLocalUserIDAssignKey = "cs:rtc_demo:local:userid:assign"
)

func getDistributedLockKey(roomID string) string {
	return "c:vccontrol:roomlock:" + roomID
}

func CheckRoomLockStatus(ctx context.Context, roomID string) (bool, error) {
	err := redis_cli.Client.Get(ctx, getDistributedLockKey(roomID)).Err()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return false, nil
		}
		return false, err
	}
	return true, nil
}

func LockRoom(ctx context.Context, roomID string) (bool, int64) {
	logs.CtxInfo(ctx, "roomID: %s try to lock", roomID)
	return mustGetLock(ctx, getDistributedLockKey(roomID), 2*time.Second)
}

func UnLockRoom(ctx context.Context, roomID string, lt int64) error {
	logs.CtxInfo(ctx, "roomID: %s try to unlock", roomID)
	return freeLock(ctx, getDistributedLockKey(roomID), lt)
}

func LockLocalUserIDAssign(ctx context.Context) (bool, int64) {
	return mustGetLock(ctx, csLocalUserIDAssignKey, lockExpiration)
}

func UnLockLocalUserIDAssign(ctx context.Context, lt int64) error {
	return freeLock(ctx, csLocalUserIDAssignKey, lt)
}

// getLock attemps to get and locking a lock. It returns whether the lock is free and the expiring time of the lock.
func getLock(ctx context.Context, key string) (bool, int64) {
	// lt timestamp microsecond
	lt := time.Now().Add(lockTimeout*time.Millisecond).UnixNano() / 1000
	lock, _ := redis_cli.Client.SetNX(ctx, key, lt, lockTimeout*time.Millisecond).Result()
	if lock {
		return true, lt
	}
	return false, 0
}

// mustGetLock tries to get the lock every 10 ms util obtaining the lock or util timeout.
func mustGetLock(ctx context.Context, key string, timeout time.Duration) (bool, int64) {
	tryTime := timeout / tryPeriod
	for i := 0; i < int(tryTime); i++ {
		l, t := getLock(ctx, key)
		if l {
			return l, t
		}
		time.Sleep(tryPeriod)
	}
	return false, 0
}

// freeLock checks whether the lock is expiring. If not, let it be free.
func freeLock(ctx context.Context, key string, lt int64) error {
	if lt > time.Now().UnixNano()/1000 {
		return redis_cli.Client.Del(ctx, key).Err()
	}
	return nil
}
