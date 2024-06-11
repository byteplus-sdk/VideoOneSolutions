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

package owc_db

import (
	"context"

	"github.com/byteplus/VideoOneServer/internal/application/owc/owc_entity"
	"github.com/byteplus/VideoOneServer/internal/pkg/db"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
)

const PresetSong = "song"

type DbPresetSongRepo struct{}

func (repo *DbPresetSongRepo) OwcGetPresetSong(ctx context.Context) ([]owc_entity.PresetSong, error) {
	defer util.CheckPanic()
	var s []owc_entity.PresetSong
	err := db.Client.WithContext(ctx).Debug().Table(PresetSong).Find(&s).Error
	if err != nil {
		return nil, err
	}
	return s, nil
}
