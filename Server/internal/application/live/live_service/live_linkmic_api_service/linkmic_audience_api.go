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
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"github.com/byteplus/VideoOneServer/internal/pkg/uuid"
)

func AudienceInvite(ctx context.Context, appID string, r *live_linker_models.ApiAudienceInviteReq) (*live_linker_models.ApiAudienceInviteResp, error) {
	linkerService := live_linkmic_core_service.GetLinkerService()
	hostRoomLinkerInfo, err := linkerService.GetRoomLinkmicInfo(ctx, &live_linker_models.GetRoomLinkmicInfoReq{
		RoomID: r.HostRoomID,
	})
	if err != nil {
		logs.CtxError(ctx, "get room linker info failed,error:%s", err)
		return nil, err
	}

	rules := []Rule{
		NewAudienceLinkmicHostSceneRule(ctx, hostRoomLinkerInfo),
	}
	err = CheckRules(ctx, rules)
	if err != nil {
		logs.CtxError(ctx, "check rule failed,error:%s", err)
		return nil, err
	}

	_, err = GetInvited(ctx, r.HostRoomID, r.HostUserID)
	if !custom_error.Equal(err, custom_error.ErrRecordNotFound) {
		logs.CtxError(ctx, "get inviting failed,error:%s", err)
		return nil, custom_error.ErrSceneAudienceHostAlreadyInvited
	}
	_, err = GetInviting(ctx, r.HostRoomID, r.HostUserID)
	if !custom_error.Equal(err, custom_error.ErrRecordNotFound) {
		logs.CtxError(ctx, "get inviting failed,error:%s", err)
		return nil, custom_error.ErrSceneRepeatInvite
	}

	ok := SetInviting(ctx, r.HostRoomID, r.HostUserID, live_linker_models.LinkerSceneAudience)
	if !ok {
		return nil, custom_error.ErrorUserCantInviteForInviting
	}
	ok = SetInvited(ctx, r.AudienceRoomID, r.AudienceUserID, live_linker_models.LinkerSceneAudience)
	if !ok {
		return nil, custom_error.ErrorUserCantInviteForInviting
	}
	linkerID := uuid.GetUUID()
	inviteResp, err := linkerService.AudienceInvite(ctx, &live_linker_models.AudienceInviteReq{
		AppID:          appID,
		LinkerID:       linkerID,
		BizID:          public.BizIDLive,
		HostRoomID:     r.HostRoomID,
		HostUserID:     r.HostUserID,
		AudienceRoomID: r.AudienceRoomID,
		AudienceUserID: r.AudienceUserID,
	})
	if err != nil {
		logs.CtxError(ctx, "invite failed,error:%s", err)
		return nil, err
	}

	inviter, _ := live_util.GetReturnUser(ctx, appID, r.HostRoomID, r.HostUserID)
	informData := &live_inform_service.InformAudienceLinkmicInvite{
		Inviter:  inviter,
		LinkerID: inviteResp.Linker.LinkerID,
		Extra:    r.Extra,
	}
	informer := inform.GetInformService(appID)
	informer.UnicastRoomUser(ctx, r.AudienceRoomID, r.AudienceUserID, live_inform_service.OnAudienceLinkmicInvite, informData)

	resp := &live_linker_models.ApiAudienceInviteResp{
		LinkerID: inviteResp.Linker.LinkerID,
	}
	return resp, nil
}

