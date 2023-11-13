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
	"context"
	"encoding/json"
	"errors"
	"strconv"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_handler"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_handler"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/endpoint"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli"
	"github.com/go-redis/redis/v8"
)

const (
	interval             = 10 * time.Second
	requests         int = 10000
	TrafficKeyPrefix     = "traffic:app_id:"
)

type EventHandlerDispatch struct {
	mws      []endpoint.Middleware
	eps      endpoint.Endpoint
	handlers map[string]endpoint.Endpoint
}

func NewEventHandlerDispatch() *EventHandlerDispatch {
	ehd := &EventHandlerDispatch{
		mws:      make([]endpoint.Middleware, 0),
		handlers: make(map[string]endpoint.Endpoint),
	}
	ehd.init()
	return ehd
}

func (ehd *EventHandlerDispatch) Handle(ctx context.Context, params *public.EventParam) (resp interface{}, err error) {
	return ehd.eps(ctx, params)
}

func (ehd *EventHandlerDispatch) init() {
	ehd.initHandlers()
	ehd.initMws()
	ehd.buildInvokeChain()
}

func (ehd *EventHandlerDispatch) initHandlers() {
	//disconnect
	ehd.register("disconnect", disconnectHandler)

	//login
	loginHandler := login_handler.NewEventHandler()
	ehd.register("passwordFreeLogin", loginHandler.PasswordFreeLogin)
	ehd.register("verifyLoginToken", loginHandler.VerifyLoginToken)
	ehd.register("changeUserName", loginHandler.ChangeUserName)
	ehd.register("joinRTS", loginHandler.JoinRts)

	liveHandler := live_handler.NewEventHandler()
	ehd.register("liveCreateLive", liveHandler.CreateLive)
	ehd.register("liveStartLive", liveHandler.StartLive)
	ehd.register("liveFinishLive", liveHandler.FinishLive)
	ehd.register("liveJoinLiveRoom", liveHandler.JoinLiveRoom)
	ehd.register("liveLeaveLiveRoom", liveHandler.LeaveLiveRoom)
	ehd.register("liveGetActiveLiveRoomList", liveHandler.GetActiveLiveRoomList)
	ehd.register("liveGetActiveAnchorList", liveHandler.GetActiveAnchorList)
	ehd.register("liveGetAudienceList", liveHandler.GetAudienceList)
	ehd.register("liveUpdateResolution", liveHandler.UpdateResolution)
	ehd.register("liveUpdateMediaStatus", liveHandler.UpdateMediaStatus)
	ehd.register("liveReconnect", liveHandler.Reconnect)
	ehd.register("liveAudienceLinkmicInvite", liveHandler.AudienceLinkmicInvite)
	ehd.register("liveAudienceLinkmicPermit", liveHandler.AudienceLinkmicPermit)
	ehd.register("liveAudienceLinkmicApply", liveHandler.AudienceLinkmicApply)
	ehd.register("liveAudienceLinkmicReply", liveHandler.AudienceLinkmicReply)
	ehd.register("liveAudienceLinkmicKick", liveHandler.AudienceLinkmicKick)
	ehd.register("liveAudienceLinkmicLeave", liveHandler.AudienceLinkmicLeave)
	ehd.register("liveAudienceLinkmicCancel", liveHandler.AudienceLinkmicCancel)
	ehd.register("liveAudienceLinkmicFinish", liveHandler.AudienceLinkmicFinish)
	ehd.register("liveAnchorLinkmicInvite", liveHandler.AnchorLinkmicInvite)
	ehd.register("liveAnchorLinkmicReply", liveHandler.AnchorLinkmicReply)
	ehd.register("liveAnchorLinkmicFinish", liveHandler.AnchorLinkmicFinish)
	ehd.register("liveManageGuestMedia", liveHandler.ManageGuestMedia)
	ehd.register("liveClearUser", liveHandler.ClearUser)
	ehd.register("liveSendMessage", liveHandler.SendMessage)
}

func (ehd *EventHandlerDispatch) register(eventName string, handlerFunc endpoint.Endpoint) {
	ehd.handlers[eventName] = handlerFunc
}

func (ehd *EventHandlerDispatch) initMws() {
	ehd.mws = append(ehd.mws, mwCheckParam)
	ehd.mws = append(ehd.mws, mwCheckLogin)
	ehd.mws = append(ehd.mws, mwCheckLimitTraffic)
}

func (ehd *EventHandlerDispatch) buildInvokeChain() {
	handler := ehd.invokeHandleEndpoint()
	ehd.eps = endpoint.Chain(ehd.mws...)(handler)
}

func (ehd *EventHandlerDispatch) invokeHandleEndpoint() endpoint.Endpoint {
	return func(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
		f, ok := ehd.handlers[param.EventName]
		if !ok {
			return nil, custom_error.InternalError(errors.New("event not exist"))
		}
		return f(ctx, param)
	}
}

