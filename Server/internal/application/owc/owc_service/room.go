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

package owc_service

import (
	"context"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_db"
	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_entity"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/token"
)

type Room struct {
	*owc_entity.OwcRoom
	AudienceCount int `json:"audience_count"`
	isDirty       bool
}

func (r *Room) IsDirty() bool {
	return r.isDirty
}

func (r *Room) SetIsDirty(isDirty bool) {
	r.isDirty = isDirty
}

func (r *Room) SetUpdateTime(time time.Time) {
	r.UpdateTime = time
	r.isDirty = true
}

func (r *Room) GetDbRoom() *owc_entity.OwcRoom {
	return r.OwcRoom
}

func (r *Room) GetCreateTime() time.Time {
	return r.CreateTime
}

func (r *Room) Start() {
	r.Status = owc_db.RoomStatusStart
	r.isDirty = true
}

func (r *Room) Finish() {
	r.Status = owc_db.RoomStatusFinish
	r.FinishTime = time.Now().UnixNano() / 1e6
	r.isDirty = true
}

func (r *Room) GetRoomID() string {
	return r.RoomID
}

func (r *Room) GetAppID() string {
	return r.AppID
}

func (r *Room) GetHostUserID() string {
	return r.HostUserID
}

func (r *Room) GenerateToken(ctx context.Context, userID string) string {
	param := &token.GenerateParam{
		AppID:        config.Configs().RTCAppID,
		AppKey:       config.Configs().RTCAppKey,
		RoomID:       r.RoomID,
		UserID:       userID,
		ExpireAt:     7 * 24 * 3600,
		CanPublish:   true,
		CanSubscribe: true,
	}
	rtcToken, err := token.GenerateToken(param)
	if err != nil {
		logs.CtxError(ctx, "generate token failed,error:%s", err)
	}
	return rtcToken
}
