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

package ktv_handler

import (
	"context"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/task"
	"github.com/robfig/cron/v3"
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
			ktvTimerEnable := config.Configs().KtvTimerEnable
			if !ktvTimerEnable {
				return
			}
			roomFactory := ktv_service.GetRoomFactory()
			rooms, err := roomFactory.GetAllActiveRoomList(ctx, false)
			if err != nil {
				logs.CtxError(ctx, "cron: get svc rooms failed,error:%s", err)
				return
			}

			roomService := ktv_service.GetRoomService()
			for _, room := range rooms {
				if time.Since(room.GetCreateTime()) >= time.Duration(config.Configs().KtvExperienceTime)*time.Minute {
					err = roomService.FinishLive(ctx, room.GetAppID(), room.GetRoomID(), ktv_service.FinishTypeTimeout)
					if err != nil {
						logs.CtxError(ctx, "cron: finish room failed,error:%s", err)
						continue
					}
				}
			}

		})
	}
	return handler
}
