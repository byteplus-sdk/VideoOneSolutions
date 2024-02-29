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

package ktv_service

import (
	"context"
	"errors"

	"github.com/byteplus/VideoOneServer/internal/pkg/inform"

	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_entity"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli/lock"

	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

var songServiceClient *SongService

type SongService struct {
	songFactory *SongFactory
	userFactory *UserFactory
}

func GetSongService() *SongService {
	if songServiceClient == nil {
		songServiceClient = &SongService{
			songFactory: GetSongFactory(),
			userFactory: GetUserFactory(),
		}
	}
	return songServiceClient
}

func (ss *SongService) RequestSong(ctx context.Context, appID, roomID, userID, songID, songName, coverUrl string, songDuration float64) error {
	ok, lt := ss.lock(ctx, roomID)
	defer ss.unlock(ctx, roomID, lt)
	if !ok {
		return custom_error.InternalError(errors.New("song lock failed"))
	}

	songList, err := ss.GetRequestSongList(ctx, roomID)
	if err != nil {
		logs.CtxError(ctx, "get song list failed,error:%s", err)
		return err
	}

	isRepeat := false
	for _, song := range songList {
		if song.GetOwnerUserID() == userID && song.GetSongID() == songID {
			isRepeat = true
			break
		}
	}
	if isRepeat {
		logs.CtxError(ctx, "request song repeat")
		return custom_error.ErrRequestSongRepeat
	}

	user, err := ss.userFactory.GetActiveUserByRoomIDUserID(ctx, appID, roomID, userID)
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return err
	}
	song := &Song{
		KtvSong: &ktv_entity.KtvSong{
			SongID:        songID,
			SongName:      songName,
			RoomID:        roomID,
			OwnerUserID:   userID,
			OwnerUserName: user.GetUserName(),
			SongDuration:  songDuration,
			CoverUrl:      coverUrl,
			Status:        SongStatusWaiting,
		},
		isDirty: true,
	}
	err = ss.songFactory.Push(ctx, roomID, song)
	if err != nil {
		logs.CtxError(ctx, "push song failed,error:%s", err)
		return err
	}

	informer := inform.GetInformService(appID)
	data := &InformRequestSong{
		Song:      song,
		SongCount: len(songList) + 1,
	}
	informer.BroadcastRoom(ctx, roomID, OnRequestSong, data)

	//first, cut song
	if len(songList) == 0 {
		err = ss.start(ctx, appID, roomID)
		if err != nil {
			return err
		}
	}

	return nil
}

func (ss *SongService) start(ctx context.Context, appID, roomID string) error {
	song, err := ss.songFactory.Top(ctx, roomID)
	if err != nil {
		logs.CtxError(ctx, "get top song failed,error:%s", err)
		return err
	}

	if song != nil {
		song.Start()
		err = ss.songFactory.UpdateTop(ctx, roomID, song)
		if err != nil {
			logs.CtxError(ctx, "update top song failed,error:%s", err)
			return err
		}
	}

	informer := inform.GetInformService(appID)
	data := &InformStartSing{
		Song: song,
	}
	informer.BroadcastRoom(ctx, roomID, OnStartSing, data)

	return nil

}

func (ss *SongService) FinishSing(ctx context.Context, appID, roomID string, score float64) (*Song, error) {
	ok, lt := ss.lock(ctx, roomID)
	defer ss.unlock(ctx, roomID, lt)
	if !ok {
		return nil, custom_error.InternalError(errors.New("song lock failed"))
	}

	song, err := ss.songFactory.Top(ctx, roomID)
	if err != nil || song == nil {
		logs.CtxError(ctx, "get song failed,error:%s", err)
		return nil, custom_error.InternalError(err)
	}

	song.Finish()
	err = ss.songFactory.UpdateTop(ctx, roomID, song)
	if err != nil {
		logs.CtxError(ctx, "update top song failed,error:%s", err)
		return nil, err
	}

	nextSong, err := ss.songFactory.LIndex(ctx, roomID, 1)
	if err != nil {
		logs.CtxError(ctx, "get song failed,error:%s", err)
		return nil, err
	}

	informer := inform.GetInformService(appID)
	data := &InformFinishSing{
		Score:    score,
		NextSong: nextSong,
		CurSong:  song,
	}
	informer.BroadcastRoom(ctx, roomID, OnFinishSing, data)

	return nextSong, nil
}

func (ss *SongService) CutOffSong(ctx context.Context, appID, roomID string) error {
	ok, lt := ss.lock(ctx, roomID)
	defer ss.unlock(ctx, roomID, lt)
	if !ok {
		return custom_error.InternalError(errors.New("song lock failed"))
	}

	for {
		_, err := ss.songFactory.Pop(ctx, roomID)
		if err != nil {
			logs.CtxError(ctx, "pop failed,error:%s", err)
			return err
		}
		song, err := ss.songFactory.Top(ctx, roomID)
		if err != nil {
			logs.CtxError(ctx, "get top song failed,error:%s", err)
			return err
		}
		if song == nil {
			break
		}
		user, err := ss.userFactory.GetActiveUserByRoomIDUserID(ctx, appID, song.GetRoomID(), song.GetOwnerUserID())
		if err != nil {
			logs.CtxError(ctx, "get user failed,error:%s", err)
			return err
		}
		if user != nil && (user.IsInteract() || user.IsHost()) {
			break
		}
	}

	err := ss.start(ctx, appID, roomID)
	if err != nil {
		return err
	}

	return nil
}

func (ss *SongService) GetRequestSongList(ctx context.Context, roomID string) ([]*Song, error) {
	return ss.songFactory.GetSongListByRoomID(ctx, roomID)
}

func (ss *SongService) GetCurSong(ctx context.Context, roomID string) (*Song, error) {
	return ss.songFactory.Top(ctx, roomID)
}

func (ss *SongService) lock(ctx context.Context, roomID string) (bool, int64) {
	return lock.LockKtvRoomSong(ctx, roomID)
}

func (ss *SongService) unlock(ctx context.Context, roomID string, lt int64) {
	lock.UnlockKtvRoomSong(ctx, roomID, lt)
}