func AudienceApply(ctx context.Context, appID string, r *live_linker_models.ApiAudienceApplyReq) (*live_linker_models.ApiAudienceApplyResp, error) {
	defer func() {
		DelAudienceApplying(ctx, r.AudienceRoomID, r.AudienceUserID)
	}()
	linkerService := live_linkmic_core_service.GetLinkerService()
	hostRoomLinkerInfo, err := linkerService.GetRoomLinkmicInfo(ctx, &live_linker_models.GetRoomLinkmicInfoReq{
		RoomID: r.HostRoomID,
	})
	if err != nil {
		logs.CtxError(ctx, "get room linker info failed,error:%s", err)
		return nil, err
	}

	scene, err := GetInviting(ctx, r.HostRoomID, r.HostUserID)
	if err == nil && scene == live_linker_models.LinkerSceneAnchor {
		logs.CtxError(ctx, "host is inviting in  anchor linkmic")
		return nil, custom_error.ErrSceneInvitingConflict
	}
	scene, err = GetInvited(ctx, r.HostRoomID, r.HostUserID)
	if err == nil && scene == live_linker_models.LinkerSceneAnchor {
		logs.CtxError(ctx, "host is inviting in  anchor linkmic")
		return nil, custom_error.ErrSceneInvitingConflict
	}
	_, err = GetAudienceApplying(ctx, r.AudienceRoomID, r.AudienceUserID)
	if !custom_error.Equal(err, custom_error.ErrRecordNotFound) {
		logs.CtxError(ctx, "get applying failed,error:%s", err)
		return nil, custom_error.ErrUserLinked
	}
	ok := SetAudienceApplying(ctx, r.AudienceRoomID, r.AudienceUserID, live_linker_models.LinkerSceneAudience)
	if !ok {
		return nil, custom_error.ErrUserLinked
	}

	rules := []Rule{
		NewAudienceLinkmicHostSceneRule(ctx, hostRoomLinkerInfo),
	}
	err = CheckRules(ctx, rules)
	if err != nil {
		logs.CtxError(ctx, "check rule failed,error:%s", err)
		return nil, err
	}
	linkerID := uuid.GetUUID()
	applyResp, err := linkerService.AudienceApply(ctx, &live_linker_models.AudienceApplyReq{
		LinkerID:       linkerID,
		AppID:          appID,
		BizID:          public.BizIDLive,
		HostRoomID:     r.HostRoomID,
		HostUserID:     r.HostUserID,
		AudienceRoomID: r.AudienceRoomID,
		AudienceUserID: r.AudienceUserID,
	})
	if err != nil {
		logs.CtxError(ctx, "invite failed,error:%s", err)
		return nil, err
	}

	applicant, _ := live_util.GetReturnUser(ctx, appID, r.AudienceRoomID, r.AudienceUserID)
	informData := &live_inform_service.InformAudienceLinkmicApply{
		Applicant: applicant,
		LinkerID:  applyResp.Linker.LinkerID,
		Extra:     r.Extra,
	}
	informer := inform.GetInformService(appID)
	informer.UnicastRoomUser(ctx, r.HostRoomID, r.HostUserID, live_inform_service.OnAudienceLinkmicApply, informData)

	resp := &live_linker_models.ApiAudienceApplyResp{
		LinkerID: applyResp.Linker.LinkerID,
	}
	return resp, nil
}

