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

package live_linkmic_core_service

import (
	"context"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_linker_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli/lock"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
)

var linkerService *LinkerService

type LinkerService struct {
	linkerFactory *LinkerFactory
	linkerRepo    live_facade.LinkerRepoInterface
	userRepo      live_facade.RoomUserRepoInterface
	roomRepo      live_facade.RoomRepoInterface
}

func GetLinkerService() *LinkerService {
	if linkerService == nil {
		linkerService = &LinkerService{
			linkerFactory: linkerFactory,
			linkerRepo:    live_facade.GetLinkerRepo(),
			userRepo:      live_facade.GetRoomUserRepo(),
			roomRepo:      live_facade.GetRoomRepo(),
		}
	}
	return linkerService
}

// Native interface
func (ls *LinkerService) CreateLinker(ctx context.Context, appID string, linkerID, bizID, fromRoomID, fromUserID, toRoomID, toUserID string, scene int) (*live_entity.LiveLinker, error) {
	//create linker
	linker := ls.linkerFactory.NewDefaultLinker(ctx, linkerID, bizID, fromRoomID, fromUserID, toRoomID, toUserID, scene)
	err := ls.linkerRepo.SaveLinker(ctx, linker)
	if err != nil {
		return nil, custom_error.InternalError(err)
	}
	return linker, nil
}

func (ls *LinkerService) AddLinkerToRoom(ctx context.Context, roomID, userID string, linker *live_entity.LiveLinker) error {
	linker.ToRoomID = roomID
	linker.ToUserID = userID
	err := ls.linkerRepo.SaveLinker(ctx, linker)
	if err != nil {
		return custom_error.InternalError(err)
	}
	return nil
}

func (ls *LinkerService) UpdateLinkerStatus(ctx context.Context, linkerID string, status int) error {
	updateParams := map[string]interface{}{}
	now := time.Now()
	if util.IntInSlice(status, []int{live_linker_models.LinkerStatusAnchorInvite, live_linker_models.LinkerStatusAudienceInvite, live_linker_models.LinkerStatusAudienceApplying}) {
		updateParams["linker_status"] = status
		updateParams["linking_time"] = now
	}
	if util.IntInSlice(status, []int{live_linker_models.LinkerStatusAnchorLinked, live_linker_models.LinkerStatusAudienceLinked}) {
		updateParams["linker_status"] = status
		updateParams["linked_time"] = now
	}
	if util.IntInSlice(status, []int{live_linker_models.LinkerStatusNothing, live_linker_models.LinkerStatusNotValid}) {
		updateParams["linker_status"] = status
	}
	err := ls.linkerRepo.UpdateLinker(ctx, linkerID, updateParams)
	if err != nil {
		return err
	}

	return nil
}

func (ls *LinkerService) GetAudienceLinkers(ctx context.Context, roomID string) ([]*live_entity.LiveLinker, error) {
	return ls.linkerRepo.GetLinkersByRoomIDScene(ctx, roomID, live_linker_models.LinkerSceneAudience)
}

func (ls *LinkerService) GetActiveAudienceLinkers(ctx context.Context, roomID string) ([]*live_entity.LiveLinker, error) {
	return ls.linkerRepo.GetActiveLinkersByRoomIDScene(ctx, roomID, live_linker_models.LinkerSceneAudience)
}

func (ls *LinkerService) GetDefaultAnchorLinker(ctx context.Context, roomID string) ([]*live_entity.LiveLinker, error) {
	return ls.linkerRepo.GetLinkersByRoomIDScene(ctx, roomID, live_linker_models.LinkerSceneAnchor)
}

func (ls *LinkerService) GetAudienceLinkerByRoomIDAndUserID(ctx context.Context, roomID, userID string) (*live_entity.LiveLinker, error) {
	return ls.linkerRepo.GetAudienceLinkerByRoomIDAndUserID(ctx, roomID, userID)
}

func (ls *LinkerService) GetLinker(ctx context.Context, linkerID string) (*live_entity.LiveLinker, error) {
	return ls.linkerRepo.GetLinker(ctx, linkerID)
}

//advance interface

