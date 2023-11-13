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

package live_linker_models

import (
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
)

type ApiAudienceInitReq struct {
	HostRoomID string `json:"host_room_id"`
	HostUserID string `json:"host_user_id"`
}

type ApiAudienceInitResp struct {
}

type ApiAudienceInviteReq struct {
	HostRoomID     string `json:"host_room_id"`
	HostUserID     string `json:"host_user_id"`
	AudienceRoomID string `json:"audience_room_id"`
	AudienceUserID string `json:"audience_user_id"`
	Extra          string `json:"extra"`
}

type ApiAudienceInviteResp struct {
	LinkerID string `json:"linker_id"`
}

type ApiAudienceReplyReq struct {
	LinkerID       string `json:"linker_id"`
	BizID          string `json:"biz_id"`
	HostRoomID     string `json:"host_room_id"`
	HostUserID     string `json:"host_user_id"`
	AudienceRoomID string `json:"audience_room_id"`
	AudienceUserID string `json:"audience_user_id"`
	Reply          int    `json:"reply"`
}

type ApiAudienceReplyResp struct {
	LinkerID       string                     `json:"linker_id"`
	RtcRoomID      string                     `json:"rtc_room_id"`
	RtcToken       string                     `json:"rtc_token"`
	LinkedUserList []*live_return_models.User `json:"linked_user_list"`
}

type ApiAudienceApplyReq struct {
	HostRoomID     string `json:"host_room_id"`
	HostUserID     string `json:"host_user_id"`
	AudienceRoomID string `json:"audience_room_id"`
	AudienceUserID string `json:"audience_user_id"`
	Extra          string `json:"extra"`
}

type ApiAudienceApplyResp struct {
	LinkerID string `json:"linker_id"`
}

type ApiAudiencePermitReq struct {
	LinkerID       string `json:"linker_id d    "`
	HostRoomID     string `json:"host_room_id"`
	HostUserID     string `json:"host_user_id"`
	AudienceRoomID string `json:"audience_room_id"`
	AudienceUserID string `json:"audience_user_id"`
	Permit         int    `json:"reply"`
}

type ApiAudiencePermitResp struct {
	LinkerID       string                     `json:"linker_id"`
	RtcRoomID      string                     `json:"rtc_room_id"`
	RtcToken       string                     `json:"rtc_token"`
	LinkedUserList []*live_return_models.User `json:"linked_user_list"`
}

type ApiAudienceLeaveReq struct {
	LinkerID       string `json:"linker_id"`
	HostRoomID     string `json:"host_room_id"`
	HostUserID     string `json:"host_user_id"`
	AudienceRoomID string `json:"audience_room_id"`
	AudienceUserID string `json:"audience_user_id"`
}

type ApiAudienceCancelReq struct {
	HostRoomID     string `json:"host_room_id"`
	HostUserID     string `json:"host_user_id"`
	AudienceRoomID string `json:"audience_room_id"`
	AudienceUserID string `json:"audience_user_id"`
	LinkerID       string `json:"linker_id"`
}

type ApiAudienceLeaveResp struct {
	LinkerID string `json:"linker_id"`
}

type ApiAudienceKickReq struct {
	HostRoomID     string `json:"host_room_id"`
	HostUserID     string `json:"host_user_id"`
	AudienceRoomID string `json:"audience_room_id"`
	AudienceUserID string `json:"audience_user_id"`
}

type ApiAudienceKickResp struct {
	LinkerID string `json:"linker_id"`
}

type ApiAudienceFinishReq struct {
	HostRoomID string `json:"host_room_id"`
	HostUserID string `json:"host_user_id"`
	OnlyActive bool   `json:"-"`
}

type ApiAudienceFinishResp struct {
}

type ApiAnchorInviteReq struct {
	InviterRoomID string `json:"inviter_room_id"`
	InviterUserID string `json:"inviter_user_id"`
	InviteeRoomID string `json:"invitee_room_id"`
	InviteeUserID string `json:"invitee_user_id"`
	Extra         string `json:"extra"`
}

type ApiAnchorInviteResp struct {
	LinkerID string `json:"linker_id"`
}

type ApiAnchorReplyReq struct {
	LinkerID      string `json:"linker_id"`
	InviterRoomID string `json:"inviter_room_id"`
	InviterUserID string `json:"inviter_user_id"`
	InviteeRoomID string `json:"invitee_room_id"`
	InviteeUserID string `json:"invitee_user_id"`
	Reply         int    `json:"reply"`
}

type ApiAnchorReplyResp struct {
	RtcRoomID   string                     `json:"rtc_room_id"`
	RtcToken    string                     `json:"rtc_token"`
	RtcUserList []*live_return_models.User `json:"rtc_user_list"`
	LinkedTime  time.Time                  `json:"linked_time"`
}

type ApiAnchorFinishReq struct {
	LinkerID string `json:"linker_id"`
	RoomID   string `json:"room_id"`
	UserID   string `json:"user_id"`
}

type ApiAnchorFinishResp struct {
}

type ApiActiveRoomLinkmicInfoResp struct {
	Linkers      []*live_entity.LiveLinker
	LinkedUsers  map[string][]*live_entity.LiveLinker
	ApplyUsers   map[string][]*live_entity.LiveLinker
	InviteUsers  map[string][]*live_entity.LiveLinker
	IsAnchorLink bool
	IsLinked     bool
}
