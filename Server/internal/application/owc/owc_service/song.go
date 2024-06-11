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
	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_entity"
)

const (
	SongStatusWaiting = 1
	SongStatusStart   = 2
	SongStatusFinish  = 3
)

type Song struct {
	*owc_entity.OwcSong
	isDirty bool
}

func (r *Song) IsDirty() bool {
	return r.isDirty
}

func (r *Song) GetRoomID() string {
	return r.RoomID
}

func (r *Song) GetOwnerUserID() string {
	return r.OwnerUserID
}

func (r *Song) GetOwnerUserName() string {
	return r.OwnerUserName
}

func (r *Song) GetSongID() string {
	return r.SongID
}

func (r *Song) Start() {
	r.Status = SongStatusStart
	r.isDirty = true
}

func (r *Song) Finish() {
	r.Status = SongStatusFinish
	r.isDirty = true
}
