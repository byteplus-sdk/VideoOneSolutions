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

package live_entity

import (
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_room_models"
)

type LiveRoomUserExtra struct {
	Width  int `json:"width"`
	Height int `json:"height"`
}

type LiveRoomUser struct {
	ID         int64     `gorm:"column:id" json:"id"`
	AppID      string    `gorm:"column:app_id" json:"app_id"`
	RoomID     string    `gorm:"column:room_id" json:"room_id"`
	UserID     string    `gorm:"column:user_id" json:"user_id"`
	UserName   string    `gorm:"column:user_name" json:"user_name"`
	UserRole   int       `gorm:"column:user_role" json:"user_role"`
	Status     int       `gorm:"column:status" json:"status"`
	Mic        int       `gorm:"column:mic" json:"mic"`
	Camera     int       `gorm:"column:camera" json:"camera"`
	CreateTime time.Time `gorm:"column:create_time" json:"create_time"`
	UpdateTime time.Time `gorm:"column:update_time" json:"update_time"`
	Extra      string    `gorm:"column:extra" json:"extra"`
}

func (u *LiveRoomUser) Join() {
	u.Status = live_room_models.RoomUserStatusStart
}

func (u *LiveRoomUser) Leave() {
	u.Status = live_room_models.RoomUserStatusFinish
}
