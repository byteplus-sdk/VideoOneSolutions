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

package live_room_service

import (
	"context"
	"encoding/json"
	"errors"
	"math"
	"strconv"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_room_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli/general"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli/lock"
	"github.com/byteplus/VideoOneServer/internal/pkg/uuid"
)

const (
	retryDelay    = 8 * time.Millisecond
	maxRetryDelay = 128 * time.Millisecond
	maxRetryNum   = 10
)

const (
	roomLength = 8
)

var roomFactoryClient *RoomFactory

type RoomFactory struct {
}

func GetRoomFactory() *RoomFactory {
	if roomFactoryClient == nil {
		roomFactoryClient = &RoomFactory{}
	}
	return roomFactoryClient
}

func (rf *RoomFactory) NewRoom(ctx context.Context, appID, roomName, hostUserID, hostUserName string, liveCdnAppId string) (*live_entity.LiveRoom, error) {
	roomID, err := ApplyRoomIDWithRetry(ctx, appID)
	if err != nil {
		return nil, err
	}

	streamID := uuid.GetUUID()
	roomExtra := live_room_models.RoomExtra{Likes: 0, Viewers: 0, Gifts: 0}
	roomExtraStr, err := json.Marshal(roomExtra)
	if err != nil {
		return nil, err
	}
	room := &live_entity.LiveRoom{
		LiveAppID:     liveCdnAppId,
		RtcAppID:      appID,
		RoomID:        roomID,
		RoomName:      roomName,
		HostUserID:    hostUserID,
		HostUserName:  hostUserName,
		StreamID:      streamID,
		Status:        live_room_models.RoomStatusPrepare,
		CreateTime:    time.Now(),
		AudienceCount: 0,
		Extra:         string(roomExtraStr),
	}
	return room, nil
}

func (rf *RoomFactory) NewRoomUser(ctx context.Context, appID, roomID, userID, userName string, userRole int) *live_entity.LiveRoomUser {
	extra := &live_entity.LiveRoomUserExtra{
		Width:  0,
		Height: 0,
	}
	extraString, _ := json.Marshal(extra)
	roomUser := &live_entity.LiveRoomUser{
		AppID:      appID,
		RoomID:     roomID,
		UserID:     userID,
		UserName:   userName,
		UserRole:   userRole,
		Mic:        1,
		Camera:     1,
		Status:     live_room_models.RoomUserStatusPrepare,
		Extra:      string(extraString),
		CreateTime: time.Now(),
	}

	return roomUser

}

func ApplyRoomIDWithRetry(ctx context.Context, appID string) (string, error) {
	roomID, err := generateRoomID(ctx, appID, public.BizIDLive)
	for i := 0; roomID == 0 && i <= maxRetryNum; i++ {
		backOff := time.Duration(int64(math.Pow(2, float64(i)))) * retryDelay
		if backOff > maxRetryDelay {
			backOff = maxRetryDelay
		}
		time.Sleep(backOff)
		roomID, err = generateRoomID(ctx, appID, public.BizIDLive)
	}
	if roomID == 0 {
		logs.CtxError(ctx, "failed to generate roomID, err: %s", err)
		return "", custom_error.InternalError(errors.New("make room err"))
	}
	return strconv.FormatInt(roomID, 10), nil
}

func generateRoomID(ctx context.Context, appID, bizID string) (int64, error) {
	ok, lt := lock.LockGenerateRoomID(ctx)
	if !ok {
		return 0, custom_error.ErrLockRedis
	}
	defer lock.UnlockGenerateRoomID(ctx, lt)

	roomID, err := general.GetGeneratedRoomID(ctx, bizID)
	if err != nil {
		return 0, custom_error.InternalError(err)
	}

	baseline := int64(math.Pow10(roomLength))
	minRoomID := int64(math.Pow10(roomLength - 1))

	if roomID == 0 {
		roomID = time.Now().Unix() % baseline
	} else {
		roomID = (roomID + 1) % baseline
	}

	if roomID < minRoomID {
		roomID += minRoomID
	}

	general.SetGeneratedRoomID(ctx, bizID, roomID)
	roomRepo := live_facade.GetRoomRepo()
	_, err = roomRepo.GetActiveRoom(ctx, appID, strconv.FormatInt(roomID, 10))
	if err != nil {
		if custom_error.Equal(err, custom_error.ErrRecordNotFound) {
			return roomID, nil
		}
		return 0, custom_error.InternalError(err)

	}

	return 0, custom_error.ErrRoomAlreadyExist
}
