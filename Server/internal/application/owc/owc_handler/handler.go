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
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/robfig/cron/v3"
)

func NewCronJob(c *cron.Cron) {
	c.AddFunc("@every 1m", func() {
		ctx := context.Background()
		owcTimerEnable := config.Configs().OwcTimerEnable
		if !owcTimerEnable {
			logs.CtxInfo(ctx, "owc timer not enable")
			return
		}
		roomFactory := owc_service.GetRoomFactory()
		rooms, err := roomFactory.GetActiveRoomList(ctx, false)
		if err != nil {
			logs.CtxError(ctx, "cron: get svc rooms failed,error:%s", err)
			return
		}

		roomService := owc_service.GetRoomService()
		for _, room := range rooms {
			if time.Since(room.GetCreateTime()) >= time.Duration(config.Configs().OwcExperienceTime)*time.Minute {
				err = roomService.FinishLive(ctx, room.GetAppID(), room.GetRoomID(), owc_service.FinishTypeTimeout)
				if err != nil {
					logs.CtxError(ctx, "cron: finish room failed,error:%s", err)
					continue
				}
			}
		}
	})
}
