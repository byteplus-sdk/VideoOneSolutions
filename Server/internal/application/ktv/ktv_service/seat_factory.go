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

package ktv_service

import (
	"context"

	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_entity"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
)

var seatFactoryClient *SeatFactory

type SeatFactory struct {
	seatRepo SeatRepo
}

func GetSeatFactory() *SeatFactory {
	if seatFactoryClient == nil {
		seatFactoryClient = &SeatFactory{
			seatRepo: GetSeatRepo(),
		}
	}
	return seatFactoryClient
}

func (sf *SeatFactory) NewSeat(ctx context.Context, roomID string, seatID int) *Seat {
	dbSeat := &ktv_entity.KtvSeat{
		RoomID: roomID,
		SeatID: seatID,
		Status: 1,
	}
	seat := &Seat{
		KtvSeat: dbSeat,
		isDirty: true,
	}
	return seat
}

func (sf *SeatFactory) Save(ctx context.Context, seat *Seat) error {
	if seat.IsDirty() {
		err := sf.seatRepo.Save(ctx, seat.KtvSeat)
		if err != nil {
			return custom_error.InternalError(err)
		}
		seat.SetIsDirty(false)
	}
	return nil
}

func (sf *SeatFactory) GetSeatByRoomIDSeatID(ctx context.Context, roomID string, seatID int) (*Seat, error) {
	dbSeat, err := sf.seatRepo.GetSeatByRoomIDSeatID(ctx, roomID, seatID)
	if err != nil {
		return nil, custom_error.InternalError(err)
	}
	if dbSeat == nil {
		return nil, nil
	}

	seat := &Seat{
		KtvSeat: dbSeat,
		isDirty: false,
	}
	return seat, nil
}

func (sf *SeatFactory) GetSeatsByRoomID(ctx context.Context, roomID string) ([]*Seat, error) {
	dbSeats, err := sf.seatRepo.GetSeatsByRoomID(ctx, roomID)
	if err != nil {
		return nil, custom_error.InternalError(err)
	}

	seats := make([]*Seat, len(dbSeats))
	for i := 0; i < len(dbSeats); i++ {
		seats[i] = &Seat{
			KtvSeat: dbSeats[i],
			isDirty: false,
		}
	}

	return seats, nil
}
