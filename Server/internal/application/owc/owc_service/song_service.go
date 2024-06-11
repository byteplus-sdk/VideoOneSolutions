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

package owc_service

import (
	"context"
	"errors"

	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_entity"
	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_redis"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/inform"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli/lock"

	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

const (
	SingleSingType string = "1"
	ManySingType   string = "2"
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
		OwcSong: &owc_entity.OwcSong{
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
	ss.songFactory.songRepo.SetUser(ctx, roomID, song.OwcSong, "")

	informer := inform.GetInformService(appID)
	data := &InformRequestSong{
		Song:      song,
		SongCount: len(songList) + 1,
		UserID:    userID,
	}
	informer.BroadcastRoom(ctx, roomID, OnRequestSong, data)

	if len(songList) == 0 {
		waitSingMessage := &InformWaitSing{
			Song:       song,
			UserId:     userID,
			LeaderUser: user,
		}
		informer.BroadcastRoom(ctx, roomID, OnWaitSing, waitSingMessage)
	}

	return nil
}

func (ss *SongService) start(ctx context.Context, appID, roomID string, operaUser, otherUser string) error {
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
	ss.songFactory.songRepo.SetUser(ctx, roomID, song.OwcSong, otherUser)
	leaderUser, err := ss.userFactory.GetActiveUserByRoomIDUserID(ctx, appID, roomID, song.GetOwnerUserID())
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return err
	}
	succentorUser, err := ss.userFactory.GetActiveUserByRoomIDUserID(ctx, appID, roomID, otherUser)
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return err
	}
	data := &InformStartSing{
		Song:          song,
		LeaderUser:    leaderUser,
		SuccentorUser: succentorUser,
		UserId:        operaUser,
	}
	informer.BroadcastRoom(ctx, roomID, OnStartSing, data)

	return nil

}

func (ss *SongService) StartSing(ctx context.Context, appID, roomID, userID, singType string, curSong *Song) (*Song, error) {
	ok, lt := ss.lock(ctx, roomID)
	defer ss.unlock(ctx, roomID, lt)
	if !ok {
		return nil, custom_error.InternalError(errors.New("song lock failed"))
	}
	if singType == SingleSingType {
		onerUser := curSong.OwnerUserID
		if onerUser != userID {
			logs.CtxInfo(ctx, "start sing found error")
			return nil, custom_error.ErrStartSingError
		}
		err := ss.start(ctx, appID, roomID, userID, "")
		if err != nil {
			return nil, err
		}
		return curSong, nil
	} else {
		onerUser := curSong.OwnerUserID
		if onerUser == userID {
			logs.CtxInfo(ctx, "start sing found error")
			return nil, custom_error.ErrStartSingError
		}
		err := ss.start(ctx, appID, roomID, userID, userID)
		if err != nil {
			return nil, err
		}
		return curSong, nil
	}

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
	//ss.songFactory.songRepo.DelUser(ctx, roomID, song.OwcSong)
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
		NextSong: nextSong,
	}
	informer.BroadcastRoom(ctx, roomID, OnFinishSing, data)

	return nextSong, nil
}

func (ss *SongService) CutOffSong(ctx context.Context, appID, roomID, userID string) error {
	ok, lt := ss.lock(ctx, roomID)
	defer ss.unlock(ctx, roomID, lt)
	if !ok {
		return custom_error.InternalError(errors.New("song lock failed"))
	}

	informer := inform.GetInformService(appID)

	for {
		preSong, err := ss.songFactory.Pop(ctx, roomID)
		if err != nil {
			logs.CtxError(ctx, "pop failed,error:%s", err)
			return err
		}
		ss.songFactory.songRepo.DelUser(ctx, roomID, preSong.OwcSong)
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
		if user != nil {
			break
		}
	}
	curSong, err := ss.GetCurSong(ctx, roomID)
	if err != nil {
		return err
	}
	if curSong == nil {
		logs.CtxInfo(ctx, "song list is empty")
		waitSingData := InformWaitSing{
			Song:       nil,
			UserId:     userID,
			LeaderUser: nil,
		}
		informer.BroadcastRoom(ctx, roomID, OnWaitSing, waitSingData)
		return nil
	}
	user, err := ss.userFactory.GetActiveUserByRoomIDUserID(ctx, appID, curSong.GetRoomID(), curSong.GetOwnerUserID())
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return err
	}
	if user == nil {
		for {
			curSong, err = ss.GetCurSong(ctx, roomID)
			if err != nil {
				logs.CtxError(ctx, "get cur song ,error:%s", err)
				return err
			}
			if curSong == nil {
				logs.CtxInfo(ctx, "get cur song nil")
				logs.CtxInfo(ctx, "song list is empty")
				waitSingData := InformWaitSing{
					Song:       nil,
					UserId:     userID,
					LeaderUser: nil,
				}
				informer.BroadcastRoom(ctx, roomID, OnWaitSing, waitSingData)
				return nil
			}
			if curSong.OwnerUserID == userID {
				preSong, err := ss.songFactory.Pop(ctx, roomID)
				if err != nil {
					logs.CtxError(ctx, "pop failed,error:%s", err)
					return err
				}
				ss.songFactory.songRepo.DelUser(ctx, roomID, preSong.OwcSong)
				if err != nil {
					logs.CtxError(ctx, "cut off song ,error:%s", err)
				}
			} else {
				break
			}
		}
	}
	waitSingData := InformWaitSing{
		Song:       curSong,
		UserId:     userID,
		LeaderUser: user,
	}
	informer.BroadcastRoom(ctx, roomID, OnWaitSing, waitSingData)
	//err := ss.start(ctx, roomID)
	//if err != nil {
	//	return err
	//}

	return nil
}

func (ss *SongService) GetSongSingUser(ctx context.Context, roomID string, song *Song) (*owc_redis.OwcSongSingUser, error) {
	owcSongSingUser, err := ss.songFactory.songRepo.GetUser(ctx, roomID, song.OwcSong)
	if err != nil {
		logs.CtxError(ctx, "get song user info error:"+err.Error())
		return nil, err
	}
	logs.CtxInfo(ctx, "singUser:%s", owcSongSingUser)
	return owcSongSingUser, nil
}

func (ss *SongService) GetRequestSongList(ctx context.Context, roomID string) ([]*Song, error) {
	return ss.songFactory.GetSongListByRoomID(ctx, roomID)
}

func (ss *SongService) GetCurSong(ctx context.Context, roomID string) (*Song, error) {
	return ss.songFactory.Top(ctx, roomID)
}
func (ss *SongService) GetNextSong(ctx context.Context, roomID string) (*Song, error) {
	return ss.songFactory.LIndex(ctx, roomID, 1)
}

func (ss *SongService) lock(ctx context.Context, roomID string) (bool, int64) {
	return lock.LockOwcRoom(ctx, roomID)
}

func (ss *SongService) unlock(ctx context.Context, roomID string, lt int64) {
	lock.UnlockOwcRoom(ctx, roomID, lt)
}
