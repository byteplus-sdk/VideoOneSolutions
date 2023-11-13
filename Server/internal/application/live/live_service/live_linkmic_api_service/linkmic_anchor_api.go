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
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_inform_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_core_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_util"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/inform"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli/lock"
	"github.com/byteplus/VideoOneServer/internal/pkg/uuid"
)

func AnchorInvite(ctx context.Context, appID string, r *live_linker_models.ApiAnchorInviteReq) (*live_linker_models.ApiAnchorInviteResp, error) {
	linkerService := live_linkmic_core_service.GetLinkerService()
	inviterRoomLinkerInfo, err := linkerService.GetRoomLinkmicInfo(ctx, &live_linker_models.GetRoomLinkmicInfoReq{
		RoomID: r.InviterRoomID,
	})
	if err != nil {
		logs.CtxError(ctx, "get room linker info failed,error:%s", err)
		return nil, err
	}

	inviteeRoomLinkerInfo, err := linkerService.GetRoomLinkmicInfo(ctx, &live_linker_models.GetRoomLinkmicInfoReq{
		RoomID: r.InviteeRoomID,
	})
	if err != nil {
		logs.CtxError(ctx, "get room linker info failed,error:%s", err)
		return nil, err
	}

	rules := []Rule{
		NewAnchorLinkmicInviterSceneRule(ctx, inviterRoomLinkerInfo),
		NewAnchorLinkmicInviteeSceneRule(ctx, inviteeRoomLinkerInfo),
		NewAnchorLinkmicRoomStateRule(ctx, appID, r.InviteeRoomID),
		NewAnchorLinkmicRoomStateRule(ctx, appID, r.InviterRoomID),
	}
	err = CheckRules(ctx, rules)
	if err != nil {
		logs.CtxError(ctx, "check rule failed,error:%s", err)
		return nil, err
	}

	_, err = GetInviting(ctx, r.InviteeRoomID, r.InviteeUserID)
	if !custom_error.Equal(err, custom_error.ErrRecordNotFound) {
		logs.CtxError(ctx, "get inviting failed,error:%s", err)
		return nil, custom_error.ErrSceneInviteeAlreadyInvited
	}
	_, err = GetInvited(ctx, r.InviterRoomID, r.InviterUserID)
	if !custom_error.Equal(err, custom_error.ErrRecordNotFound) {
		logs.CtxError(ctx, "get inviting failed,error:%s", err)
		return nil, custom_error.ErrSceneInviteeAlreadyInvited
	}

	ok := SetInviting(ctx, r.InviterRoomID, r.InviterUserID, live_linker_models.LinkerSceneAnchor)
	if !ok {
		return nil, custom_error.ErrorUserCantInviteForInviting
	}
	ok = SetInvited(ctx, r.InviteeRoomID, r.InviteeUserID, live_linker_models.LinkerSceneAnchor)
	if !ok {
		return nil, custom_error.ErrorUserCantInviteForInviting
	}

	linkerID := uuid.GetUUID()
	_, err = linkerService.AnchorInvite(ctx, appID, &live_linker_models.AnchorInviteReq{
		LinkerID:      linkerID,
		BizID:         public.BizIDLive,
		InviterRoomID: r.InviterRoomID,
		InviterUserID: r.InviterUserID,
		InviteeRoomID: r.InviteeRoomID,
		InviteeUserID: r.InviteeUserID,
	})
	if err != nil {
		logs.CtxError(ctx, "anchor invite failed,error:%s", err)
		return nil, err
	}

	inviter, _ := live_util.GetReturnUser(ctx, appID, r.InviterRoomID, r.InviterUserID)
	informData := &live_inform_service.InformAnchorLinkmicInvite{
		Inviter:  inviter,
		LinkerID: linkerID,
		Extra:    r.Extra,
	}
	informer := inform.GetInformService(appID)
	informer.UnicastRoomUser(ctx, r.InviteeRoomID, r.InviteeUserID, live_inform_service.OnAnchorLinkmicInvite, informData)

	resp := &live_linker_models.ApiAnchorInviteResp{
		LinkerID: linkerID,
	}
	return resp, nil
}

