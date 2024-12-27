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

package drama_model

import "time"

type Drama struct {
	ID               int       `json:"-" gorm:"column:id"`
	Title            string    `json:"title" gorm:"column:title"`
	Description      string    `json:"description" gorm:"column:description"`
	DramaID          string    `json:"drama_id" gorm:"column:drama_id"`
	CoverUrl         string    `json:"cover_url" gorm:"column:cover_url"`
	TotalNumber      int       `json:"total_number" gorm:"column:total_number"`
	FreeNumber       int       `json:"free_number" gorm:"column:free_number"`
	VideoOrientation int       `json:"video_orientation" gorm:"column:video_orientation"`
	CreateTime       time.Time `json:"-" gorm:"column:create_time"`
	UpdateTime       time.Time `json:"-" gorm:"column:update_time"`
}

type DramaUnlock struct {
	ID         int       `json:"-" gorm:"column:id"`
	UserID     string    `json:"user_id" gorm:"column:user_id"`
	DramaID    string    `json:"drama_id" gorm:"column:drama_id"`
	VIDList    string    `json:"vid_list" gorm:"column:vid_list"`
	CreateTime time.Time `json:"-" gorm:"column:create_time"`
	UpdateTime time.Time `json:"-" gorm:"column:update_time"`
}

type VideoComments struct {
	ID         int64     `gorm:"column:id"`
	Vid        string    `gorm:"column:vid"`
	Content    string    `gorm:"column:content"`
	Name       string    `gorm:"column:name"`
	CreateTime time.Time `gorm:"column:create_time"`
	UpdateTime time.Time `gorm:"column:update_time"`
}
