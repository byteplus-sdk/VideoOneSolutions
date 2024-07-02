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

	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

var songFactoryClient *SongFactory

type SongFactory struct {
	songRepo SongRepo
}

func GetSongFactory() *SongFactory {
	if songFactoryClient == nil {
		songFactoryClient = &SongFactory{
			songRepo: GetSongRepo(),
		}
	}
	return songFactoryClient
}

func (sf *SongFactory) GetSongListByRoomID(ctx context.Context, roomID string) ([]*Song, error) {
	dbSongs, err := sf.songRepo.List(ctx, roomID)
	if err != nil {
		logs.CtxError(ctx, "get song failed,error:%s", err)
		return nil, custom_error.InternalError(err)
	}
	songs := make([]*Song, 0)
	for _, dbSong := range dbSongs {
		song := &Song{
			KtvSong: dbSong,
			isDirty: false,
		}
		songs = append(songs, song)
	}
	return songs, nil
}

func (sf *SongFactory) Push(ctx context.Context, roomID string, song *Song) error {
	dbSong := song.KtvSong
	err := sf.songRepo.Push(ctx, roomID, dbSong)
	if err != nil {
		return custom_error.InternalError(err)
	}
	return nil
}

func (sf *SongFactory) UpdateTop(ctx context.Context, roomID string, song *Song) error {
	dbSong := song.KtvSong
	err := sf.songRepo.UpdateTop(ctx, roomID, dbSong)
	if err != nil {
		return custom_error.InternalError(err)
	}
	return nil
}

func (sf *SongFactory) Top(ctx context.Context, roomID string) (*Song, error) {
	dbSong, err := sf.songRepo.LIndex(ctx, roomID, 0)
	if err != nil {
		return nil, custom_error.InternalError(err)
	}
	if dbSong == nil {
		return nil, nil
	}
	song := &Song{
		KtvSong: dbSong,
		isDirty: false,
	}
	return song, nil
}

func (sf *SongFactory) LIndex(ctx context.Context, roomID string, index int64) (*Song, error) {
	dbSong, err := sf.songRepo.LIndex(ctx, roomID, index)
	if err != nil {
		return nil, custom_error.InternalError(err)
	}
	if dbSong == nil {
		return nil, nil
	}
	song := &Song{
		KtvSong: dbSong,
		isDirty: false,
	}
	return song, nil
}

func (sf *SongFactory) Pop(ctx context.Context, roomID string) (*Song, error) {
	dbSong, err := sf.songRepo.Pop(ctx, roomID)
	if err != nil {
		return nil, custom_error.InternalError(err)
	}
	if dbSong == nil {
		return nil, nil
	}
	song := &Song{
		KtvSong: dbSong,
		isDirty: false,
	}
	return song, nil
}
