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

package live_linkmic_api_service

import (
	"context"
	"errors"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_linker_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type Rule interface {
	Check(ctx context.Context) error
}

func CheckRules(ctx context.Context, rules []Rule) error {
	for _, rule := range rules {
		if err := rule.Check(ctx); err != nil {
			return err
		}
	}
	return nil
}

type AudienceLinkmicHostSceneRule struct {
	RoomLinkmicInfo *live_linker_models.GetRoomLinkmicInfoResp `json:"room_linker_info"`
}

func NewAudienceLinkmicHostSceneRule(ctx context.Context, roomLinkerInfo *live_linker_models.GetRoomLinkmicInfoResp) Rule {
	return &AudienceLinkmicHostSceneRule{
		RoomLinkmicInfo: roomLinkerInfo,
	}
}

func (r *AudienceLinkmicHostSceneRule) Check(ctx context.Context) error {
	if r.RoomLinkmicInfo == nil {
		return custom_error.InternalError(errors.New("room linker info empty"))
	}
	isAudienceLinkmic := true
	isAnchorLinkmic := false
	isLinkedUserCountLimit := false
	userCount := 0
	for _, linker := range r.RoomLinkmicInfo.Linkers {
		if linker.Scene == live_linker_models.LinkerSceneAudience && linker.LinkerStatus == live_linker_models.LinkerStatusAudienceLinked {
			isAudienceLinkmic = true
			userCount += 1
			if userCount > 6 {
				isLinkedUserCountLimit = true
			}
		}
		if linker.Scene == live_linker_models.LinkerSceneAnchor && linker.LinkerStatus == live_linker_models.LinkerStatusAnchorLinked {
			isAnchorLinkmic = true
			return custom_error.ErrSceneAudienceNotAllowedOrLinked
		}

	}

	if !isAudienceLinkmic || isAnchorLinkmic {
		return custom_error.ErrSceneAudienceNotAllowedOrLinked
	}

	if isLinkedUserCountLimit {
		logs.CtxError(ctx, "linked user count reach limit")
		return custom_error.ErrorReachMicOnLimit
	}

	return nil
}

type AnchorLinkmicInviterSceneRule struct {
	RoomLinkmicInfo *live_linker_models.GetRoomLinkmicInfoResp `json:"room_linker_info"`
}

func NewAnchorLinkmicInviterSceneRule(ctx context.Context, roomLinkmicInfo *live_linker_models.GetRoomLinkmicInfoResp) Rule {
	return &AnchorLinkmicInviterSceneRule{
		RoomLinkmicInfo: roomLinkmicInfo,
	}
}

func (r *AnchorLinkmicInviterSceneRule) Check(ctx context.Context) error {
	if r.RoomLinkmicInfo == nil {
		return custom_error.InternalError(errors.New("room linker info empty"))
	}
	for _, linker := range r.RoomLinkmicInfo.Linkers {
		if linker.Scene == live_linker_models.LinkerSceneAudience && linker.LinkerStatus == live_linker_models.LinkerStatusAudienceLinked {
			return custom_error.ErrSceneReplyInviteRoomHasAudience
		}
		if linker.Scene == live_linker_models.LinkerSceneAnchor && linker.LinkerStatus == live_linker_models.LinkerStatusAnchorLinked {
			return custom_error.ErrSceneReplyRoomLinked
		}
	}
	return nil
}

type AnchorLinkmicInviteeSceneRule struct {
	RoomLinkmicInfo *live_linker_models.GetRoomLinkmicInfoResp `json:"room_linker_info"`
}

func NewAnchorLinkmicInviteeSceneRule(ctx context.Context, roomLinkerInfo *live_linker_models.GetRoomLinkmicInfoResp) Rule {
	return &AnchorLinkmicInviteeSceneRule{
		RoomLinkmicInfo: roomLinkerInfo,
	}
}

func (r *AnchorLinkmicInviteeSceneRule) Check(ctx context.Context) error {
	if r.RoomLinkmicInfo == nil {
		return custom_error.InternalError(errors.New("room linker info empty"))
	}

	for _, linker := range r.RoomLinkmicInfo.Linkers {
		if linker.Scene == live_linker_models.LinkerSceneAudience && linker.LinkerStatus == live_linker_models.LinkerStatusAudienceLinked {
			return custom_error.ErrSceneReplyInviteRoomHasAudience
		}
		if linker.Scene == live_linker_models.LinkerSceneAnchor && linker.LinkerStatus == live_linker_models.LinkerStatusAnchorLinked {
			return custom_error.ErrSceneReplyRoomLinked
		}
	}
	return nil
}

type AnchorLinkmicRoomStateRule struct {
	AppID  string `json:"app_id"`
	RoomID string `json:"room_id"`
}

func NewAnchorLinkmicRoomStateRule(_ context.Context, appID, roomID string) Rule {
	return &AnchorLinkmicRoomStateRule{
		AppID:  appID,
		RoomID: roomID,
	}
}

func (r *AnchorLinkmicRoomStateRule) Check(ctx context.Context) error {
	if r.RoomID == "" {
		return custom_error.InternalError(errors.New("room_id is empty"))
	}

	roomRepo := live_facade.GetRoomRepo()
	_, err := roomRepo.GetActiveRoom(ctx, r.AppID, r.RoomID)
	if err != nil {
		if custom_error.Equal(err, custom_error.ErrRecordNotFound) {
			return custom_error.ErrRoomNotExist
		}
		return custom_error.InternalError(err)
	}
	return nil
}

type LinkmicUserStateRule struct {
	AppID  string `json:"app_id"`
	RoomID string `json:"room_id"`
	UserID string `json:"user_id"`
}

func NewLinkmicUserStateRule(_ context.Context, appID, roomID, userID string) Rule {
	return &LinkmicUserStateRule{
		AppID:  appID,
		RoomID: roomID,
		UserID: userID,
	}
}

func (r *LinkmicUserStateRule) Check(ctx context.Context) error {
	if r.RoomID == "" {
		return custom_error.InternalError(errors.New("room_id is empty"))
	}
	if r.UserID == "" {
		return custom_error.InternalError(errors.New("user_id is empty"))
	}

	userRepo := live_facade.GetRoomUserRepo()
	_, err := userRepo.GetActiveUser(ctx, r.AppID, r.RoomID, r.UserID)
	if err != nil {
		if custom_error.Equal(err, custom_error.ErrRecordNotFound) {
			return custom_error.ErrUserNotExist
		}
		return custom_error.InternalError(err)
	}
	return nil
}
