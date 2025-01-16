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

package drama_service

import (
	"context"
	"math/rand"
	"sort"

	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_model"
	"github.com/byteplus/VideoOneServer/internal/application/drama/drama_repo"
)

func GetDramaChannel(ctx context.Context) (*drama_model.GetDramaChannelResp, error) {
	dramaList, err := drama_repo.GetDramaRepo().GetAllDrama(ctx)
	if err != nil {
		return nil, err
	}

	resp := new(drama_model.GetDramaChannelResp)

	dramaReturnSize := 6

	//1. build [loop]
	for _, d := range dramaList {
		resp.Loop = append(resp.Loop, drama_model.DramaMetaInfo{
			DramaID:               d.DramaID,
			DramaTitle:            d.Title,
			DramaPlayTimes:        rand.Int63n(100000) + 100000, // random
			DramaCoverURL:         d.CoverUrl,
			DramaLength:           d.TotalNumber,
			DramaVideoOrientation: d.VideoOrientation,
		})
	}

	//2. build [trending]
	for i, d := range dramaList {
		if i >= dramaReturnSize {
			break
		}
		resp.Trending = append(resp.Trending, drama_model.DramaMetaInfo{
			DramaID:               d.DramaID,
			DramaTitle:            d.Title,
			DramaPlayTimes:        rand.Int63n(100000) + 100000, // random
			DramaCoverURL:         d.CoverUrl,
			DramaLength:           d.TotalNumber,
			DramaVideoOrientation: d.VideoOrientation,
		})
	}
	sort.SliceStable(resp.Trending, func(i, j int) bool {
		return resp.Trending[i].DramaPlayTimes > resp.Trending[j].DramaPlayTimes
	})

	//3. build [new]
	rand.Shuffle(len(dramaList), func(i, j int) {
		dramaList[i], dramaList[j] = dramaList[j], dramaList[i]
	})
	for i, d := range dramaList {
		if i >= dramaReturnSize {
			break
		}
		resp.New = append(resp.New, drama_model.DramaMetaInfo{
			DramaID:               d.DramaID,
			DramaTitle:            d.Title,
			DramaPlayTimes:        rand.Int63n(100000) + 100000, // random
			DramaCoverURL:         d.CoverUrl,
			NewRelease:            i%3 == 0, // random
			DramaLength:           d.TotalNumber,
			DramaVideoOrientation: d.VideoOrientation,
		})
	}

	//4. build [recommend]
	rand.Shuffle(len(dramaList), func(i, j int) {
		dramaList[i], dramaList[j] = dramaList[j], dramaList[i]
	})
	for i, d := range dramaList {
		if i >= dramaReturnSize {
			break
		}
		resp.Recommend = append(resp.Recommend, drama_model.DramaMetaInfo{
			DramaID:               d.DramaID,
			DramaTitle:            d.Title,
			DramaPlayTimes:        rand.Int63n(100000) + 100000, // random
			DramaCoverURL:         d.CoverUrl,
			DramaLength:           d.TotalNumber,
			DramaVideoOrientation: d.VideoOrientation,
		})
	}
	return resp, nil
}
