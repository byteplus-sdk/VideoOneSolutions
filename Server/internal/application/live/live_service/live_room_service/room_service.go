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

package live_room_service

import (
	"context"
	"encoding/json"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_linker_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_room_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_inform_service"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_service/live_linkmic_core_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/inform"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
)

type RoomService struct {
	roomFactory  *RoomFactory
	roomRepo     live_facade.RoomRepoInterface
	roomUserRepo live_facade.RoomUserRepoInterface
}

var roomService *RoomService

func GetRoomService() *RoomService {
	if roomService == nil {
		roomService = &RoomService{
			roomFactory:  GetRoomFactory(),
			roomRepo:     live_facade.GetRoomRepo(),
			roomUserRepo: live_facade.GetRoomUserRepo(),
		}
	}
	return roomService
}

func (rs *RoomService) CreateRoom(ctx context.Context, appID, roomName, hostUserID, hostUserName string, liveCdnAppId string) (*live_entity.LiveRoom, *live_entity.LiveRoomUser, error) {
	//create room
	room, err := rs.roomFactory.NewRoom(ctx, appID, roomName, hostUserID, hostUserName, liveCdnAppId)
	if err != nil {
		logs.CtxError(ctx, "new room failed,error:%s", err)
		return nil, nil, err
	}

	rtcRoomID, err := ApplyRoomIDWithRetry(ctx, appID)
	if err != nil {
		return nil, nil, err
	}
	rs.roomRepo.SetRoomRtcRoomID(ctx, room.RoomID, rtcRoomID)
	err = rs.roomRepo.Save(ctx, room)
	if err != nil {
		logs.CtxError(ctx, "save room failed,error:%s", err)
		return nil, nil, err
	}

	host := rs.roomFactory.NewRoomUser(ctx, appID, room.RoomID, hostUserID, hostUserName, live_room_models.RoomUserRoleHost)
	err = rs.roomUserRepo.Save(ctx, host)
	if err != nil {
		logs.CtxError(ctx, "save room user failed,error:%s", err)
		return nil, nil, err
	}

	return room, host, nil
}

func (rs *RoomService) StartRoom(ctx context.Context, appID, roomID, hostUserID string) (*live_entity.LiveRoom, *live_entity.LiveRoomUser, error) {
	room, err := rs.roomRepo.GetRoom(ctx, appID, roomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,roomID:%s,error:%s", roomID, err)
		return nil, nil, err
	}

	if room.HostUserID != hostUserID {
		logs.CtxError(ctx, "host user id not match")
		return nil, nil, custom_error.ErrUserIsNotOwner
	}

	room.Start()
	err = rs.roomRepo.Save(ctx, room)
	if err != nil {
		logs.CtxError(ctx, "save room failed,error:%s", err)
		return nil, nil, err
	}

	host, err := rs.roomUserRepo.GetUser(ctx, appID, roomID, hostUserID)
	if err != nil {
		logs.CtxError(ctx, "get user failed,error:%s", err)
		return nil, nil, err
	}
	host.Join()
	err = rs.roomUserRepo.Save(ctx, host)
	if err != nil {
		logs.CtxError(ctx, "save room user failed,error:%s", err)
		return nil, nil, err
	}

	return room, host, nil
}

func (rs *RoomService) FinishRoom(ctx context.Context, appID, roomID, hostUserID string, finishType int) (*live_entity.LiveRoom, error) {
	room, err := rs.roomRepo.GetActiveRoom(ctx, appID, roomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,roomID:%s,error:%s", roomID, err)
		return nil, err
	}

	if room.HostUserID != hostUserID {
		logs.CtxError(ctx, "host user id not match")
		return nil, custom_error.ErrUserIsNotOwner
	}

	room.Finish()
	roomDuration := int(room.FinishTime.Sub(room.CreateTime).Milliseconds())
	roomExtra := &live_room_models.RoomExtra{}
	err = json.Unmarshal([]byte(room.Extra), roomExtra)
	if err != nil {
		logs.CtxError(ctx, "save room user failed,error:%s", err)
		return nil, err
	}
	roomExtra.Duration = roomDuration
	newRoomExtraStr, err := json.Marshal(roomExtra)
	if err != nil {
		logs.CtxInfo(ctx, "marshal room extra error:%s", err)
		return nil, err
	}
	room.Extra = string(newRoomExtraStr)
	err = rs.roomRepo.Save(ctx, room)
	if err != nil {
		logs.CtxError(ctx, "save room failed,error:%s", err)
		return nil, err
	}

	rs.roomUserRepo.UpdateUsersByRoomID(ctx, appID, roomID, map[string]interface{}{
		"status": live_room_models.RoomUserStatusFinish,
	})
	rs.roomRepo.DelRoomRtcRoomID(ctx, roomID)
	informData := live_inform_service.InformFinishLive{
		RoomID: roomID,
		Type:   finishType,
		Extra:  string(newRoomExtraStr),
	}
	informer := inform.GetInformService(appID)

	informer.BroadcastRoom(ctx, room.RoomID, live_inform_service.OnFinishLive, informData)

	return room, nil
}