func AudienceReply(ctx context.Context, appID string, r *live_linker_models.ApiAudienceReplyReq) (*live_linker_models.ApiAudienceReplyResp, error) {
	defer func() {
		DelInviting(ctx, r.HostRoomID, r.HostUserID)
		DelInvited(ctx, r.AudienceRoomID, r.AudienceUserID)
	}()
	linkerService := live_linkmic_core_service.GetLinkerService()
	hostRoomLinkerInfo, err := linkerService.GetRoomLinkmicInfo(ctx, &live_linker_models.GetRoomLinkmicInfoReq{
		RoomID: r.HostRoomID,
	})
	if err != nil {
		logs.CtxError(ctx, "get room linker info failed,error:%s", err)
		return nil, err
	}

	rules := []Rule{
		NewAudienceLinkmicHostSceneRule(ctx, hostRoomLinkerInfo),
		NewLinkmicUserStateRule(ctx, appID, r.AudienceUserID, r.AudienceUserID),
	}
	err = CheckRules(ctx, rules)
	if err != nil {
		logs.CtxError(ctx, "check rule failed,error:%s", err)
		return nil, err
	}

	replyResp, err := linkerService.AudienceReply(ctx, &live_linker_models.AudienceReplyReq{
		BizID:          public.BizIDLive,
		HostRoomID:     r.HostRoomID,
		HostUserID:     r.HostUserID,
		AudienceRoomID: r.AudienceRoomID,
		AudienceUserID: r.AudienceUserID,
		Reply:          r.Reply,
	})
	if err != nil {
		logs.CtxError(ctx, "invite failed,error:%s", err)
		return nil, err
	}

	invitee, _ := live_util.GetReturnUser(ctx, appID, r.AudienceRoomID, r.AudienceUserID)
	informData := &live_inform_service.InformAudienceLinkmicReply{
		Invitee:   invitee,
		LinkerID:  replyResp.Linker.LinkerID,
		ReplyType: r.Reply,
	}

	roomRepo := live_facade.GetRoomRepo()

	resp := &live_linker_models.ApiAudienceReplyResp{
		LinkerID:  replyResp.Linker.LinkerID,
		RtcRoomID: roomRepo.GetRoomRtcRoomID(ctx, replyResp.Linker.FromRoomID),
	}
	appInfoService := login_service.GetAppInfoService()
	appInfo, _ := appInfoService.ReadAppInfoByAppId(ctx, appID)

	informer := inform.GetInformService(appID)
	if r.Reply == live_linker_models.ReplyAccept {
		userList, _ := getLinkedUserList(ctx, appID, r.HostRoomID)
		informDataBroad := &live_inform_service.InformAudienceLinkmicJoin{
			RtcRoomID: roomRepo.GetRoomRtcRoomID(ctx, replyResp.Linker.FromRoomID),
			UserList:  userList,
			UserID:    r.AudienceUserID,
		}
		informer.BroadcastRoom(ctx, roomRepo.GetRoomRtcRoomID(ctx, replyResp.Linker.FromRoomID), live_inform_service.OnAudienceLinkmicJoin, informDataBroad)

		informData.RtcRoomID = roomRepo.GetRoomRtcRoomID(ctx, replyResp.Linker.FromRoomID)
		informData.RtcToken = live_util.GenToken(roomRepo.GetRoomRtcRoomID(ctx, replyResp.Linker.FromRoomID), r.HostUserID, appInfo.AppId, appInfo.AppKey)
		informData.RtcUserList = userList

		resp.LinkedUserList = userList
		resp.RtcToken = live_util.GenToken(roomRepo.GetRoomRtcRoomID(ctx, replyResp.Linker.FromRoomID), r.AudienceUserID, appInfo.AppId, appInfo.AppKey)

		if len(userList) == 2 {
			linkmicStatusInformData := &live_inform_service.InformLinkmicStatus{
				LinkmicStatus: live_return_models.UserLinkmicStatusAudienceLinkmicLinked,
			}
			informer.BroadcastRoom(ctx, r.HostRoomID, live_inform_service.OnLinkmicStatus, linkmicStatusInformData)
		}
	}

	informer.UnicastRoomUser(ctx, r.HostRoomID, r.HostUserID, live_inform_service.OnAudienceLinkmicReply, informData)

	return resp, nil
}

