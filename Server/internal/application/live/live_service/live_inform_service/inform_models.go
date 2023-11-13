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

package live_inform_service

import (
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/pkg/inform"
)

const (
	//room
	OnAudienceJoinRoom  inform.InformEvent = "liveOnAudienceJoinRoom"
	OnAudienceLeaveRoom inform.InformEvent = "liveOnAudienceLeaveRoom"
	OnFinishLive        inform.InformEvent = "liveOnFinishLive"
	//linkmic broadcast
	OnAudienceLinkmicJoin   inform.InformEvent = "liveOnAudienceLinkmicJoin"
	OnAudienceLinkmicLeave  inform.InformEvent = "liveOnAudienceLinkmicLeave"
	OnAudienceLinkmicCancel inform.InformEvent = "liveOnAudienceLinkmicCancel"
	OnAudienceLinkmicFinish inform.InformEvent = "liveOnAudienceLinkmicFinish"
	OnAnchorLinkmicFinish   inform.InformEvent = "liveOnAnchorLinkmicFinish"
	OnMediaChange           inform.InformEvent = "liveOnMediaChange"
	OnLinkmicStatus         inform.InformEvent = "liveOnLinkmicStatus"
	//linkmic unicast
	OnAudienceLinkmicInvite inform.InformEvent = "liveOnAudienceLinkmicInvite"
	OnAudienceLinkmicApply  inform.InformEvent = "liveOnAudienceLinkmicApply"
	OnAudienceLinkmicReply  inform.InformEvent = "liveOnAudienceLinkmicReply"
	OnAudienceLinkmicPermit inform.InformEvent = "liveOnAudienceLinkmicPermit"
	OnAudienceLinkmicKick   inform.InformEvent = "liveOnAudienceLinkmicKick"
	OnAnchorLinkmicInvite   inform.InformEvent = "liveOnAnchorLinkmicInvite"
	OnAnchorLinkmicReply    inform.InformEvent = "liveOnAnchorLinkmicReply"
	OnManageGuestMedia      inform.InformEvent = "liveOnManageGuestMedia"
	OnMessageSend           inform.InformEvent = "liveOnMessageSend"
)

type InformAudienceJoinRoom struct {
	AudienceUserID   string `json:"audience_user_id"`
	AudienceUserName string `json:"audience_user_name"`
	AudienceCount    int    `json:"audience_count"`
}

type InformAudienceLeaveRoom struct {
	AudienceUserID   string `json:"audience_user_id"`
	AudienceUserName string `json:"audience_user_name"`
	AudienceCount    int    `json:"audience_count"`
}

type InformFinishLive struct {
	RoomID string `json:"room_id"`
	Type   int    `json:"type"`
	Extra  string `json:"extra"`
}

type InformAudienceLinkmicJoin struct {
	RtcRoomID string                     `json:"rtc_room_id"`
	UserList  []*live_return_models.User `json:"user_list"`
	UserID    string                     `json:"user_id"`
}

type InformAudienceLinkmicLeave struct {
	RtcRoomID string                     `json:"rtc_room_id"`
	UserList  []*live_return_models.User `json:"user_list"`
	UserID    string                     `json:"user_id"`
}

type InformAudienceLinkmicCancel struct {
	RtcRoomID string `json:"rtc_room_id"`
	UserID    string `json:"user_id"`
}

type InformAudienceLinkmicFinish struct {
	RtcRoomID string `json:"rtc_room_id"`
}

type InformAnchorLinkmicFinish struct {
	RtcRoomID string `json:"rtc_room_id"`
}

type InformMediaChange struct {
	RoomID         string `json:"room_id"`
	UserID         string `json:"user_id"`
	Camera         int    `json:"camera"`
	Mic            int    `json:"mic"`
	OperatorUserID string `json:"operator_user_id"`
}

type InformAudienceLinkmicInvite struct {
	Inviter  *live_return_models.User `json:"inviter"`
	LinkerID string                   `json:"linker_id"`
	Extra    string                   `json:"extra"`
}

type InformUserMsg struct {
	User    *live_entity.LiveRoomUser `json:"user"`
	Message string                    `json:"message"`
}

type InformAudienceLinkmicApply struct {
	Applicant *live_return_models.User `json:"applicant"`
	LinkerID  string                   `json:"linker_id"`
	Extra     string                   `json:"extra"`
}

type InformAudienceLinkmicReply struct {
	Invitee     *live_return_models.User   `json:"invitee"`
	LinkerID    string                     `json:"linker_id"`
	ReplyType   int                        `json:"reply_type"`
	RtcRoomID   string                     `json:"rtc_room_id"`
	RtcToken    string                     `json:"rtc_token"`
	RtcUserList []*live_return_models.User `json:"rtc_user_list"`
}

type InformAudienceLinkmicPermit struct {
	LinkerID    string                     `json:"linker_id"`
	PermitType  int                        `json:"permit_type"`
	RtcRoomID   string                     `json:"rtc_room_id"`
	RtcToken    string                     `json:"rtc_token"`
	RtcUserList []*live_return_models.User `json:"rtc_user_list"`
}

type InformAudienceLinkmicKick struct {
	LinkerID  string `json:"linker_id"`
	RoomID    string `json:"room_id"`
	RtcRoomID string `json:"rtc_room_id"`
	UserID    string `json:"user_id"`
}

type InformAnchorLinkmicInvite struct {
	Inviter    *live_return_models.User `json:"inviter"`
	LinkerID   string                   `json:"linker_id"`
	Extra      string                   `json:"extra"`
	LinkedTime time.Time                `json:"linked_time"`
}

type InformAnchorLinkmicReply struct {
	Invitee     *live_return_models.User   `json:"invitee"`
	LinkerID    string                     `json:"linker_id"`
	ReplyType   int                        `json:"reply_type"`
	RtcRoomID   string                     `json:"rtc_room_id"`
	RtcToken    string                     `json:"rtc_token"`
	RtcUserList []*live_return_models.User `json:"rtc_user_list"`
	LinkedTime  time.Time                  `json:"linked_time"`
}

type InformManageGuestMedia struct {
	GuestRoomID string `json:"guest_room_id"`
	GuestUserID string `json:"guest_user_id"`
	Mic         int    `json:"mic"`
	Camera      int    `json:"camera"`
}

type InformLinkmicStatus struct {
	LinkmicStatus int `json:"linkmic_status"`
}
