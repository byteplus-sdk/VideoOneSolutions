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

package live_handler

import (
	"context"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_room_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_repo/live_facade"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/task"
	"github.com/robfig/cron/v3"

	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

var handler *EventHandler

type EventHandler struct {
	c *cron.Cron
}

func NewEventHandler() *EventHandler {
	if handler == nil {
		handler = &EventHandler{
			c: task.GetCronTask(),
		}
		handler.c.AddFunc("@every 1m", func() {
			ctx := context.Background()
			liveTimerEnable := config.Configs().LiveTimerEnable
			if !liveTimerEnable {
				logs.CtxInfo(ctx, "timeout not enable")
				return
			}
			roomRepo := live_facade.GetRoomRepo()
			rooms, err := roomRepo.GetAllActiveRooms(ctx)
			if err != nil {
				logs.CtxError(ctx, "cron: get live rooms failed,error:%s", err)
				return
			}

			for _, room := range rooms {
				if time.Now().Sub(room.CreateTime) >= time.Duration(config.Configs().LiveExperienceTime)*time.Minute {
					FinishLiveLogic(ctx, room.RtcAppID, finishLiveReq{
						RoomID:     room.RoomID,
						UserID:     room.HostUserID,
						FinishType: live_room_models.RoomFinishTimeOut,
					})
				}
			}

		})

	}
	return handler
}