//audience linkmic
//func (ls *LinkerService) AudienceInit(ctx context.Context, appID string, r *live_linker_models.AudienceInitReq) (*live_linker_models.AudienceInitResp, error) {
//	linker, err := ls.CreateLinker(ctx, appID, r.LinkerID, r.BizID, r.HostRoomID, r.HostUserID, live_linker_models.LinkerSceneAudience)
//	if err != nil {
//		logs.CtxError(ctx, "CreateLinker failed,req:%#v,error:%s", r, err)
//		return nil, err
//	}
//
//	logs.CtxInfo(ctx, "AudienceInit success,req:%#v,linker:%#v", r, linker)
//	resp := &live_linker_models.AudienceInitResp{
//		Linker: linker,
//	}
//	return resp, nil
//}

func (ls *LinkerService) AudienceInvite(ctx context.Context, r *live_linker_models.AudienceInviteReq) (*live_linker_models.AudienceInviteResp, error) {
	_, err := ls.userRepo.GetUser(ctx, r.AppID, r.HostRoomID, r.HostUserID)
	if err != nil {
		logs.CtxError(ctx, "get host failed,error:%s", err)
		return nil, err
	}
	if r.LinkerID == "" {
		return nil, custom_error.ErrLinkerParamError
	}
	linker, err := ls.CreateLinker(ctx, r.AppID, r.LinkerID, r.BizID, r.AudienceRoomID, r.AudienceUserID, r.HostRoomID, r.HostUserID, live_linker_models.LinkerSceneAudience)
	if err != nil {
		logs.CtxError(ctx, "CreateLinker failed,req:%#v,error:%s", r, err)
		return nil, err
	}

	//Add Linker to the invited host room
	err = ls.AddLinkerToRoom(ctx, r.HostRoomID, r.HostUserID, linker)
	if err != nil {
		logs.CtxError(ctx, "add linker to room failed,error:%s", err)
		return nil, err
	}

	linker, err = ls.GetAudienceLinkerByRoomIDAndUserID(ctx, r.AudienceRoomID, r.AudienceUserID)
	if err != nil {
		logs.CtxError(ctx, "GetDefaultLinker failed,req:%#v,error:%s", r, err)
		return nil, err
	}
	err = ls.UpdateLinkerStatus(ctx, linker.LinkerID, live_linker_models.LinkerStatusAudienceInvite)
	if err != nil {
		return nil, err
	}
	logs.CtxInfo(ctx, "AudienceInvite success,req:%#v,linker:%#v", r, linker)
	resp := &live_linker_models.AudienceInviteResp{
		Linker: linker,
	}
	return resp, nil
}

func (ls *LinkerService) AudienceReply(ctx context.Context, r *live_linker_models.AudienceReplyReq) (*live_linker_models.AudienceReplyResp, error) {
	linker, err := ls.GetAudienceLinkerByRoomIDAndUserID(ctx, r.AudienceRoomID, r.AudienceUserID)
	if err != nil {
		logs.CtxError(ctx, "GetDefaultLinker failed,req:%#v,error:%s", r, err)
		return nil, err
	}
	currentUnix := time.Now().Unix()
	if linker.LinkerStatus != live_linker_models.LinkerStatusAudienceInvite && linker.LinkingTime.Unix()-currentUnix >= 5 {
		logs.CtxInfo(ctx, "linker is expire")
		return nil, custom_error.ErrLinkerNotExist
	}

	if r.Reply == live_linker_models.ReplyAccept {
		_, err = ls.linkerRepo.GetValidInvitee(ctx, linker.LinkerID, r.AudienceRoomID, r.AudienceUserID)
		if err != nil {
			return nil, err
		}
		err = ls.UpdateLinkerStatus(ctx, linker.LinkerID, live_linker_models.LinkerStatusAudienceLinked)
		if err != nil {
			return nil, err
		}
		// If the anchor confirms the audience's connection request, the PK request sent by the anchor itself should be automatically set as invalid
		anchorLinker, err := ls.GetDefaultAnchorLinker(ctx, r.HostRoomID)
		if err != nil && !custom_error.Equal(err, custom_error.ErrRecordNotFound) {
			logs.CtxError(ctx, "get default linker failed,error:%s", err)
			return nil, err
		}
		for _, al := range anchorLinker {
			err = ls.UpdateLinkerStatus(ctx, al.LinkerID, live_linker_models.LinkerStatusNotValid)
			if err != nil {
				logs.CtxError(ctx, "update linker status error: "+err.Error())
				return nil, err
			}
		}
	} else if r.Reply == live_linker_models.ReplyReject {
		err = ls.UpdateLinkerStatus(ctx, linker.LinkerID, live_linker_models.LinkerStatusNotValid)
		if err != nil {
			return nil, err
		}
	}

	logs.CtxInfo(ctx, "AudienceReply success,req:%#v,linker:%#v", r, linker)
	resp := &live_linker_models.AudienceReplyResp{
		Linker: linker,
	}
	return resp, nil
}

