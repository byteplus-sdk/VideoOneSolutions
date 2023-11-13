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

package inform

import (
	"context"

	"github.com/byteplus/VideoOneServer/internal/models/response"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/rtc_openapi"
)

type InformEvent string

type InformService struct {
	AppID string
}

var informServiceMap map[string]*InformService

func GetInformService(appID string) *InformService {
	if informServiceMap == nil {
		informServiceMap = make(map[string]*InformService, 10)
	}
	informService, ok := informServiceMap[appID]
	if ok {
		return informService
	} else {
		informService = &InformService{
			AppID: appID,
		}
		informServiceMap[appID] = informService
	}

	return informService
}

// BroadcastRoom Broadcast in Room
func (is *InformService) BroadcastRoom(ctx context.Context, roomID string, event InformEvent, data interface{}) {
	instance := rtc_openapi.GetInstance(ctx, is.AppID)
	err := instance.RtsSendBroadcast(ctx, is.AppID, roomID, response.NewInformToClient(string(event), data))
	if err != nil {
		logs.CtxError(ctx, "rts send broad cast failed,event:%s,data:%#v,error:%s", event, data, err)
	}
}

// UnicastRoomUser Unicast to user in Room
func (is *InformService) UnicastRoomUser(ctx context.Context, roomID, userID string, event InformEvent, data interface{}) {
	instance := rtc_openapi.GetInstance(ctx, is.AppID)
	err := instance.RtsSendRoomUnicast(ctx, is.AppID, roomID, userID, response.NewInformToClient(string(event), data))
	if err != nil {
		logs.CtxError(ctx, "rts send broad cast failed,event:%s,data:%#v,error:%s", event, data, err)
	}
}

// UnicastUser Unicast to User
func (is *InformService) UnicastUser(ctx context.Context, userID string, event InformEvent, data interface{}) {
	instance := rtc_openapi.GetInstance(ctx, is.AppID)
	err := instance.RtsSendUnicast(ctx, is.AppID, userID, response.NewInformToClient(string(event), data))
	if err != nil {
		logs.CtxError(ctx, "rts send broad cast failed,event:%s,data:%#v,error:%s", event, data, err)
	}
}
