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
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_db"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/inform"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

const (
	FinishTypeNormal        = 1
	FinishTypeTimeout       = 2
	FinishTypeReviewIllegal = 3
)

var roomServiceClient *RoomService

type SeatInfo struct {
	Status    int   `json:"status"`
	GuestInfo *User `json:"guest_info"`
}

type RoomService struct {
	roomFactory *RoomFactory
	userFactory *UserFactory
}

func GetRoomService() *RoomService {
	if roomServiceClient == nil {
		roomServiceClient = &RoomService{
			roomFactory: GetRoomFactory(),
			userFactory: GetUserFactory(),
		}
	}
	return roomServiceClient
}

func (rs *RoomService) CreateRoom(ctx context.Context, appID, roomName, roomBackgroundImageName, hostUserID, hostUserName, hostDeviceID string) (*Room, *User, error) {
	room, err := rs.roomFactory.NewRoom(ctx, appID, roomName, roomBackgroundImageName, hostUserID, hostUserName)
	if err != nil || room == nil {
		logs.CtxError(ctx, "create room failed,error:%s", err)
		return nil, nil, custom_error.InternalError(errors.New("create room failed"))
	}
	logs.CtxInfo(ctx, "room:%#v", room.GetDbRoom())
	err = rs.roomFactory.Save(ctx, room)
	if err != nil {
		logs.CtxError(ctx, "save room failed,error:%s", err)
		return nil, nil, err
	}

	host := rs.userFactory.NewUser(ctx, appID, room.GetRoomID(), hostUserID, hostUserName, hostDeviceID, owc_db.UserRoleHost)
	err = rs.userFactory.Save(ctx, host)
	if err != nil {
		return nil, nil, err
	}

	return room, host, nil
}

func (rs *RoomService) StartLive(ctx context.Context, appID, roomID string) error {
	room, err := rs.roomFactory.GetRoomByRoomID(ctx, appID, roomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		return custom_error.InternalError(err)
	}
	if room == nil {
		logs.CtxError(ctx, "room is not exist")
		return custom_error.ErrRoomNotExist
	}

	room.Start()
	err = rs.roomFactory.Save(ctx, room)
	if err != nil {
		logs.CtxError(ctx, "save room failed,error:%s", err)
		return custom_error.InternalError(err)
	}

	host, err := rs.userFactory.GetUserByRoomIDUserID(ctx, appID, room.GetRoomID(), room.GetHostUserID())
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return err
	}
	if host == nil {
		logs.CtxError(ctx, "user is not exist")
		return custom_error.ErrUserNotExist
	}

	host.StartLive()
	err = rs.userFactory.Save(ctx, host)
	if err != nil {
		return err
	}

	return nil
}

func (rs *RoomService) FinishLive(ctx context.Context, appID, roomID string, finishType int) error {
	room, err := rs.roomFactory.GetRoomByRoomID(ctx, appID, roomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		return custom_error.InternalError(err)
	}
	if room == nil {
		logs.CtxError(ctx, "room is not exist")
		return custom_error.ErrRoomNotExist
	}

	songService := GetSongService()

	//inform
	informer := inform.GetInformService(appID)
	data := &InformFinishLive{
		RoomID: room.GetRoomID(),
		Type:   finishType,
	}
	informer.BroadcastRoom(ctx, roomID, OnFinishLive, data)

	//update
	room.Finish()
	err = rs.roomFactory.Save(ctx, room)
	if err != nil {
		logs.CtxError(ctx, "save room failed,error:%s", err)
		return custom_error.InternalError(err)
	}

	err = rs.userFactory.UpdateUsersByRoomID(ctx, appID, roomID, map[string]interface{}{
		"net_status":  owc_db.UserNetStatusOffline,
		"seat_id":     0,
		"leave_time":  time.Now().UnixNano() / 1e6,
		"update_time": time.Now(),
	})

	if err != nil {
		logs.CtxError(ctx, "update user failed,error:%s", err)
	}

	for {
		curSong, err := songService.GetCurSong(ctx, roomID)
		if err != nil {
			logs.CtxError(ctx, "get cur song err,%s", err)
			break
		}
		if curSong == nil {
			logs.CtxInfo(ctx, "song list is empty")
			break
		}
		songService.songFactory.songRepo.DelUser(ctx, roomID, curSong.OwcSong)
		_, err = songService.songFactory.Pop(ctx, roomID)
		if err != nil {
			logs.CtxError(ctx, "pop song err:%s", err)
			break
		}
	}

	return nil
}

