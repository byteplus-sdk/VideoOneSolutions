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

package owc_handler

import (
	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type getRequestSongReq struct {
	AppID  string `json:"app_id" binding:"required"`
	RoomID string `json:"room_id" binding:"required"`
}

type getRequestSongResp struct {
	SongList []*owc_service.Song `json:"song_list"`
}

func GetRequestSongList(ctx *gin.Context) (resp interface{}, err error) {
	var p getRequestSongReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}
	songService := owc_service.GetSongService()

	songList, err := songService.GetRequestSongList(ctx, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get song list failed,error:%s", err)
		return nil, err
	}

	resp = &getRequestSongResp{
		SongList: songList,
	}

	return resp, nil
}
