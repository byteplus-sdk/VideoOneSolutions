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

package vod_entity

import "time"

type VideoInfo struct {
	ID                      int64     `gorm:"column:id"`
	Vid                     string    `gorm:"column:vid"`
	VideoType               int       `gorm:"column:video_type"`
	AntiScreenshotAndRecord int       `gorm:"column:anti_screenshot_and_record"`
	SupportSmartSubtitle    int       `gorm:"column:support_smart_subtitle"`
	CreateTime              time.Time `gorm:"column:create_time"`
	UpdateTime              time.Time `gorm:"column:update_time"`
}

type VideoComments struct {
	ID         int64     `gorm:"column:id"`
	Vid        string    `gorm:"column:vid"`
	Content    string    `gorm:"column:content"`
	Name       string    `gorm:"column:name"`
	CreateTime time.Time `gorm:"column:create_time"`
	UpdateTime time.Time `gorm:"column:update_time"`
}
