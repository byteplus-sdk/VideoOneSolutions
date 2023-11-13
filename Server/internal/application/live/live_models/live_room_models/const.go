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

package live_room_models

// room
const (
	RoomStatusPrepare = iota
	RoomStatusStart
	RoomStatusFinish
)

// room user
const (
	RoomUserRoleAudience = 1
	RoomUserRoleHost     = 2
)

// linker
const (
	LinkerStatusPrepare = iota
	LinkerStatusFinish
)

const (
	RoomUserStatusPrepare = iota
	RoomUserStatusStart
	RoomUserStatusFinish
)

const (
	RoomFinishTypeNormal  = 1
	RoomFinishTypeTimeout = 2
)

const RoomFinishTimeOut = "room_timeout"

type Message struct {
	MessageType int `json:"type"`
}

type RoomExtra struct {
	Likes    int `json:"likes"`
	Gifts    int `json:"gifts"`
	Viewers  int `json:"viewers"`
	Duration int `json:"duration"`
}

const (
	MessageTypeNormal = 1
	MessageTypeGift   = 2
	MessageTypeLike   = 3
)