func AnchorReply(ctx context.Context, appID string, r *live_linker_models.ApiAnchorReplyReq) (*live_linker_models.ApiAnchorReplyResp, error) {
	defer func() {
		DelInviting(ctx, r.InviterRoomID, r.InviterUserID)
		DelInvited(ctx, r.InviteeRoomID, r.InviteeUserID)
	}()

	appInfoService := login_service.GetAppInfoService()
	appInfo, _ := appInfoService.ReadAppInfoByAppId(ctx, appID)

	if r.LinkerID == "" {
		return nil, custom_error.ErrInput
	}

	ok, lt := lock.LockRoom(ctx, r.InviterRoomID)
	if !ok {
		return nil, custom_error.ErrLockRedis
	}
	defer lock.UnLockRoom(ctx, r.InviterRoomID, lt)

	linkerService := live_linkmic_core_service.GetLinkerService()
	inviterRoomLinkerInfo, err := linkerService.GetRoomLinkmicInfo(ctx, &live_linker_models.GetRoomLinkmicInfoReq{
		RoomID: r.InviterRoomID,
	})
	if err != nil {
		logs.CtxError(ctx, "get room linker info failed,error:%s", err)
		return nil, err
	}

	inviteeRoomLinkerInfo, err := linkerService.GetRoomLinkmicInfo(ctx, &live_linker_models.GetRoomLinkmicInfoReq{
		RoomID: r.InviteeRoomID,
	})
	if err != nil {
		logs.CtxError(ctx, "get room linker info failed,error:%s", err)
		return nil, err
	}

	rules := []Rule{
		NewAnchorLinkmicInviterSceneRule(ctx, inviterRoomLinkerInfo),
		NewAnchorLinkmicInviteeSceneRule(ctx, inviteeRoomLinkerInfo),
	}
	err = CheckRules(ctx, rules)
	if err != nil {
		logs.CtxError(ctx, "check rule failed,error:%s", err)
		return nil, err
	}

	replyResp, err := linkerService.AnchorReply(ctx, &live_linker_models.AnchorReplyReq{
		AppID:         appID,
		LinkerID:      r.LinkerID,
		BizID:         public.BizIDLive,
		InviterRoomID: r.InviterRoomID,
		InviterUserID: r.InviterUserID,
		InviteeRoomID: r.InviteeRoomID,
		InviteeUserID: r.InviteeUserID,
		Reply:         r.Reply,
	})
	if err != nil {
		logs.CtxError(ctx, "anchor invite failed,error:%s", err)
		return nil, err
	}

	resp := &live_linker_models.ApiAnchorReplyResp{}

	invitee, _ := live_util.GetReturnUser(ctx, appID, r.InviteeRoomID, r.InviteeUserID)
	informData := &live_inform_service.InformAnchorLinkmicReply{
		Invitee:    invitee,
		LinkerID:   r.LinkerID,
		ReplyType:  r.Reply,
		LinkedTime: replyResp.Linker.LinkedTime,
	}
	if r.Reply == live_linker_models.ReplyAccept {
		userList, _ := getLinkedUserList(ctx, appID, r.InviteeRoomID)
		roomRepo := live_facade.GetRoomRepo()
		inviterRtcRoomID := roomRepo.GetRoomRtcRoomID(ctx, r.InviterRoomID)
		inviteeRtcRoomID := roomRepo.GetRoomRtcRoomID(ctx, r.InviteeRoomID)
		resp.RtcRoomID = inviterRtcRoomID
		resp.RtcToken = live_util.GenToken(resp.RtcRoomID, r.InviteeUserID, appInfo.AppId, appInfo.AppKey)
		resp.RtcUserList = userList
		resp.LinkedTime = replyResp.Linker.LinkedTime
		informData.RtcRoomID = inviteeRtcRoomID
		informData.RtcToken = live_util.GenToken(informData.RtcRoomID, r.InviterUserID, appInfo.AppId, appInfo.AppKey)
		informData.RtcUserList = userList

		linkmicStatusInformData := &live_inform_service.InformLinkmicStatus{
			LinkmicStatus: live_return_models.UserLinkmicStatusAnchorLinkmicLinked,
		}
		informer := inform.GetInformService(appID)
		informer.BroadcastRoom(ctx, r.InviterRoomID, live_inform_service.OnLinkmicStatus, linkmicStatusInformData)
		informer.BroadcastRoom(ctx, r.InviteeRoomID, live_inform_service.OnLinkmicStatus, linkmicStatusInformData)

	}
	informer := inform.GetInformService(appID)
	informer.UnicastRoomUser(ctx, r.InviterRoomID, r.InviterUserID, live_inform_service.OnAnchorLinkmicReply, informData)

	return resp, nil
}

func AnchorFinish(ctx context.Context, appID string, r *live_linker_models.ApiAnchorFinishReq) (*live_linker_models.ApiAnchorFinishResp, error) {
	linkerService := live_linkmic_core_service.GetLinkerService()
	finishResp, err := linkerService.AnchorFinish(ctx, &live_linker_models.AnchorFinishReq{
		LinkerID: r.LinkerID,
		BizID:    public.BizIDLive,
	})
	if err != nil {
		logs.CtxError(ctx, "anchor invite failed,error:%s", err)
		return nil, err
	}

	roomRepo := live_facade.GetRoomRepo()
	informer := inform.GetInformService(appID)

	for _, user := range finishResp.UserList {
		informData := &live_inform_service.InformAnchorLinkmicFinish{
			RtcRoomID: roomRepo.GetRoomRtcRoomID(ctx, user.RoomID),
		}

		informer.BroadcastRoom(ctx, roomRepo.GetRoomRtcRoomID(ctx, user.RoomID), live_inform_service.OnAnchorLinkmicFinish, informData)
		linkmicStatusInformData := &live_inform_service.InformLinkmicStatus{
			LinkmicStatus: live_return_models.UserLinkmicStatusUnknown,
		}
		informer.BroadcastRoom(ctx, user.RoomID, live_inform_service.OnLinkmicStatus, linkmicStatusInformData)
	}

	resp := &live_linker_models.ApiAnchorFinishResp{}
	return resp, nil

}
