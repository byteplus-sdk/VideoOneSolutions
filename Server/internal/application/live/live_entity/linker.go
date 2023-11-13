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

type LiveLinker struct {
	ID           int64     `gorm:"column:id" json:"id"`
	AppID        string    `gorm:"column:app_id" json:"app_id"`
	LinkerID     string    `gorm:"column:linker_id" json:"linker_id"`
	FromRoomID   string    `gorm:"column:from_room_id" json:"from_room_id"`
	FromUserID   string    `gorm:"column:from_user_id" json:"from_user_id"`
	ToRoomID     string    `gorm:"column:to_room_id" json:"to_room_id"`
	ToUserID     string    `gorm:"column:to_user_id" json:"to_user_id"`
	BizID        string    `gorm:"column:biz_id" json:"biz_id"`
	Scene        int       `gorm:"column:scene" json:"scene"`
	LinkerStatus int       `gorm:"column:linker_status" json:"linker_status"`
	CreateTime   time.Time `gorm:"column:create_time" json:"create_time"`
	LinkingTime  time.Time `gorm:"column:linking_time" json:"linking_time"`
	LinkedTime   time.Time `gorm:"column:linked_time" json:"linked_time"`
	Status       int       `gorm:"column:status" json:"status"`
	Extra        string    `gorm:"column:extra" json:"extra"`
}

func (l *LiveLinker) Finish() {
	l.Status = live_room_models.LinkerStatusFinish
}