func (rs *RoomService) JoinRoom(ctx context.Context, appID, roomID, userID, userName, userDeviceID string) error {
	room, err := rs.roomFactory.GetRoomByRoomID(ctx, appID, roomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		return err
	}
	if room == nil {
		logs.CtxError(ctx, "room is not exist")
		return custom_error.ErrRoomNotExist
	}
	user, err := rs.userFactory.GetActiveUserByRoomIDUserID(ctx, appID, roomID, userID)
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err.Error())
		return err
	}
	if user != nil {
		logs.CtxError(ctx, "user has joined the room")
		return custom_error.ErrUserInRoom
	}

	user = rs.userFactory.NewUser(ctx, appID, roomID, userID, userName, userDeviceID, owc_db.UserRoleAudience)
	user.JoinRoom(room.GetRoomID())
	err = rs.userFactory.Save(ctx, user)
	if err != nil {
		return custom_error.InternalError(err)
	}

	err = rs.roomFactory.IncrRoomAudienceCount(ctx, room.GetRoomID(), 1)
	if err != nil {
		logs.CtxError(ctx, "incr room audience count failed,error:%s", err)
	}

	//inform
	userCountMap, err := rs.roomFactory.GetRoomsAudienceCount(ctx, []string{room.GetRoomID()})
	if err != nil {
		logs.CtxError(ctx, "get user count failed,error:"+err.Error())
	}
	userCount := userCountMap[room.GetRoomID()]
	data := &InformJoinRoom{
		UserInfo:      user,
		AudienceCount: userCount,
	}
	informer := inform.GetInformService(appID)
	informer.BroadcastRoom(ctx, roomID, OnAudienceJoinRoom, data)
	return nil
}

func (rs *RoomService) LeaveRoom(ctx context.Context, appID, roomID, userID string) error {
	room, err := rs.roomFactory.GetRoomByRoomID(ctx, appID, roomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,error:%s", err)
		return err
	}
	if room == nil {
		logs.CtxError(ctx, "room is not exist")
		return custom_error.ErrRoomNotExist
	}

	user, err := rs.userFactory.GetActiveUserByRoomIDUserID(ctx, appID, roomID, userID)
	if err != nil || user == nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return nil
	}
	user.LeaveRoom()
	err = rs.userFactory.Save(ctx, user)
	if err != nil {
		return custom_error.InternalError(err)
	}
	songService := GetSongService()
	song, err := songService.GetCurSong(ctx, roomID)
	if err != nil {
		return err
	}
	if song != nil {
		startSingUser, err := songService.GetSongSingUser(ctx, roomID, song)
		if err != nil {
			logs.CtxError(ctx, "get sing users error,%s", err)
			return err
		}
		if userID == startSingUser.LeaderUser || userID == startSingUser.SuccentorUser {
			err := songService.CutOffSong(ctx, appID, roomID, userID)
			if err != nil {
				logs.CtxError(ctx, "cut off song,%s", err)
				return err
			}
		}
	}

	err = rs.roomFactory.IncrRoomAudienceCount(ctx, room.GetRoomID(), -1)
	if err != nil {
		logs.CtxError(ctx, "incr room audience count failed,error:%s", err)
	}

	//inform
	userCountMap, err := rs.roomFactory.GetRoomsAudienceCount(ctx, []string{room.GetRoomID()})
	if err != nil {
		logs.CtxError(ctx, "get user count failed,error:"+err.Error())
	}
	userCount := userCountMap[room.GetRoomID()]
	data := &InformLeaveRoom{
		UserInfo:      user,
		AudienceCount: userCount,
	}
	informer := inform.GetInformService(appID)
	informer.BroadcastRoom(ctx, roomID, OnAudienceLeaveRoom, data)
	return nil
}

func (rs *RoomService) Disconnect(ctx context.Context, appID, roomID, userID string) error {
	user, err := rs.userFactory.GetActiveUserByRoomIDUserID(ctx, appID, roomID, userID)
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return err
	}
	if user == nil {
		return errors.New("user not found")
	}

	user.Disconnect()
	err = rs.userFactory.Save(ctx, user)
	if err != nil {
		return err
	}

	go func(ctx context.Context, roomID, userID string) {
		user, err := rs.userFactory.GetUserByRoomIDUserID(ctx, appID, roomID, userID)
		if err != nil || user == nil {
			logs.CtxWarn(ctx, "get user failed,error:%s", err)
			return
		}
		roomService := GetRoomService()
		songService := GetSongService()

		if user.IsHost() {
			err = roomService.FinishLive(ctx, appID, user.GetRoomID(), FinishTypeNormal)
			if err != nil {
				logs.CtxError(ctx, "finish live failed,error:%s", err)
			}
		} else if user.IsAudience() {
			err = roomService.LeaveRoom(ctx, appID, user.GetRoomID(), user.GetUserID())
			if err != nil {
				logs.CtxError(ctx, "leave room failed,error:%s", err)
				return
			}
			for {
				curSong, err := songService.GetCurSong(ctx, roomID)
				if err != nil {
					logs.CtxError(ctx, "get cur song ,error:%s", err)
					return
				}
				if curSong == nil {
					logs.CtxInfo(ctx, "get cur song nil")
					break
				}
				if curSong.OwnerUserID == userID {
					preSong, err := songService.songFactory.Pop(ctx, roomID)
					if err != nil {
						logs.CtxError(ctx, "pop failed,error:%s", err)
						return
					}
					songService.songFactory.songRepo.DelUser(ctx, roomID, preSong.OwcSong)
					if err != nil {
						logs.CtxError(ctx, "cut off song ,error:%s", err)
					}
				} else {
					break
				}
			}
		}
	}(ctx, user.GetRoomID(), user.GetUserID())
	return nil
}

var presetSongRepoClient SongInfoRepo

func GetPresetSongRepo() SongInfoRepo {
	if presetSongRepoClient == nil {
		presetSongRepoClient = &owc_db.DbPresetSongRepo{}
	}
	return presetSongRepoClient
}