func (rs *RoomService) JoinRoom(ctx context.Context, appID, roomID, userID, userName string) (*live_entity.LiveRoom, *live_entity.LiveRoomUser, error) {
	room, err := rs.roomRepo.GetActiveRoom(ctx, appID, roomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,roomID:%s,error:%s", roomID, err)
		return nil, nil, err
	}

	roomExtraStr := room.Extra
	roomExtra := &live_room_models.RoomExtra{}
	err = json.Unmarshal([]byte(roomExtraStr), roomExtra)
	if err != nil {
		logs.CtxError(ctx, "save room user failed,error:%s", err)
		return nil, nil, err
	}
	roomExtra.Viewers = roomExtra.Viewers + 1
	newRoomExtraStr, err := json.Marshal(roomExtra)
	if err != nil {
		logs.CtxInfo(ctx, "marshal room extra error:%s", err)
		return nil, nil, err
	}
	room.Extra = string(newRoomExtraStr)
	err = rs.roomRepo.Save(ctx, room)
	if err != nil {
		logs.CtxError(ctx, "save room failed,error:%s", err)
		return nil, nil, err
	}
	audience := rs.roomFactory.NewRoomUser(ctx, appID, roomID, userID, userName, live_room_models.RoomUserRoleAudience)
	audience.Join()
	err = rs.roomUserRepo.Save(ctx, audience)
	if err != nil {
		logs.CtxError(ctx, "save room user failed,error:%s", err)
		return nil, nil, err
	}

	rs.roomRepo.AddRoomAudienceCount(ctx, roomID)
	room.AudienceCount = room.AudienceCount + 1

	informData := live_inform_service.InformAudienceJoinRoom{
		AudienceUserID:   userID,
		AudienceUserName: userName,
		AudienceCount:    room.AudienceCount,
	}

	informer := inform.GetInformService(appID)
	informer.BroadcastRoom(ctx, room.RoomID, live_inform_service.OnAudienceJoinRoom, informData)

	return room, audience, nil
}

func (rs *RoomService) LeaveRoom(ctx context.Context, appID, roomID, userID string) error {
	room, err := rs.roomRepo.GetActiveRoom(ctx, appID, roomID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,roomID:%s,error:%s", roomID, err)
		return err
	}

	user, err := rs.roomUserRepo.GetActiveUser(ctx, appID, roomID, userID)
	if err != nil {
		logs.CtxError(ctx, "get room failed,roomID:%s,error:%s", roomID, err)
		return err
	}

	user.Leave()
	err = rs.roomUserRepo.Save(ctx, user)
	if err != nil {
		return err
	}

	linkerService := live_linkmic_core_service.GetLinkerService()
	linker, err := linkerService.GetAudienceLinkerByRoomIDAndUserID(ctx, roomID, userID)
	if err != nil {
		if !custom_error.Equal(err, custom_error.ErrRecordNotFound) {
			logs.CtxError(ctx, "GetAudienceLinkerByRoomIDAndUserID failed,error:%s", err)
			return err
		}
	} else {
		// if user has sent linkmic apply, cancel it
		err = linkerService.UpdateLinkerStatus(ctx, linker.LinkerID, live_linker_models.LinkerStatusNotValid)
		if err != nil {
			logs.CtxError(ctx, "UpdateLinkerStatus error:%s", err)
			return err
		}
	}

	rs.roomRepo.SubRoomAudienceCount(ctx, roomID)
	room.AudienceCount = room.AudienceCount - 1
	if room.AudienceCount < 0 {
		room.AudienceCount = 0
	}

	informData := live_inform_service.InformAudienceLeaveRoom{
		AudienceUserID:   userID,
		AudienceUserName: user.UserName,
		AudienceCount:    room.AudienceCount,
	}
	informer := inform.GetInformService(appID)
	informer.BroadcastRoom(ctx, room.RoomID, live_inform_service.OnAudienceLeaveRoom, informData)

	return nil
}

func (rs *RoomService) HandleMessage(ctx context.Context, appID, roomID, messageStr string) error {
	var message live_room_models.Message
	err := json.Unmarshal([]byte(messageStr), &message)
	if err != nil {
		return err
	}
	if util.IntInSlice(message.MessageType, []int{live_room_models.MessageTypeGift, live_room_models.MessageTypeLike}) {
		room, err := rs.roomRepo.GetActiveRoom(ctx, appID, roomID)
		if err != nil {
			logs.CtxError(ctx, "get room failed,roomID:%s,error:%s", roomID, err)
			return err
		}
		roomExtraStr := room.Extra
		roomExtra := &live_room_models.RoomExtra{}
		err = json.Unmarshal([]byte(roomExtraStr), roomExtra)
		if err != nil {
			logs.CtxError(ctx, "save room user failed,error:%s", err)
			return err
		}
		if message.MessageType == live_room_models.MessageTypeGift {
			roomExtra.Gifts = roomExtra.Gifts + 1
		} else {
			roomExtra.Likes = roomExtra.Likes + 1
		}
		newRoomExtraStr, err := json.Marshal(roomExtra)
		if err != nil {
			logs.CtxInfo(ctx, "marshal room extra error:%s", err)
			return err
		}
		room.Extra = string(newRoomExtraStr)
		err = rs.roomRepo.Save(ctx, room)
		if err != nil {
			logs.CtxError(ctx, "save room failed,error:%s", err)
			return err
		}
	}

	return nil
}
