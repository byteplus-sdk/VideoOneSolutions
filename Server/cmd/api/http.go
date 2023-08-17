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

package api

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/byteplus/VideoOneServer/cmd/handler"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/models/response"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/rtc_openapi"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"github.com/gin-gonic/gin"
)

type HttpApi struct {
	r          *gin.Engine
	dispatcher *handler.EventHandlerDispatch
	Port       string
}

func NewHttpApi(dispatcher *handler.EventHandlerDispatch) *HttpApi {
	api := &HttpApi{}
	api.r = gin.Default()
	api.r.Use(Cors())
	api.dispatcher = dispatcher
	api.Port = config.Configs().Port
	return api
}

func (api *HttpApi) Run() error {
	rr := api.r.Group("/videoone_opensource")
	rr.GET("/ping", api.PingPong)
	rr.POST("/login", api.HandleHttpLoginEvent)
	rr.POST("/rts", api.HandleRtsOpenApiEvent)
	rr.POST("/rts_callback", api.HandleRtsCallback)
	rr.POST("/http_response", api.HandleHttpResponseEvent)
	return api.r.Run(fmt.Sprintf("0.0.0.0:%s", api.Port))
}

func (api *HttpApi) PingPong(ctx *gin.Context) {
	logs.CtxInfo(ctx, "receive ping request")
	ctx.JSON(200, map[string]string{
		"message": "pong",
	})
}

func (api *HttpApi) HandleHttpLoginEvent(httpCtx *gin.Context) {
	ctx := util.EnsureID(httpCtx)
	ctx = context.WithValue(ctx, public.CtxSourceApi, "http")

	p := &public.EventParam{}
	err := httpCtx.BindJSON(p)
	if err != nil {
		logs.CtxError(ctx, "param error,err:%s", err)
		httpCtx.String(400, "param error")
		return
	}
	logs.CtxInfo(ctx, "handle http,param:%#v", p)
	resp, err := api.dispatcher.Handle(ctx, p)
	if err != nil {
		logs.CtxError(ctx, "handle error,param:%#v,err:%s", p, err)
	}

	httpCtx.String(200, response.NewCommonResponse(ctx, "", resp, err))
	return
}

func (api *HttpApi) HandleRtsOpenApiEvent(httpCtx *gin.Context) {
	defer httpCtx.String(200, "ok")
	ctx := util.EnsureID(httpCtx)
	logs.CtxInfo(ctx, "get logid:%s", util.RetrieveID(ctx))
	ctx = context.WithValue(ctx, public.CtxSourceApi, "rtm")

	p := &RtsParam{}
	err := httpCtx.BindJSON(p)
	if err != nil {
		logs.CtxError(ctx, "param error,err:%s", err)
		return
	}
	pp := &public.EventParam{}
	err = json.Unmarshal([]byte(p.Message), pp)
	if err != nil {
		logs.CtxError(ctx, "param error,err:%s", err)
		rtsReturn(ctx, pp.AppID, pp.RoomID, pp.UserID, pp.RequestID, nil, err)
		return
	}
	logs.CtxInfo(ctx, "handle rts, param:%#v", pp)

	go func(ctx context.Context, param *public.EventParam) {
		util.CheckPanic()
		resp, err := api.dispatcher.Handle(ctx, param)
		if err != nil {
			logs.CtxError(ctx, "handle error,param:%#v,err:%s", param, err)
		}
		rtsReturn(ctx, param.AppID, param.RoomID, param.UserID, param.RequestID, resp, err)
	}(ctx, pp)

}

func rtsReturn(ctx context.Context, appID, roomID, userID, requestID string, resp interface{}, err error) {
	instance := rtc_openapi.GetInstance(ctx, appID)
	err = instance.RtsSendUnicast(ctx, appID, userID, response.NewCommonResponse(ctx, requestID, resp, err))
	if err != nil {
		logs.CtxError(ctx, "send to rts failed,error:%s", err)
	}
}

func (api *HttpApi) HandleRtsCallback(httpCtx *gin.Context) {
	defer httpCtx.String(200, "ok")

	ctx := util.EnsureID(httpCtx)
	ctx = context.WithValue(ctx, public.CtxSourceApi, "http")

	p := &RtsCallbackParam{}
	err := httpCtx.BindJSON(p)
	if err != nil {
		logs.CtxError(ctx, "param error,err:%s", err)
		return
	}

	pp := &public.EventParam{}

	switch p.EventType {
	case "UserLeaveRoom":
		eventData := &EventDataLeaveRoom{}
		err = json.Unmarshal([]byte(p.EventData), eventData)
		if err != nil {
			logs.CtxError(ctx, "param error,err:%s", err)
			return
		}
		if eventData.Reason != LeaveRoomReasonConnectionLost {
			return
		}
		pp.AppID = p.AppId
		pp.RoomID = eventData.RoomId
		pp.UserID = eventData.UserId
		pp.EventName = "disconnect"
	case "InvisibleUserLeaveRoom":
		eventData := &EventDataLeaveRoom{}
		err = json.Unmarshal([]byte(p.EventData), eventData)
		if err != nil {
			logs.CtxError(ctx, "param error,err:%s", err)
			return
		}
		if eventData.Reason != LeaveRoomReasonConnectionLost {
			return
		}
		pp.AppID = p.AppId
		pp.RoomID = eventData.RoomId
		pp.UserID = eventData.UserId
		pp.EventName = "disconnect"
	case "RecordStopped":
		pp.AppID = p.AppId
		pp.Content = p.EventData
		pp.EventName = "recordCallBack"
	}

	logs.CtxInfo(ctx, "handle rts callback,param:%#v", pp)
	_, err = api.dispatcher.Handle(ctx, pp)
	if err != nil {
		logs.CtxError(ctx, "handle error,param:%#v,err:%s", p, err)
	}

}

func Cors() gin.HandlerFunc {
	return func(c *gin.Context) {
		method := c.Request.Method
		origin := c.Request.Header.Get("Origin")
		if origin != "" {
			c.Header("Access-Control-Allow-Origin", "*")
			c.Header("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE, UPDATE")
			c.Header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization")
			c.Header("Access-Control-Expose-Headers", "Content-Length, Access-Control-Allow-Origin, Access-Control-Allow-Headers, Cache-Control, Content-Language, Content-Type")
			c.Header("Access-Control-Allow-Credentials", "true")
		}

		if method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
		}

	}
}

func (api *HttpApi) HandleHttpResponseEvent(httpCtx *gin.Context) {
	ctx := util.EnsureID(httpCtx)
	ctx = context.WithValue(ctx, public.CtxSourceApi, "http_response")

	p := &RtsParam{}
	err := httpCtx.BindJSON(p)
	if err != nil {
		logs.CtxError(ctx, "param error,err:%s", err)
		return
	}
	pp := &public.EventParam{}
	err = json.Unmarshal([]byte(p.Message), pp)
	if err != nil {
		logs.CtxError(ctx, "param error,err:%s", err)
		httpCtx.String(400, "param error")
		return
	}

	logs.CtxInfo(ctx, "handle http,param:%#v", pp)
	resp, err := api.dispatcher.Handle(ctx, pp)
	if err != nil {
		logs.CtxError(ctx, "handle error,param:%#v,err:%s", pp, err)
	}

	httpCtx.String(200, response.NewCommonResponse(ctx, "", resp, err))
	return
}
