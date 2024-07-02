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

package live_feed_repo

import (
	"context"

	"github.com/byteplus/VideoOneServer/internal/application/live_feed/live_feed_model"
)

var liveFeedRepo liveFeedRepoInterface

func GetLiveFeedRepo() liveFeedRepoInterface {
	if liveFeedRepo == nil {
		liveFeedRepo = &LiveFeedRepoImpl{}
	}
	return liveFeedRepo
}

type liveFeedRepoInterface interface {
	GetLiveFeed(ctx context.Context, offset, pageSize int, excludeRoomID string) ([]*live_feed_model.LiveFeed, error)
	AddRoomAudienceCount(ctx context.Context, roomID string, value int64) (int64, error)
}
