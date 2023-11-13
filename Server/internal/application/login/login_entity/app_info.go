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

package login_entity

import "time"

type AppInfo struct {
	ID              int64     `gorm:"column:id" json:"id"`
	AppId           string    `gorm:"column:app_id" json:"app_id"`
	AppKey          string    `gorm:"column:app_key" json:"app_key"`
	AccessKey       string    `gorm:"column:access_key" json:"access_key"`
	SecretAccessKey string    `gorm:"column:secret_access_key" json:"secret_access_key"`
	VodSpace        string    `gorm:"column:vod_space" json:"vod_space"`
	LiveStreamKey   string    `gorm:"column:live_stream_key" json:"live_stream_key"`
	LivePushDomain  string    `gorm:"column:live_push_domain" json:"live_push_domain"`
	LivePullDomain  string    `gorm:"column:live_pull_domain" json:"live_pull_domain"`
	LiveAppName     string    `gorm:"column:live_app_name" json:"live_app_name"`
	CreateTime      time.Time `gorm:"column:create_time" json:"create_time"`
	UpdateTime      time.Time `gorm:"column:update_time" json:"update_time"`
}