func (ls *LinkerService) AudienceApply(ctx context.Context, r *live_linker_models.AudienceApplyReq) (*live_linker_models.AudienceApplyResp, error) {
	if r.LinkerID == "" {
		return nil, custom_error.ErrLinkerParamError
	}
	_, err := ls.GetAudienceLinkerByRoomIDAndUserID(ctx, r.AudienceRoomID, r.AudienceUserID)
	if !custom_error.Equal(err, custom_error.ErrRecordNotFound) {
		logs.CtxError(ctx, "GetDefaultLinker failed")
		return nil, custom_error.ErrUserInviting
	}

	linker, err := ls.CreateLinker(ctx, r.AppID, r.LinkerID, r.BizID, r.AudienceRoomID, r.AudienceUserID, r.HostRoomID, r.HostUserID, live_linker_models.LinkerSceneAudience)
	if err != nil {
		logs.CtxError(ctx, "CreateLinker failed,req:%#v,error:%s", r, err)
		return nil, err
	}

	err = ls.AddLinkerToRoom(ctx, r.HostRoomID, r.HostUserID, linker)
	if err != nil {
		logs.CtxError(ctx, "add linker to room failed,error:%s", err)
		return nil, err
	}
	err = ls.UpdateLinkerStatus(ctx, linker.LinkerID, live_linker_models.LinkerStatusAudienceApplying)
	if err != nil {
		return nil, err
	}
	linker, err = ls.GetLinker(ctx, linker.LinkerID)
	if err != nil {
		logs.CtxError(ctx, "GetDefaultLinker failed,req:%#v,error:%s", r, err)
		return nil, err
	}
	logs.CtxInfo(ctx, "AudienceApply success,req:%#v,linker:%#v,group:%#v", r, linker)
	resp := &live_linker_models.AudienceApplyResp{
		Linker: linker,
	}
	return resp, nil
}

func (ls *LinkerService) AudiencePermit(ctx context.Context, r *live_linker_models.AudiencePermitReq) (*live_linker_models.AudiencePermitResp, error) {
	linker, err := ls.GetLinker(ctx, r.LinkerID)
	if err != nil {
		logs.CtxError(ctx, "GetDefaultLinker failed,req:%#v,error:%s", r, err)
		return nil, err
	}
	if linker.LinkerStatus != live_linker_models.LinkerStatusAudienceApplying {
		logs.CtxInfo(ctx, "linker is expire")
		return nil, custom_error.ErrLinkerNotExist
	}
	if linker.ToUserID != r.HostUserID {
		logs.CtxError(ctx, "linker info error")
		return nil, custom_error.ErrUserDoNotHavePermission
	}

	if r.Permit == live_linker_models.PermitAccept {
		err = ls.UpdateLinkerStatus(ctx, linker.LinkerID, live_linker_models.LinkerStatusAudienceLinked)
		if err != nil {
			return nil, err
		}
		// If the anchor confirms the audience's connection request, the PK request sent by the anchor itself should be automatically set as invalid
		anchorLinker, err := ls.GetDefaultAnchorLinker(ctx, r.HostRoomID)
		if err != nil && !custom_error.Equal(err, custom_error.ErrRecordNotFound) {
			logs.CtxError(ctx, "get default linker failed,error:%s", err)
			return nil, err
		}
		for _, al := range anchorLinker {
			err = ls.UpdateLinkerStatus(ctx, al.LinkerID, live_linker_models.LinkerStatusNotValid)
			if err != nil {
				logs.CtxError(ctx, "update linker status error: "+err.Error())
				return nil, err
			}
		}
	} else if r.Permit == live_linker_models.PermitReject {
		err = ls.UpdateLinkerStatus(ctx, linker.LinkerID, live_linker_models.LinkerStatusNotValid)
		if err != nil {
			return nil, err
		}
	}

	logs.CtxInfo(ctx, "AudiencePermit success,req:%#v,linker:%#v,group:%#v", r, linker)
	resp := &live_linker_models.AudiencePermitResp{
		Linker: linker,
	}
	return resp, nil
}