func AudiencePermit(ctx context.Context, appID string, r *live_linker_models.ApiAudiencePermitReq) (*live_linker_models.ApiAudiencePermitResp, error) {
	linkerService := live_linkmic_core_service.GetLinkerService()
	hostRoomLinkerInfo, err := linkerService.GetRoomLinkmicInfo(ctx, &live_linker_models.GetRoomLinkmicInfoReq{
		RoomID: r.HostRoomID,
	})
	if err != nil {
		logs.CtxError(ctx, "get room linker info failed,error:%s", err)
		return nil, err
	}

	appInfoService := login_service.GetAppInfoService()
	appInfo, _ := appInfoService.ReadAppInfoByAppId(ctx, appID)

	rules := []Rule{
		NewAudienceLinkmicHostSceneRule(ctx, hostRoomLinkerInfo),
	}
	err = CheckRules(ctx, rules)
	if err != nil {
		logs.CtxError(ctx, "check rule failed,error:%s", err)
		return nil, err
	}

	ok, lt := lock.LockRoom(ctx, r.HostRoomID)
	if !ok {
		return nil, custom_error.ErrLockRedis
	}
	defer lock.UnLockRoom(ctx, r.HostRoomID, lt)

	permitResp, err := linkerService.AudiencePermit(ctx, &live_linker_models.AudiencePermitReq{
		LinkerID:       r.LinkerID,
		BizID:          public.BizIDLive,
		HostRoomID:     r.HostRoomID,
		HostUserID:     r.HostUserID,
		AudienceRoomID: r.AudienceRoomID,
		AudienceUserID: r.AudienceUserID,
		Permit:         r.Permit,
	})
	if err != nil {
		logs.CtxError(ctx, "permit failed,error:%s", err)
		return nil, err
	}

	informData := &live_inform_service.InformAudienceLinkmicPermit{
		LinkerID:   permitResp.Linker.LinkerID,
		PermitType: r.Permit,
	}

	resp := &live_linker_models.ApiAudiencePermitResp{
		LinkerID: permitResp.Linker.LinkerID,
	}
	roomRepo := live_facade.GetRoomRepo()

	informer := inform.GetInformService(appID)
	rtcRoomID := roomRepo.GetRoomRtcRoomID(ctx, permitResp.Linker.FromRoomID)
	if r.Permit == live_linker_models.PermitAccept {
		userList, _ := getLinkedUserList(ctx, appID, r.HostRoomID)
		informDataBroad := &live_inform_service.InformAudienceLinkmicJoin{
			RtcRoomID: rtcRoomID,
			UserList:  userList,
			UserID:    r.AudienceUserID,
		}
		informer.BroadcastRoom(ctx, rtcRoomID, live_inform_service.OnAudienceLinkmicJoin, informDataBroad)

		informData.RtcRoomID = rtcRoomID
		informData.RtcToken = live_util.GenToken(rtcRoomID, r.AudienceUserID, appInfo.AppId, appInfo.AppKey)
		informData.RtcUserList = userList

		resp.LinkedUserList = userList
		resp.RtcToken = live_util.GenToken(rtcRoomID, r.HostUserID, appInfo.AppId, appInfo.AppKey)

		if len(userList) == 2 {
			linkmicStatusInformData := &live_inform_service.InformLinkmicStatus{
				LinkmicStatus: live_return_models.UserLinkmicStatusAudienceLinkmicLinked,
			}
			informer.BroadcastRoom(ctx, r.HostRoomID, live_inform_service.OnLinkmicStatus, linkmicStatusInformData)
		}
	}

	informer.UnicastRoomUser(ctx, r.AudienceRoomID, r.AudienceUserID, live_inform_service.OnAudienceLinkmicPermit, informData)

	return resp, nil
}

func AudienceKick(ctx context.Context, appID string, r *live_linker_models.ApiAudienceKickReq) (*live_linker_models.ApiAudienceKickResp, error) {
	linkerService := live_linkmic_core_service.GetLinkerService()

	kickResp, err := linkerService.AudienceKick(ctx, &live_linker_models.AudienceKickReq{
		BizID:          public.BizIDLive,
		HostRoomID:     r.HostRoomID,
		HostUserID:     r.HostUserID,
		AudienceRoomID: r.AudienceRoomID,
		AudienceUserID: r.AudienceUserID,
	})
	if err != nil {
		logs.CtxError(ctx, "invite failed,error:%s", err)
		return nil, err
	}
	informer := inform.GetInformService(appID)
	roomRepo := live_facade.GetRoomRepo()
	rtcRoomID := roomRepo.GetRoomRtcRoomID(ctx, kickResp.Linker.FromRoomID)
	informData := &live_inform_service.InformAudienceLinkmicKick{
		LinkerID:  kickResp.Linker.LinkerID,
		RoomID:    r.AudienceRoomID,
		RtcRoomID: rtcRoomID,
		UserID:    r.AudienceUserID,
	}
	informer.UnicastRoomUser(ctx, r.AudienceRoomID, r.AudienceUserID, live_inform_service.OnAudienceLinkmicKick, informData)

	linkedUserList, _ := getLinkedUserList(ctx, appID, r.HostRoomID)
	informDataLeave := live_inform_service.InformAudienceLinkmicLeave{
		RtcRoomID: rtcRoomID,
		UserList:  linkedUserList,
		UserID:    r.AudienceUserID,
	}

	informer.BroadcastRoom(ctx, rtcRoomID, live_inform_service.OnAudienceLinkmicLeave, informDataLeave)

	if len(linkedUserList) == 0 {
		AudienceFinish(ctx, appID, &live_linker_models.ApiAudienceFinishReq{
			HostRoomID: r.HostRoomID,
			HostUserID: r.HostUserID,
			OnlyActive: true,
		})
	}
	resp := &live_linker_models.ApiAudienceKickResp{
		LinkerID: kickResp.Linker.LinkerID,
	}
	return resp, nil
}

