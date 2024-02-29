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

type KtvSong struct {
	ID            int64     `gorm:"column:id" json:"id"`
	RoomID        string    `gorm:"column:room_id" json:"room_id"`
	SongID        string    `gorm:"column:song_id" json:"song_id"`
	SongName      string    `gorm:"column:song_name" json:"song_name"`
	OwnerUserID   string    `gorm:"column:owner_user_id" json:"owner_user_id"`
	OwnerUserName string    `gorm:"column:owner_user_name" json:"owner_user_name"`
	SongDuration  float64   `gorm:"column:song_duration" json:"song_duration"`
	CoverUrl      string    `gorm:"column:cover_url" json:"cover_url"`
	Status        int       `gorm:"column:status" json:"status"`
	CreateTime    time.Time `gorm:"column:create_time" json:"create_time"`
	UpdateTime    time.Time `gorm:"column:update_time" json:"update_time"`
}

type PresetSong struct {
	Artist      string    `json:"artist" gorm:"column:artist"`
	CoverUrl    string    `json:"cover_url" gorm:"column:cover_url"`
	Duration    int       `json:"duration" gorm:"column:duration"`
	SongLrcUrl  string    `json:"song_lrc_url" gorm:"column:song_lrc_url"`
	SongFileUrl string    `json:"song_file_url" gorm:"column:song_file_url"`
	SongId      int       `json:"song_id" gorm:"column:id"`
	Name        string    `json:"song_name" gorm:"column:name"`
	CreateTime  time.Time `gorm:"column:create_time" json:"create_time"`
	UpdateTime  time.Time `gorm:"column:update_time" json:"update_time"`
}