func (ls *LinkerService) AudienceLeave(ctx context.Context, r *live_linker_models.AudienceLeaveReq) (*live_linker_models.AudienceLeaveResp, error) {
	ok, lt := lock.LockRoom(ctx, r.HostRoomID)
	if !ok {
		return nil, custom_error.ErrLockRedis
	}
	defer lock.UnLockRoom(ctx, r.HostRoomID, lt)

	linker, err := ls.GetLinker(ctx, r.LinkerID)
	if err != nil {
		logs.CtxError(ctx, "GetDefaultLinker failed,req:%#v,error:%s", r, err)
		return nil, err
	}
	if linker.ToUserID != r.HostUserID {
		return nil, custom_error.ErrUserDoNotHavePermission
	}

	err = ls.UpdateLinkerStatus(ctx, linker.LinkerID, live_linker_models.LinkerStatusNotValid)
	if err != nil {
		return nil, err
	}

	logs.CtxInfo(ctx, "AudienceKick success,req:%#v,linker:%#v", r, linker)
	resp := &live_linker_models.AudienceLeaveResp{
		Linker: linker,
	}
	return resp, nil

}

func (ls *LinkerService) AudienceCancel(ctx context.Context, r *live_linker_models.ApiAudienceCancelReq) (*live_linker_models.AudienceLeaveResp, error) {
	ok, lt := lock.LockRoom(ctx, r.HostRoomID)
	if !ok {
		return nil, custom_error.ErrLockRedis
	}
	defer lock.UnLockRoom(ctx, r.HostRoomID, lt)

	linker, err := ls.GetLinker(ctx, r.LinkerID)
	if err != nil {
		logs.CtxError(ctx, "GetDefaultLinker failed,req:%#v,error:%s", r, err)
		return nil, err
	}
	if linker.ToUserID != r.HostUserID {
		return nil, custom_error.ErrUserDoNotHavePermission
	}
	if linker.LinkerStatus == live_linker_models.LinkerStatusAudienceLinked {
		logs.CtxError(ctx, "audience is linking")
		return nil, custom_error.ErrUserLinked
	}

	err = ls.UpdateLinkerStatus(ctx, linker.LinkerID, live_linker_models.LinkerStatusNotValid)
	if err != nil {
		return nil, err
	}

	logs.CtxInfo(ctx, "AudienceKick success,req:%#v,linker:%#v", r, linker)
	resp := &live_linker_models.AudienceLeaveResp{
		Linker: linker,
	}
	return resp, nil

}

func (ls *LinkerService) AudienceKick(ctx context.Context, r *live_linker_models.AudienceKickReq) (*live_linker_models.AudienceKickResp, error) {
	linker, err := ls.GetAudienceLinkerByRoomIDAndUserID(ctx, r.AudienceRoomID, r.AudienceUserID)
	if err != nil {
		logs.CtxError(ctx, "GetDefaultLinker failed,req:%#v,error:%s", r, err)
		return nil, err
	}
	err = ls.UpdateLinkerStatus(ctx, linker.LinkerID, live_linker_models.LinkerStatusNotValid)
	if err != nil {
		return nil, err
	}

	logs.CtxInfo(ctx, "AudienceApply success,req:%#v,linker:%#v", r, linker)
	resp := &live_linker_models.AudienceKickResp{
		Linker: linker,
	}
	return resp, nil
}

