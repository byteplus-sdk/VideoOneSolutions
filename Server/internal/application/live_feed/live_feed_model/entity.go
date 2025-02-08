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

package live_feed_model

import "time"

type LiveFeed struct {
	ID         int       `json:"-" gorm:"column:id"`
	HostName   string    `json:"host_name" gorm:"column:host_name"`
	RoomName   string    `json:"room_name" gorm:"column:room_name"`
	RoomDesc   string    `json:"room_desc" gorm:"column:room_desc"`
	CoverUrl   string    `json:"cover_url" gorm:"column:cover_url"`
	RoomID     string    `json:"room_id" gorm:"column:room_id"`
	RTCAppID   string    `json:"rtc_app_id" gorm:"-"`
	StreamID   string    `json:"-" gorm:"column:stream_id"`
	CreateTime time.Time `json:"-" gorm:"column:create_time"`
	UpdateTime time.Time `json:"-" gorm:"column:update_time"`
}
