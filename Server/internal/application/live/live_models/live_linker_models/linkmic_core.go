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
	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
)

type AudienceInitReq struct {
	LinkerID   string `json:"linker_id"`
	BizID      string `json:"biz_id"`
	HostRoomID string `json:"host_room_id"`
	HostUserID string `json:"host_user_id"`
}

type AudienceInitResp struct {
	Linker *live_entity.LiveLinker
}

type AudienceInviteReq struct {
	AppID          string `json:"app_id"`
	LinkerID       string `json:"linker_id"`
	BizID          string `json:"biz_id"`
	HostRoomID     string `json:"host_room_id"`
	HostUserID     string `json:"host_user_id"`
	AudienceRoomID string `json:"audience_room_id"`
	AudienceUserID string `json:"audience_user_id"`
}

type AudienceInviteResp struct {
	Linker *live_entity.LiveLinker
}

type AudienceReplyReq struct {
	LinkerID       string `json:"linker_id"`
	BizID          string `json:"biz_id"`
	HostRoomID     string `json:"host_room_id"`
	HostUserID     string `json:"host_user_id"`
	AudienceRoomID string `json:"audience_room_id"`
	AudienceUserID string `json:"audience_user_id"`
	Reply          int    `json:"reply"`
}

type AudienceReplyResp struct {
	Linker *live_entity.LiveLinker
}

type AudienceApplyReq struct {
	AppID          string `json:"app_id"`
	LinkerID       string `json:"linker_id"`
	BizID          string `json:"biz_id"`
	HostRoomID     string `json:"host_room_id"`
	HostUserID     string `json:"host_user_id"`
	AudienceRoomID string `json:"audience_room_id"`
	AudienceUserID string `json:"audience_user_id"`
}

type AudienceApplyResp struct {
	Linker *live_entity.LiveLinker
}

type AudiencePermitReq struct {
	LinkerID       string `json:"linker_id"`
	BizID          string `json:"biz_id"`
	HostRoomID     string `json:"host_room_id"`
	HostUserID     string `json:"host_user_id"`
	AudienceRoomID string `json:"audience_room_id"`
	AudienceUserID string `json:"audience_user_id"`
	Permit         int    `json:"reply"`
}

type AudiencePermitResp struct {
	Linker *live_entity.LiveLinker
}

type AudienceLeaveReq struct {
	LinkerID       string `json:"linker_id"`
	BizID          string `json:"biz_id"`
	HostRoomID     string `json:"host_room_id"`
	HostUserID     string `json:"host_user_id"`
	AudienceRoomID string `json:"audience_room_id"`
	AudienceUserID string `json:"audience_user_id"`
}

type AudienceLeaveResp struct {
	Linker *live_entity.LiveLinker
}

type AudienceKickReq struct {
	LinkerID       string `json:"linker_id"`
	BizID          string `json:"biz_id"`
	HostRoomID     string `json:"host_room_id"`
	HostUserID     string `json:"host_user_id"`
	AudienceRoomID string `json:"audience_room_id"`
	AudienceUserID string `json:"audience_user_id"`
}

type AudienceKickResp struct {
	Linker *live_entity.LiveLinker
}

type AudienceFinishReq struct {
	LinkerID   string `json:"linker_id"`
	BizID      string `json:"biz_id"`
	HostRoomID string `json:"host_room_id"`
	HostUserID string `json:"host_user_id"`
	OnlyActive bool   `json:"-"`
}

type AudienceFinishResp struct {
	Linkers []*live_entity.LiveLinker
}

type AnchorInviteReq struct {
	LinkerID      string `json:"linker_id"`
	BizID         string `json:"biz_id"`
	InviterRoomID string `json:"inviter_room_id"`
	InviterUserID string `json:"inviter_user_id"`
	InviteeRoomID string `json:"invitee_room_id"`
	InviteeUserID string `json:"invitee_user_id"`
}

type AnchorInviteResp struct {
	Linker *live_entity.LiveLinker
}

type AnchorReplyReq struct {
	AppID         string `json:"app_id"`
	LinkerID      string `json:"linker_id"`
	BizID         string `json:"biz_id"`
	InviterRoomID string `json:"inviter_room_id"`
	InviterUserID string `json:"inviter_user_id"`
	InviteeRoomID string `json:"invitee_room_id"`
	InviteeUserID string `json:"invitee_user_id"`
	Reply         int    `json:"reply"`
}

type AnchorReplyResp struct {
	Linker *live_entity.LiveLinker
}

type AnchorFinishReq struct {
	LinkerID string `json:"linker_id"`
	BizID    string `json:"biz_id"`
}

type AnchorFinishResp struct {
	Linker   *live_entity.LiveLinker
	UserList []*live_entity.LiveRoomUser
}

type GetRoomLinkmicInfoReq struct {
	RoomID string `json:"room_id"`
}

type GetRoomLinkmicInfoResp struct {
	Linkers      []*live_entity.LiveLinker
	LinkedUsers  map[string][]*live_entity.LiveLinker
	ApplyUsers   map[string][]*live_entity.LiveLinker
	InviteUsers  map[string][]*live_entity.LiveLinker
	IsAnchorLink bool
	IsLinked     bool
}
