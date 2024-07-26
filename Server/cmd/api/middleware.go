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

package api

import (
	"net/http"
	"net/http/httputil"

	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/models/response"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

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

func LogHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		dump, err := httputil.DumpRequest(c.Request, true)
		if err != nil {
			logs.CtxError(c, "http dump error: "+err.Error())
		} else {
			logs.CtxInfo(c, "Receive HTTP Request: \n"+string(dump))
		}
	}
}

func CheckLoginToken() gin.HandlerFunc {
	return func(ctx *gin.Context) {
		loginToken := ctx.GetHeader(public.HeaderLoginToken)
		userService := login_service.GetUserService()
		err := userService.CheckLoginToken(ctx, loginToken)
		if err != nil {
			ctx.String(200, response.NewCommonResponse(ctx, "", "", err))
			ctx.Abort()
			return
		}

		var u struct {
			UserID string `json:"user_id"`
		}
		if err = ctx.ShouldBindBodyWith(&u, binding.JSON); err != nil {
			logs.CtxError(ctx, "json parse error:"+err.Error())
			ctx.String(200, response.NewCommonResponse(ctx, "", "", custom_error.InternalError(err)))
			ctx.Abort()
			return
		}
		if u.UserID == "" {
			logs.CtxWarn(ctx, "user id is empty")
		} else {
			if userService.GetUserID(ctx, loginToken) != u.UserID {
				logs.CtxError(ctx, "login_token expired")
				ctx.String(200, response.NewCommonResponse(ctx, "", "", custom_error.ErrorTokenUserNotMatch))
				ctx.Abort()
				return
			}
		}

		logs.CtxInfo(ctx, "check login info pass")
		ctx.Next()
	}
}
