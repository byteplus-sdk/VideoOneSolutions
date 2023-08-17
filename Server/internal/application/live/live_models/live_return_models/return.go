/*
 * Copyright 2023 CloudWeGo Authors
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

package live_return_models

import "time"

const (
	UserLinkmicStatusUnknown                 = 0
	UserLinkmicStatusAudienceLinkmicInviting = 1
	UserLinkmicStatusAudienceLinkmicApply    = 2
	UserLinkmicStatusAudienceLinkmicLinked   = 3
	UserLinkmicStatusAnchorLinkmicLinked     = 4
)

type Room struct {
	LiveAppID         string            `json:"live_app_id"`
	RtcAppID          string            `json:"rtc_app_id"`
	RoomID            string            `json:"room_id"`
	RoomName          string            `json:"room_name"`
	HostUserID        string            `json:"host_user_id"`
	HostUserName      string            `json:"host_user_name"`
	Status            int               `json:"status"`
	AudienceCount     int               `json:"audience_count"`
	StreamPullUrlList map[string]string `json:"stream_pull_url_list"`
	Extra             string            `json:"extra"`
}

type User struct {
	RoomID        string    `json:"room_id"`
	UserID        string    `json:"user_id"`
	UserName      string    `json:"user_name"`
	UserRole      int       `json:"user_role"`
	Mic           int       `json:"mic"`
	Camera        int       `json:"camera"`
	Extra         string    `json:"extra"`
	LinkmicStatus int       `json:"linkmic_status"`
	LinkmicTime   time.Time `json:"linkmic_time"`
}
