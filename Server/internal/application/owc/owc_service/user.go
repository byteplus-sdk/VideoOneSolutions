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
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_db"
	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_entity"
)

type User struct {
	*owc_entity.OwcUser
	isDirty bool
}

func (u *User) IsDirty() bool {
	return u.isDirty
}

func (u *User) GetRoomID() string {
	return u.RoomID
}

func (u *User) GetUserID() string {
	return u.UserID
}

func (u *User) GetUserName() string {
	return u.UserName
}

func (u *User) GetSeatID() int {
	return u.SeatID
}

func (u *User) IsReconnecting() bool {
	return u.NetStatus == owc_db.UserNetStatusReconnecting
}

func (u *User) IsOnline() bool {
	return u.NetStatus == owc_db.UserNetStatusOnline
}

func (u *User) IsHost() bool {
	return u.UserRole == owc_db.UserRoleHost
}

func (u *User) IsAudience() bool {
	return u.UserRole == owc_db.UserRoleAudience
}

func (u *User) StartLive() {
	u.NetStatus = owc_db.UserNetStatusOnline
	u.JoinTime = time.Now().UnixNano() / 1e6
	u.isDirty = true
}

func (u *User) JoinRoom(roomID string) {
	u.RoomID = roomID
	u.NetStatus = owc_db.UserNetStatusOnline
	u.JoinTime = time.Now().UnixNano() / 1e6
	u.isDirty = true
}

func (u *User) LeaveRoom() {
	u.NetStatus = owc_db.UserNetStatusOffline
	u.SeatID = 0
	u.LeaveTime = time.Now().UnixNano() / 1e6
	u.isDirty = true
}

func (u *User) Disconnect() {
	u.NetStatus = owc_db.UserNetStatusReconnecting
	u.isDirty = true
}

func (u *User) Reconnect() {
	u.NetStatus = owc_db.UserNetStatusOnline
	u.isDirty = true
}

func (u *User) SetUpdateTime(time time.Time) {
	u.UpdateTime = time
	u.isDirty = true
}

func (u *User) SetIsDirty(status bool) {
	u.isDirty = status
}

func (u *User) MuteMic() {
	u.Mic = 0
	u.isDirty = true
}

func (u *User) UnmuteMic() {
	u.Mic = 1
	u.isDirty = true
}