func (ls *LinkerService) AudienceFinish(ctx context.Context, r *live_linker_models.AudienceFinishReq) (*live_linker_models.AudienceFinishResp, error) {
	var linkers []*live_entity.LiveLinker
	var err error
	if r.OnlyActive {
		linkers, err = ls.GetActiveAudienceLinkers(ctx, r.HostRoomID)
	} else {
		linkers, err = ls.GetAudienceLinkers(ctx, r.HostRoomID)
	}

	if err != nil {
		return nil, err
	}
	var finishLinkers []*live_entity.LiveLinker
	for _, linker := range linkers {

		if linker.ToUserID != r.HostUserID {
			return nil, custom_error.ErrUserDoNotHavePermission
		}

		err = ls.UpdateLinkerStatus(ctx, linker.LinkerID, live_linker_models.LinkerStatusNotValid)
		if err != nil {
			logs.CtxError(ctx, "UpdateLinker failed,req:%#v,error:%s", r, err)
			return nil, err
		}
		if linker.LinkerStatus == live_linker_models.LinkerStatusAnchorLinked {
			finishLinkers = append(finishLinkers, linker)
		}

	}

	resp := &live_linker_models.AudienceFinishResp{
		Linkers: finishLinkers,
	}
	return resp, nil
}

func (ls *LinkerService) AnchorInvite(ctx context.Context, appID string, r *live_linker_models.AnchorInviteReq) (*live_linker_models.AnchorInviteResp, error) {
	if r.LinkerID == "" {
		return nil, custom_error.ErrLinkerParamError
	}
	linker, err := ls.CreateLinker(ctx, appID, r.LinkerID, r.BizID, r.InviterRoomID, r.InviterUserID, r.InviteeRoomID, r.InviteeUserID, live_linker_models.LinkerSceneAnchor)
	if err != nil {
		logs.CtxError(ctx, "CreateLinker failed,req:%#v,error:%s", r, err)
		return nil, err
	}

	err = ls.AddLinkerToRoom(ctx, r.InviteeRoomID, r.InviteeUserID, linker)
	if err != nil {
		logs.CtxError(ctx, "add linker to room failed,error:%s", err)
		return nil, err
	}
	err = ls.UpdateLinkerStatus(ctx, linker.LinkerID, live_linker_models.LinkerStatusAnchorInvite)
	if err != nil {
		return nil, err
	}

	logs.CtxInfo(ctx, "AnchorInvite success,req:%#v,linker:%#v", r, linker)
	resp := &live_linker_models.AnchorInviteResp{
		Linker: linker,
	}
	return resp, nil
}

func (ls *LinkerService) AnchorReply(ctx context.Context, r *live_linker_models.AnchorReplyReq) (*live_linker_models.AnchorReplyResp, error) {
	if r.LinkerID == "" {
		return nil, custom_error.ErrLinkerParamError
	}
	linker, err := ls.GetLinker(ctx, r.LinkerID)
	if err != nil {
		logs.CtxError(ctx, "GetLinker failed,req:%#v,error:%s", r, err)
		return nil, err
	}
	currentUnix := time.Now().Unix()
	if linker.LinkerStatus != live_linker_models.LinkerStatusAnchorInvite && linker.LinkingTime.Unix()-currentUnix >= 5 {
		logs.CtxInfo(ctx, "linker is expire")
		return nil, custom_error.ErrLinkerNotExist
	}
	_, err = ls.linkerRepo.GetValidInvitee(ctx, linker.LinkerID, r.InviteeRoomID, r.InviteeUserID)
	if err != nil {
		logs.CtxError(ctx, "invitee invalid,error:%s", err)
		return nil, err
	}
	room, err := ls.roomRepo.GetActiveRoom(ctx, r.AppID, r.InviterRoomID)
	if err != nil || room == nil {
		logs.CtxError(ctx, "get inviter room error:%s", err)
		return nil, err
	}
	// Dual anchor pk, directly updating all users. If multiple anchors pk, the logic needs to be modified
	if r.Reply == live_linker_models.ReplyAccept {
		err = ls.UpdateLinkerStatus(ctx, linker.LinkerID, live_linker_models.LinkerStatusAnchorLinked)
		if err != nil {
			return nil, err
		}
	} else if r.Reply == live_linker_models.ReplyReject {
		_, err = ls.AnchorFinish(ctx, &live_linker_models.AnchorFinishReq{
			LinkerID: r.LinkerID,
			BizID:    r.BizID,
		})
		if err != nil {
			return nil, err
		}
	}

	logs.CtxInfo(ctx, "AnchorReply success,req:%#v,linker:%#v", r, linker)
	resp := &live_linker_models.AnchorReplyResp{
		Linker: linker,
	}
	return resp, nil
}