func AudienceLeave(ctx context.Context, appID string, r *live_linker_models.ApiAudienceLeaveReq) (*live_linker_models.ApiAudienceLeaveResp, error) {
	linkerService := live_linkmic_core_service.GetLinkerService()

	leaveResp, err := linkerService.AudienceLeave(ctx, &live_linker_models.AudienceLeaveReq{
		LinkerID:       r.LinkerID,
		BizID:          public.BizIDLive,
		HostRoomID:     r.HostRoomID,
		HostUserID:     r.HostUserID,
		AudienceRoomID: r.AudienceRoomID,
		AudienceUserID: r.AudienceUserID,
	})
	if err != nil {
		logs.CtxError(ctx, "invite failed,error:%s", err)
		return nil, err
	}
	roomRepo := live_facade.GetRoomRepo()
	userList, _ := getLinkedUserList(ctx, appID, r.HostRoomID)
	rtcRoomID := roomRepo.GetRoomRtcRoomID(ctx, r.HostRoomID)
	informData := &live_inform_service.InformAudienceLinkmicLeave{
		RtcRoomID: rtcRoomID,
		UserList:  userList,
		UserID:    r.AudienceUserID,
	}
	informer := inform.GetInformService(appID)

	informer.BroadcastRoom(ctx, rtcRoomID, live_inform_service.OnAudienceLinkmicLeave, informData)

	if len(userList) < 2 {
		AudienceFinish(ctx, appID, &live_linker_models.ApiAudienceFinishReq{
			HostRoomID: r.HostRoomID,
			HostUserID: r.HostUserID,
			OnlyActive: true,
		})
	}
	resp := &live_linker_models.ApiAudienceLeaveResp{
		LinkerID: leaveResp.Linker.LinkerID,
	}
	return resp, nil
}

func AudienceCancel(ctx context.Context, appID string, r *live_linker_models.ApiAudienceCancelReq) (*live_linker_models.ApiAudienceLeaveResp, error) {
	linkerService := live_linkmic_core_service.GetLinkerService()

	locked, err := lock.CheckRoomLockStatus(ctx, r.HostRoomID)
	if err != nil {
		return nil, custom_error.InternalError(err)
	}
	if locked {
		logs.CtxInfo(ctx, " room is locked")
		return nil, custom_error.ErrRoomStatusNotMatchAction
	}

	leaveResp, err := linkerService.AudienceCancel(ctx, &live_linker_models.ApiAudienceCancelReq{
		HostRoomID:     r.HostRoomID,
		HostUserID:     r.HostUserID,
		AudienceRoomID: r.AudienceRoomID,
		AudienceUserID: r.AudienceUserID,
		LinkerID:       r.LinkerID,
	})
	if err != nil {
		logs.CtxError(ctx, "invite failed,error:%s", err)
		return nil, err
	}
	roomRepo := live_facade.GetRoomRepo()
	rtcRoomID := roomRepo.GetRoomRtcRoomID(ctx, r.HostRoomID)
	informData := &live_inform_service.InformAudienceLinkmicCancel{
		RtcRoomID: rtcRoomID,
		UserID:    r.AudienceUserID,
	}
	informer := inform.GetInformService(appID)

	informer.UnicastUser(ctx, r.HostUserID, live_inform_service.OnAudienceLinkmicCancel, informData)

	resp := &live_linker_models.ApiAudienceLeaveResp{
		LinkerID: leaveResp.Linker.LinkerID,
	}
	return resp, nil
}

