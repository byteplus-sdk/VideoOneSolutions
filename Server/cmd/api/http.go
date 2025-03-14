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
	"fmt"

	"github.com/byteplus/VideoOneServer/cmd/handler"
	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_handler"
	"github.com/byteplus/VideoOneServer/internal/application/live_feed/live_feed_handler"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_handler"
	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_handler"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/gin-gonic/gin"
)

type HttpApi struct {
	r    *gin.Engine
	Port string
}

func NewHttpApi() *HttpApi {
	api := &HttpApi{}
	api.r = gin.Default()
	api.r.Use(Cors())
	api.r.Use(LogHandler())
	api.Port = config.Configs().Port
	return api
}

func (api *HttpApi) Run() error {
	rr := api.r.Group("/videoone_opensource")

	rr.GET("/ping", handler.PingPong)

	rr.POST("/passwordFreeLogin", login_handler.PasswordFreeLogin)
	rr.POST("/http_call", CheckLoginToken(), handler.HandleHttpCallEvent)
	rr.POST("/getRTCJoinRoomToken", handler.HandleGetRTCJoinRoomToken)
	rr.POST("/rts_callback", handler.HandleRtsCallback)

	//vod
	{
		vod := rr.Group("/vod")
		vod.POST("/v1/getFeedStreamWithPlayAuthToken", vod_handler.GetFeedStreamWithPlayAuthToken)
		vod.POST("/v1/getFeedStreamWithVideoModel", vod_handler.GetFeedStreamWithVideoModel)
		vod.GET("/v1/upload", vod_handler.GenUploadToken)
		vod.GET("/v1/getVideoComments", vod_handler.GetVideoComments)
		vod.POST("/v1/getFeedSimilarVideos", vod_handler.GetFeedSimilarVideos)
		vod.POST("/v1/getPlayListDetail", vod_handler.GetPlayListDetail)
	}
	// liveFeed
	{
		liveFeed := rr.Group("/liveFeed")
		liveFeed.POST("/v1/getFeedStreamWithLive", live_feed_handler.GetFeedStreamWithLive)
		liveFeed.POST("/v1/getFeedStreamOnlyLive", live_feed_handler.GetFeedStreamOnlyLive)
		liveFeed.POST("/v1/switchFeedLiveRoom", live_feed_handler.SwitchFeedStreamRoom)
		liveFeed.POST("/v1/liveSendMessage", live_feed_handler.SendMessage)
	}
	// drama
	{
		liveFeed := rr.Group("/drama")
		liveFeed.POST("/v1/getDramaChannel", drama_handler.GetDramaChannel)
		liveFeed.POST("/v1/getDramaFeed", drama_handler.GetDramaFeed)
		liveFeed.POST("/v1/getDramaList", drama_handler.GetDramaList)
		liveFeed.POST("/v1/getDramaDetail", drama_handler.GetDramaDetail)
		liveFeed.GET("/v1/getVideoComments", drama_handler.GetVideoComments)
	}
	return api.r.Run(fmt.Sprintf("0.0.0.0:%s", api.Port))
}
