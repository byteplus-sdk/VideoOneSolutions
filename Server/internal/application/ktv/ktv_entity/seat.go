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

package ktv_entity

type KtvSeat struct {
	RoomID      string `gorm:"column:room_id" json:"room_id"`
	SeatID      int    `gorm:"column:seat_id" json:"seat_id"`
	OwnerUserID string `gorm:"column:user_id" json:"user_id"`
	Status      int    `gorm:"column:status" json:"status"`
}