func AudienceFinish(ctx context.Context, appID string, r *live_linker_models.ApiAudienceFinishReq) (*live_linker_models.ApiAudienceFinishResp, error) {
	linkerService := live_linkmic_core_service.GetLinkerService()

	_, err := linkerService.AudienceFinish(ctx, &live_linker_models.AudienceFinishReq{
		BizID:      public.BizIDLive,
		HostRoomID: r.HostRoomID,
		HostUserID: r.HostUserID,
		OnlyActive: r.OnlyActive,
	})
	if err != nil {
		logs.CtxError(ctx, "invite failed,error:%s", err)
		return nil, err
	}
	roomRepo := live_facade.GetRoomRepo()

	informData := &live_inform_service.InformAudienceLinkmicFinish{
		RtcRoomID: roomRepo.GetRoomRtcRoomID(ctx, r.HostRoomID),
	}

	informer := inform.GetInformService(appID)

	informer.BroadcastRoom(ctx, roomRepo.GetRoomRtcRoomID(ctx, r.HostRoomID), live_inform_service.OnAudienceLinkmicFinish, informData)

	linkmicStatusInformData := &live_inform_service.InformLinkmicStatus{
		LinkmicStatus: live_return_models.UserLinkmicStatusUnknown,
	}
	informer.BroadcastRoom(ctx, r.HostRoomID, live_inform_service.OnLinkmicStatus, linkmicStatusInformData)

	//AudienceInit(ctx, appID, &live_linker_models.ApiAudienceInitReq{
	//	HostRoomID: r.HostRoomID,
	//	HostUserID: r.HostUserID,
	//})

	resp := &live_linker_models.ApiAudienceFinishResp{}
	return resp, nil
}

func getLinkedUserList(ctx context.Context, appID, roomID string) ([]*live_return_models.User, error) {
	resp := make([]*live_return_models.User, 0)
	activeRoomLinkmicInfo, err := GetActiveRoomLinkmicInfo(ctx, roomID)
	if err != nil {
		logs.CtxError(ctx, "get active room linkmic failed,error:%s", err)
		return nil, err
	}

	if len(activeRoomLinkmicInfo.Linkers) == 0 {
		return resp, nil
	}

	if !activeRoomLinkmicInfo.IsAnchorLink {
		if len(activeRoomLinkmicInfo.LinkedUsers) == 0 {
			return resp, nil
		}
		var userIDs []string
		for _, linker := range activeRoomLinkmicInfo.LinkedUsers[roomID] {
			userIDs = append(userIDs, linker.FromUserID)
			if !util.StringInSlice(linker.ToUserID, userIDs) {
				userIDs = append(userIDs, linker.ToUserID)
			}
		}
		roomUsers, err := live_facade.GetRoomUserRepo().GetUsersByRoomIDUserIDs(ctx, appID, roomID, userIDs)
		if err != nil {
			logs.CtxError(ctx, "get room users failed,error:%s", err)
			return nil, err
		}

		for _, roomUser := range roomUsers {
			user := &live_return_models.User{
				RoomID:   roomUser.RoomID,
				UserID:   roomUser.UserID,
				UserName: roomUser.UserName,
				UserRole: roomUser.UserRole,
				Mic:      roomUser.Mic,
				Camera:   roomUser.Camera,
				Extra:    roomUser.Extra,
			}
			resp = append(resp, user)
		}
	} else {
		for _, linker := range activeRoomLinkmicInfo.LinkedUsers[roomID] {
			fromRoomUser, _ := live_facade.GetRoomUserRepo().GetActiveUser(ctx, appID, linker.FromRoomID, linker.FromUserID)
			toRoomUser, _ := live_facade.GetRoomUserRepo().GetActiveUser(ctx, appID, linker.ToRoomID, linker.ToUserID)
			if fromRoomUser != nil {
				user := &live_return_models.User{
					RoomID:   fromRoomUser.RoomID,
					UserID:   fromRoomUser.UserID,
					UserName: fromRoomUser.UserName,
					UserRole: fromRoomUser.UserRole,
					Mic:      fromRoomUser.Mic,
					Camera:   fromRoomUser.Camera,
					Extra:    fromRoomUser.Extra}
				resp = append(resp, user)
			}
			if toRoomUser != nil {
				user := &live_return_models.User{
					RoomID:   toRoomUser.RoomID,
					UserID:   toRoomUser.UserID,
					UserName: toRoomUser.UserName,
					UserRole: toRoomUser.UserRole,
					Mic:      toRoomUser.Mic,
					Camera:   toRoomUser.Camera,
					Extra:    toRoomUser.Extra}
				resp = append(resp, user)
			}

		}
	}
	return resp, nil
}
