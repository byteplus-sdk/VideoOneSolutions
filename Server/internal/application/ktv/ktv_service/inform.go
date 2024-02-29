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

package ktv_service

import . "github.com/byteplus/VideoOneServer/internal/pkg/inform"

const (
	OnAudienceJoinRoom  InformEvent = "ktvOnAudienceJoinRoom"
	OnAudienceLeaveRoom InformEvent = "ktvOnAudienceLeaveRoom"
	OnFinishLive        InformEvent = "ktvOnFinishLive"
	OnInviteInteract    InformEvent = "ktvOnInviteInteract"
	OnApplyInteract     InformEvent = "ktvOnApplyInteract"
	OnInviteResult      InformEvent = "ktvOnInviteResult"
	OnJoinInteract      InformEvent = "ktvOnJoinInteract"
	OnFinishInteract    InformEvent = "ktvOnFinishInteract"
	OnMessage           InformEvent = "ktvOnMessage"
	OnMediaStatusChange InformEvent = "ktvOnMediaStatusChange"
	OnMediaOperate      InformEvent = "ktvOnMediaOperate"
	OnSeatStatusChange  InformEvent = "ktvOnSeatStatusChange"
	OnClearUser         InformEvent = "ktvOnClearUser"
	OnStartSing         InformEvent = "ktvOnStartSing"
	OnFinishSing        InformEvent = "ktvOnFinishSing"
	OnRequestSong       InformEvent = "ktvOnRequestSong"
)

type InformGeneral struct {
	RoomID   string `json:"room_id,omitempty"`
	UserID   string `json:"user_id,omitempty"`
	UserName string `json:"user_name,omitempty"`
}

type InformJoinRoom struct {
	UserInfo      *User `json:"user_info"`
	AudienceCount int   `json:"audience_count"`
}

type InformLeaveRoom struct {
	UserInfo      *User `json:"user_info"`
	AudienceCount int   `json:"audience_count"`
}

type InformFinishLive struct {
	RoomID string `json:"room_id"`
	Type   int    `json:"type"`
}

type InformInviteInteract struct {
	HostInfo *User `json:"host_info"`
	SeatID   int   `json:"seat_id"`
}

type InformApplyInteract struct {
	UserInfo *User `json:"user_info"`
	SeatID   int   `json:"seat_id"`
}

type InformInviteResult struct {
	UserInfo *User `json:"user_info"`
	Reply    int   `json:"reply"`
}

type InformJoinInteract struct {
	UserInfo *User `json:"user_info"`
	SeatID   int   `json:"seat_id"`
}

type InformFinishInteract struct {
	UserInfo *User `json:"user_info"`
	SeatID   int   `json:"seat_id"`
	Type     int   `json:"type"`
}

type InformMessage struct {
	UserInfo *User  `json:"user_info"`
	Message  string `json:"message"`
}

type InformUpdateMediaStatus struct {
	UserInfo *User `json:"user_info"`
	SeatID   int   `json:"seat_id"`
	Mic      int   `json:"mic"`
}

type InformMediaOperate struct {
	Mic int `json:"mic"`
}

type InformSeatStatusChange struct {
	SeatID int `json:"seat_id"`
	Type   int `json:"type"`
}

type InformStartSing struct {
	Song *Song `json:"song"`
}

type InformFinishSing struct {
	Score    float64 `json:"score"`
	NextSong *Song   `json:"next_song"`
	CurSong  *Song   `json:"cur_song"`
}

type InformRequestSong struct {
	Song      *Song `json:"song"`
	SongCount int   `json:"song_count"`
}

type InformClearUser struct {
	RoomID string `json:"room_id"`
	UserID string `json:"user_id"`
}
