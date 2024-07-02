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

type LiveRoom struct {
	ID                int64             `gorm:"column:id" json:"id"`
	RtcAppID          string            `gorm:"column:rtc_app_id" json:"rtc_app_id"`
	RoomID            string            `gorm:"column:room_id" json:"room_id"`
	RoomName          string            `gorm:"column:room_name" json:"room_name"`
	HostUserID        string            `gorm:"column:host_user_id" json:"host_user_id"`
	HostUserName      string            `gorm:"column:host_user_name" json:"host_user_name"`
	StreamID          string            `gorm:"column:stream_id" json:"stream_id"`
	Status            int               `gorm:"column:status" json:"status"`
	CreateTime        time.Time         `gorm:"column:create_time" json:"create_time"`
	UpdateTime        time.Time         `gorm:"column:update_time" json:"update_time"`
	StartTime         time.Time         `gorm:"column:start_time" json:"start_time"`
	FinishTime        time.Time         `gorm:"column:finish_time" json:"finish_time"`
	AudienceCount     int               `gorm:"-" json:"audience_count"`
	StreamPullUrlList map[string]string `gorm:"-" json:"stream_pull_url_list"`
	Extra             string            `gorm:"column:extra" json:"extra"`
}

func (r *LiveRoom) Start() {
	r.Status = live_room_models.RoomStatusStart
	r.StartTime = time.Now()
}

func (r *LiveRoom) Finish() {
	r.Status = live_room_models.RoomStatusFinish
	r.FinishTime = time.Now()
}

func (r *LiveRoom) IsFinished() bool {
	return r.Status == live_room_models.RoomStatusFinish
}
