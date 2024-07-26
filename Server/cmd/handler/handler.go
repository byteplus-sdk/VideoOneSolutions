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

package handler

import (
	"encoding/json"
	"errors"

	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_handler"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_handler"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_handler"
	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_handler"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/response"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/task"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"github.com/gin-gonic/gin"
)

type VideoOneHandler func(ctx *gin.Context) (resp interface{}, err error)

var (
	handlerMap = make(map[string]VideoOneHandler)
)

func HandleHttpCallEvent(httpCtx *gin.Context) {
	ctx := util.EnsureID(httpCtx)
	eventName := httpCtx.Query("event_name")
	if !validEventName(eventName) {
		logs.CtxInfo(ctx, "event_name is invalid")
		httpCtx.String(400, response.NewCommonResponse(ctx, "", "", custom_error.NewCustomError(400, errors.New("event_name is invalid"))))
		return
	}

	resp, err := handlerMap[eventName](httpCtx)
	httpCtx.String(200, response.NewCommonResponse(ctx, "", resp, err))
}

func init() {
	//login
	{
		registerHandler("getAppInfo", login_handler.GetAppInfo)
	}

	// interactive live
	{
		{
			// common
			registerHandler("liveGetActiveLiveRoomList", live_handler.GetActiveLiveRoomList)
			registerHandler("liveUpdateMediaStatus", live_handler.UpdateMediaStatus)
			registerHandler("liveUpdateResolution", live_handler.UpdateResolution)
			registerHandler("liveReconnect", live_handler.Reconnect)
			registerHandler("liveClearUser", live_handler.ClearUser)
			registerHandler("liveSendMessage", live_handler.SendMessage)
		}
		{
			// host
			registerHandler("liveCreateLive", live_handler.CreateLive)
			registerHandler("liveStartLive", live_handler.StartLive)
			registerHandler("liveFinishLive", live_handler.FinishLive)
			registerHandler("liveGetActiveAnchorList", live_handler.GetActiveAnchorList)
			registerHandler("liveAnchorLinkmicInvite", live_handler.AnchorLinkmicInvite)
			registerHandler("liveAnchorLinkmicReply", live_handler.AnchorLinkmicReply)
			registerHandler("liveAnchorLinkmicFinish", live_handler.AnchorLinkmicFinish)
			registerHandler("liveGetAudienceList", live_handler.GetAudienceList)
			registerHandler("liveAudienceLinkmicInvite", live_handler.AudienceLinkmicInvite)
			registerHandler("liveAudienceLinkmicReply", live_handler.AudienceLinkmicReply)
			registerHandler("liveAudienceLinkmicKick", live_handler.AudienceLinkmicKick)
			registerHandler("liveManageGuestMedia", live_handler.ManageGuestMedia)
		}
		{
			// guest
			registerHandler("liveJoinLiveRoom", live_handler.JoinLiveRoom)
			registerHandler("liveLeaveLiveRoom", live_handler.LeaveLiveRoom)
			registerHandler("liveAudienceLinkmicPermit", live_handler.AudienceLinkmicPermit)
			registerHandler("liveAudienceLinkmicApply", live_handler.AudienceLinkmicApply)
			registerHandler("liveAudienceLinkmicLeave", live_handler.AudienceLinkmicLeave)
			registerHandler("liveAudienceLinkmicCancel", live_handler.AudienceLinkmicCancel)
			registerHandler("liveAudienceLinkmicFinish", live_handler.AudienceLinkmicFinish)
		}
	}

	// Online KTV - Duet Singing
	{
		{
			// common
			registerHandler("ktvGetActiveLiveRoomList", ktv_handler.GetActiveLiveRoomList)
			registerHandler("ktvSendMessage", ktv_handler.SendMessage)
			registerHandler("ktvReconnect", ktv_handler.Reconnect)
			registerHandler("ktvClearUser", ktv_handler.ClearUser)
			registerHandler("ktvUpdateMediaStatus", ktv_handler.UpdateMediaStatus)
		}
		{
			// host
			registerHandler("ktvStartLive", ktv_handler.StartLive)
			registerHandler("ktvFinishLive", ktv_handler.FinishLive)
			registerHandler("ktvGetAudienceList", ktv_handler.GetAudienceList)
			registerHandler("ktvGetApplyAudienceList", ktv_handler.GetApplyAudienceList)
			registerHandler("ktvManageInteractApply", ktv_handler.ManageInteractApply)
			registerHandler("ktvManageSeat", ktv_handler.ManageSeat)
			registerHandler("ktvAgreeApply", ktv_handler.AgreeApply)
		}
		{
			// guest
			registerHandler("ktvApplyInteract", ktv_handler.ApplyInteract)
			registerHandler("ktvFinishInteract", ktv_handler.FinishInteract)
			registerHandler("ktvInviteInteract", ktv_handler.InviteInteract)
			registerHandler("ktvJoinLiveRoom", ktv_handler.JoinLiveRoom)
			registerHandler("ktvLeaveLiveRoom", ktv_handler.LeaveLiveRoom)
			registerHandler("ktvReplyInvite", ktv_handler.ReplyInvite)
		}
		{
			// song
			registerHandler("ktvRequestSong", ktv_handler.RequestSong)
			registerHandler("ktvCutOffSong", ktv_handler.CutOffSong)
			registerHandler("ktvFinishSing", ktv_handler.FinishSing)
			registerHandler("ktvGetRequestSongList", ktv_handler.GetRequestSongList)
			registerHandler("ktvGetPresetSongList", ktv_handler.GetPreSetSongList)
		}
	}

	//online KTV - Solo Singing
	{
		{
			// common
			registerHandler("owcGetActiveLiveRoomList", owc_handler.GetActiveLiveRoomList)
			registerHandler("owcSendMessage", owc_handler.SendMessage)
			registerHandler("owcUpdateMediaStatus", owc_handler.UpdateMediaStatus)
			registerHandler("owcClearUser", owc_handler.ClearUser)
			registerHandler("owcReconnect", owc_handler.Reconnect)
		}
		{
			// host
			registerHandler("owcStartLive", owc_handler.StartLive)
			registerHandler("owcFinishLive", owc_handler.FinishLive)
		}
		{
			// guest
			registerHandler("owcJoinLiveRoom", owc_handler.JoinLiveRoom)
			registerHandler("owcLeaveLiveRoom", owc_handler.LeaveLiveRoom)
		}
		{
			// song
			registerHandler("owcRequestSong", owc_handler.RequestSong)
			registerHandler("owcCutOffSong", owc_handler.CutOffSong)
			registerHandler("owcStartSing", owc_handler.StartSing)
			registerHandler("owcFinishSing", owc_handler.FinishSing)
			registerHandler("owcGetRequestSongList", owc_handler.GetRequestSongList)
			registerHandler("owcGetPresetSongList", owc_handler.GetPreSetSongList)
		}
	}
}