func mwCheckParam(next endpoint.Endpoint) endpoint.Endpoint {
	return func(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
		sourceApi, _ := ctx.Value(public.CtxSourceApi).(string)
		switch sourceApi {
		case "http":
			if param.EventName == "" || param.Content == "" || param.DeviceID == "" {
				if param.EventName == "disconnect" || param.EventName == "recordCallBack" || param.EventName == "sendLoginSms" || param.EventName == "verifyLoginSms" {
					return next(ctx, param)
				}
				return nil, custom_error.ErrInput
			}
		case "rtm", "rts":
			if param.AppID == "" || param.UserID == "" || param.EventName == "" || param.Content == "" || param.DeviceID == "" {
				return nil, custom_error.ErrInput
			}
			appInfoService := login_service.GetAppInfoService()
			_, err := appInfoService.ReadAppInfoByAppId(ctx, param.AppID)
			if err != nil {
				return nil, err
			}
		case "http_response":
			if param.AppID == "" || param.UserID == "" || param.EventName == "" || param.Content == "" || param.DeviceID == "" {
				return nil, custom_error.ErrInput
			}
			appInfoService := login_service.GetAppInfoService()
			_, err := appInfoService.ReadAppInfoByAppId(ctx, param.AppID)
			if err != nil {
				return nil, err
			}

		default:
			return nil, custom_error.InternalError(errors.New("source api missing"))
		}
		logs.CtxInfo(ctx, "check param info pass")
		return next(ctx, param)
	}

}

type checkParam struct {
	LoginToken string `json:"login_token"`
}

func mwCheckLimitTraffic(next endpoint.Endpoint) endpoint.Endpoint {
	return func(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
		if param.EventName == "coFlushTraffic" {
			return next(ctx, param)
		}
		appID := param.AppID
		if appID == "" {
			logs.CtxInfo(ctx, "appID is empty:%s", param)
			return next(ctx, param)
		}
		exist, err := ExistTrafficAppID(ctx, appID)
		if err != nil {
			logs.CtxError(ctx, "check traffic err:%s", err)
			return nil, custom_error.ErrCheckTrafficAppID
		}
		key := TrafficKey(ctx, appID)
		if exist {
			val, err := strconv.Atoi(redis_cli.Client.Get(ctx, key).Val())
			duration := redis_cli.Client.TTL(ctx, key).Val()
			logs.CtxInfo(ctx, "check appID:%s,duration:%s,traffic:%s", appID, duration.String(), val)
			if duration.Seconds() == -1 {
				logs.CtxInfo(ctx, "set key expire")
				redis_cli.Client.Expire(ctx, key, interval)
			}
			if err != nil {
				logs.CtxError(ctx, "check traffic err:%s", err)
				return nil, custom_error.ErrCheckTrafficAppID
			}
			if val > requests {
				logs.CtxInfo(ctx, "check traffic up top")
				return nil, custom_error.ErrCheckTrafficUpLimit
			} else {
				redis_cli.Client.Incr(ctx, key)
			}
		} else {
			redis_cli.Client.Set(ctx, key, 0, 0)
			redis_cli.Client.Expire(ctx, key, interval)
		}
		logs.CtxInfo(ctx, "check traffic info pass")
		return next(ctx, param)
	}
}

func ExistTrafficAppID(ctx context.Context, appID string) (bool, error) {
	key := TrafficKey(ctx, appID)
	val, err := redis_cli.Client.Exists(ctx, key).Result()
	switch err {
	case nil:
		return val == 1, nil
	case redis.Nil:
		return false, nil
	default:
		return false, err
	}
}

func TrafficKey(ctx context.Context, key string) string {
	return TrafficKeyPrefix + key
}

func mwCheckLogin(next endpoint.Endpoint) endpoint.Endpoint {
	return func(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
		userService := login_service.GetUserService()
		sourceApi, _ := ctx.Value(public.CtxSourceApi).(string)
		switch sourceApi {
		case "rtm", "http_response":
			p := &checkParam{}
			err = json.Unmarshal([]byte(param.Content), p)
			if err != nil {
				logs.CtxError(ctx, "json unmarshal failed,error:%s", err)
				return nil, custom_error.InternalError(err)
			}
			err = userService.CheckLoginToken(ctx, p.LoginToken)
			if err != nil {
				logs.CtxError(ctx, "login_token expired")
				return nil, err
			}
			loginUserID := userService.GetUserID(ctx, p.LoginToken)
			logs.CtxInfo(ctx, "get loginToken userid:%s", loginUserID)
			if loginUserID != param.UserID {
				return nil, custom_error.ErrorTokenUserNotMatch
			}
			logs.CtxInfo(ctx, "check login info pass")
		}

		return next(ctx, param)
	}
}
