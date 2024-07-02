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
	"strconv"

	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
)

type GetPresetSongListResp struct {
	Artist       string `json:"artist"`
	CoverUrl     string `json:"cover_url"`
	SongDuration int    `json:"song_duration"`
	SongLrcUrl   string `json:"song_lrc_url"`
	SongFileUrl  string `json:"song_file_url"`
	SongId       string `json:"song_id"`
	SongName     string `json:"song_name"`
}

func GetPreSetSongList(ctx *gin.Context) (interface{}, error) {

	songList, err := owc_service.GetPresetSongRepo().OwcGetPresetSong(ctx)
	if err != nil {
		logs.CtxError(ctx, "get song list failed,error:%s", err)
		return nil, err
	}

	resp := make([]*GetPresetSongListResp, 0)
	for _, s := range songList {
		resp = append(resp, &GetPresetSongListResp{
			Artist:       s.Artist,
			CoverUrl:     s.CoverUrl,
			SongDuration: s.Duration,
			SongLrcUrl:   s.SongLrcUrl,
			SongFileUrl:  s.SongFileUrl,
			SongId:       strconv.Itoa(s.SongId),
			SongName:     s.Name,
		})
	}
	return map[string][]*GetPresetSongListResp{"song_list": resp}, nil
}