// nolint
func registerHandler(eventName string, handler VideoOneHandler) {
	handlerMap[eventName] = handler
}

func validEventName(eventName string) bool {
	_, exist := handlerMap[eventName]
	return exist
}

func DisconnectHandler(ctx *gin.Context, appID, roomID, userID string) (err error) {
	logs.CtxInfo(ctx, "disconnect, appID %s,roomID:%s,userID:%s", appID, roomID, userID)

	err = live_handler.DisconnectLogic(ctx, appID, roomID, userID)
	if err == nil {
		return
	}

	err = ktv_handler.Disconnect(ctx, appID, roomID, userID)
	if err == nil {
		return
	}

	owc_handler.Disconnect(ctx, appID, roomID, userID)

	return nil
}

func PingPong(ctx *gin.Context) {
	logs.CtxInfo(ctx, "receive ping request")
	ctx.JSON(200, map[string]string{
		"message": "pong",
	})
}

func HandleRtsCallback(httpCtx *gin.Context) {
	defer httpCtx.String(200, "ok")

	p := &RtsCallbackParam{}
	err := httpCtx.BindJSON(p)
	if err != nil {
		logs.CtxError(httpCtx, "param error,err:%s", err)
		return
	}

	var appID, roomID, userID string

	switch p.EventType {
	case "UserLeaveRoom", "InvisibleUserLeaveRoom":
		eventData := &EventDataLeaveRoom{}
		err = json.Unmarshal([]byte(p.EventData), eventData)
		if err != nil {
			logs.CtxError(httpCtx, "param error,err:%s", err)
			return
		}
		if eventData.Reason != LeaveRoomReasonConnectionLost {
			return
		}
		appID = p.AppId
		roomID = eventData.RoomId
		userID = eventData.UserId
		if err = DisconnectHandler(httpCtx, appID, roomID, userID); err != nil {
			logs.CtxError(httpCtx, "handle error,param:%#v,err:%s", p, err)
		}
	}
}

func StartCronJob() {
	c := task.GetCronTask()
	live_handler.NewCronJob(c)
	ktv_handler.NewCronJob(c)
	owc_handler.NewCronJob(c)
	c.Start()
}
