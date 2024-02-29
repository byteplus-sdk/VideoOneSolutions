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

package ktv_entity

import "time"

type KtvUser struct {
	ID             int64     `gorm:"column:id" json:"id"`
	AppID          string    `gorm:"column:app_id" json:"app_id"`
	RoomID         string    `gorm:"column:room_id" json:"room_id"`
	UserID         string    `gorm:"column:user_id" json:"user_id"`
	UserName       string    `gorm:"column:user_name" json:"user_name"`
	UserRole       int       `gorm:"column:user_role" json:"user_role"`
	NetStatus      int       `gorm:"column:net_status" json:"-"`
	InteractStatus int       `gorm:"column:interact_status" json:"status"`
	SeatID         int       `gorm:"column:seat_id" json:"-"`
	Mic            int       `gorm:"column:mic" json:"mic"`
	JoinTime       int64     `gorm:"column:join_time" json:"join_time"`
	LeaveTime      int64     `gorm:"column:leave_time" json:"leave_time"`
	CreateTime     time.Time `gorm:"column:create_time" json:"-"`
	UpdateTime     time.Time `gorm:"column:update_time" json:"-"`
	DeviceID       string    `gorm:"column:device_id" json:"-"`
}
