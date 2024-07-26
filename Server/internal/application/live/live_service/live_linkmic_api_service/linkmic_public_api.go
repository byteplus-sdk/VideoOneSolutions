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

package live_linkmic_api_service

import (
	"context"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_linker_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_core_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

func FinishHostLinkmic(ctx context.Context, appID, roomID, userID string) error {
	roomLinkmicInfo, err := GetActiveRoomLinkmicInfo(ctx, roomID)
	if err != nil {
		logs.CtxError(ctx, "get room linkmic info failed,error:%s", err)
		return err
	}

	if !roomLinkmicInfo.IsLinked {
		return nil
	}

	if roomLinkmicInfo.IsAnchorLink {
		AnchorFinish(ctx, appID, &live_linker_models.ApiAnchorFinishReq{
			LinkerID: roomLinkmicInfo.Linkers[0].LinkerID,
			RoomID:   roomID,
			UserID:   userID,
		})
	} else {
		AudienceFinish(ctx, appID, &live_linker_models.ApiAudienceFinishReq{
			HostRoomID: roomID,
			HostUserID: userID,
		})
	}

	return nil
}

// audience leave room
func FinishAudienceLinkmic(ctx context.Context, appID, roomID, userID string) error {
	roomLinkmicInfo, err := GetActiveRoomLinkmicInfo(ctx, roomID)
	if err != nil {
		logs.CtxError(ctx, "get room linkmic info failed,error:%s", err)
		return err
	}

	if len(roomLinkmicInfo.LinkedUsers) == 0 {
		return nil
	}

	if !roomLinkmicInfo.IsAnchorLink {
		for _, linker := range roomLinkmicInfo.LinkedUsers[roomID] {
			if linker.FromUserID == userID {
				AudienceLeave(ctx, appID, &live_linker_models.ApiAudienceLeaveReq{
					LinkerID:       linker.LinkerID,
					HostRoomID:     linker.ToRoomID,
					HostUserID:     linker.ToUserID,
					AudienceRoomID: roomID,
					AudienceUserID: userID,
				})
			}
		}
	}

	return nil
}

func GetActiveRoomLinkmicInfo(ctx context.Context, roomID string) (*live_linker_models.ApiActiveRoomLinkmicInfoResp, error) {
	ls := live_linkmic_core_service.GetLinkerService()
	roomLinkmicInfo, err := ls.GetRoomLinkmicInfo(ctx, &live_linker_models.GetRoomLinkmicInfoReq{
		RoomID: roomID,
	})

	if err != nil {
		return nil, err
	}
	resp := &live_linker_models.ApiActiveRoomLinkmicInfoResp{}
	resp.Linkers = roomLinkmicInfo.Linkers
	resp.LinkedUsers = roomLinkmicInfo.LinkedUsers
	resp.InviteUsers = roomLinkmicInfo.InviteUsers
	resp.ApplyUsers = roomLinkmicInfo.ApplyUsers
	resp.IsAnchorLink = roomLinkmicInfo.IsAnchorLink
	resp.IsLinked = roomLinkmicInfo.IsLinked
	return resp, nil
}
