/*
 * Copyright 2023 CloudWeGo Authors
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

package live_linkmic_core_service

import (
	"context"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_entity"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_linker_models"
)

var linkerFactory *LinkerFactory

type LinkerFactory struct {
}

func GetLinkerFactory() *LinkerFactory {
	if linkerFactory == nil {
		linkerFactory = &LinkerFactory{}
	}
	return linkerFactory
}

func (f *LinkerFactory) NewDefaultLinker(ctx context.Context, linkerID, bizID, fromRoomID, fromUserID, toRoomID, toUserID string, scene int) *live_entity.LiveLinker {
	now := time.Now()
	linker := &live_entity.LiveLinker{
		LinkerID:     linkerID,
		FromRoomID:   fromRoomID,
		FromUserID:   fromUserID,
		ToRoomID:     toRoomID,
		ToUserID:     toUserID,
		BizID:        bizID,
		LinkerStatus: live_linker_models.LinkerStatusNothing,
		Status:       live_linker_models.DataStatusNormal,
		Scene:        scene,
		CreateTime:   now,
	}
	return linker
}
