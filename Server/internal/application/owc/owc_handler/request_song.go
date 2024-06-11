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
	"context"
	"encoding/json"

	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"

	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type requestSongReq struct {
	UserID       string  `json:"user_id"`
	RoomID       string  `json:"room_id"`
	SongID       string  `json:"song_id"`
	SongName     string  `json:"song_name"`
	SongDuration float64 `json:"song_duration"`
	CoverUrl     string  `json:"cover_url"`
	LoginToken   string  `json:"login_token"`
}

type requestSongResp struct {
}

func (eh *EventHandler) RequestSong(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "owcFinishLive param:%+v", param)
	var p requestSongReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	if p.UserID == "" || p.RoomID == "" || p.SongID == "" || p.SongName == "" {
		logs.CtxError(ctx, "input error, param:%v", p)
		return nil, custom_error.ErrInput
	}

	userFactory := owc_service.GetUserFactory()

	user, err := userFactory.GetActiveUserByRoomIDUserID(ctx, param.AppID, p.RoomID, p.UserID)
	if err != nil || user == nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return nil, custom_error.ErrUserIsInactive
	}

	songService := owc_service.GetSongService()
	err = songService.RequestSong(ctx, param.AppID, p.RoomID, p.UserID, p.SongID, p.SongName, p.CoverUrl, p.SongDuration)
	if err != nil {
		return nil, err
	}

	return nil, nil

}