func (ls *LinkerService) AnchorFinish(ctx context.Context, r *live_linker_models.AnchorFinishReq) (*live_linker_models.AnchorFinishResp, error) {
	if r.LinkerID == "" {
		return nil, custom_error.ErrLinkerParamError
	}
	linker, err := ls.GetLinker(ctx, r.LinkerID)
	if err != nil {
		logs.CtxError(ctx, "GetLinker failed,req:%#v,error:%s", r, err)
		return nil, err
	}
	users, _ := ls.linkerRepo.GetLinkedUsersByLinkerID(ctx, linker.LinkerID)

	err = ls.UpdateLinkerStatus(ctx, linker.LinkerID, live_linker_models.LinkerStatusNotValid)
	if err != nil {
		logs.CtxError(ctx, "UpdateLinker failed,req:%#v,error:%s", r, err)
		return nil, err
	}

	resp := &live_linker_models.AnchorFinishResp{
		Linker:   linker,
		UserList: users,
	}

	return resp, nil
}

// info
func (ls *LinkerService) GetRoomLinkmicInfo(ctx context.Context, r *live_linker_models.GetRoomLinkmicInfoReq) (*live_linker_models.GetRoomLinkmicInfoResp, error) {
	resp := &live_linker_models.GetRoomLinkmicInfoResp{}
	resp.Linkers = make([]*live_entity.LiveLinker, 0)
	resp.LinkedUsers = make(map[string][]*live_entity.LiveLinker)
	resp.InviteUsers = make(map[string][]*live_entity.LiveLinker)
	resp.ApplyUsers = make(map[string][]*live_entity.LiveLinker)
	audienceLinkers, err := ls.GetAudienceLinkers(ctx, r.RoomID)
	if err != nil && !custom_error.Equal(err, custom_error.ErrRecordNotFound) {
		logs.CtxError(ctx, "get default linker failed,error:%s", err)
		return nil, err
	}
	if len(audienceLinkers) != 0 {
		for _, linker := range audienceLinkers {
			if linker.LinkerStatus == live_linker_models.LinkerStatusAudienceLinked {
				resp.IsLinked = true
				resp.LinkedUsers[linker.FromRoomID] = append(resp.LinkedUsers[linker.FromRoomID], linker)
			} else if linker.LinkerStatus == live_linker_models.LinkerStatusAudienceApplying {
				resp.ApplyUsers[linker.FromRoomID] = append(resp.ApplyUsers[linker.FromRoomID], linker)
			} else if linker.LinkerStatus == live_linker_models.LinkerStatusAudienceInvite {
				resp.InviteUsers[linker.FromRoomID] = append(resp.InviteUsers[linker.FromRoomID], linker)
			}
			resp.Linkers = append(resp.Linkers, linker)
		}
		//return resp, nil
	}
	anchorLinker, err := ls.GetDefaultAnchorLinker(ctx, r.RoomID)
	if err != nil && !custom_error.Equal(err, custom_error.ErrRecordNotFound) {
		logs.CtxError(ctx, "get default linker failed,error:%s", err)
		return nil, err
	}
	if len(anchorLinker) != 0 {
		for _, linker := range anchorLinker {
			if linker.LinkerStatus == live_linker_models.LinkerStatusAnchorLinked {
				resp.IsLinked = true
				resp.LinkedUsers[linker.FromRoomID] = append(resp.LinkedUsers[linker.FromRoomID], linker)
				resp.LinkedUsers[linker.ToRoomID] = append(resp.LinkedUsers[linker.ToRoomID], linker)
			} else if linker.LinkerStatus == live_linker_models.LinkerStatusAnchorInvite {
				resp.InviteUsers[r.RoomID] = append(resp.InviteUsers[r.RoomID], linker)
			}
			resp.Linkers = append(resp.Linkers, linker)
		}
		resp.IsAnchorLink = true
	}

	return resp, nil
}
