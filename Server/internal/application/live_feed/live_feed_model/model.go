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

package live_feed_model

type GetFeedStreamWithLiveReq struct {
	PageSize int    `json:"page_size" binding:"required"`
	Offset   int    `json:"offset"`
	UserID   string `json:"user_id" binding:"required"`
}

type GetFeedStreamWithLiveResp struct {
	VideoType  int          `json:"video_type"`  // 1:vod, 2:live
	UserStatus int          `json:"user_status"` // 1: offline  2:living
	RoomInfo   *RoomDetail  `json:"room_info,omitempty"`
	VideoInfo  *VideoDetail `json:"video_info,omitempty"`
}

const (
	VideoTypeVod  = 1
	VideoTypeLive = 2

	UserStatusOffline = 1
	UserStatusLiving  = 2
)

type RoomDetail struct {
	LiveFeed
	HostUserID        int64             `json:"host_user_id"`
	RtsToken          string            `json:"rts_token"`
	StreamPullUrlList map[string]string `json:"stream_pull_url_list"`
}

type VideoDetail struct {
	Vid               string  `json:"vid"`
	Caption           string  `json:"caption"`
	Duration          float64 `json:"duration"`
	CoverUrl          string  `json:"cover_url"`
	PlayAuthToken     string  `json:"play_auth_token"`
	SubtitleAuthToken string  `json:"subtitle_auth_token"`
	PlayTimes         int64   `json:"play_times"`
	Subtitle          string  `json:"subtitle"`
	CreateTime        string  `json:"create_time"`
	Name              string  `json:"name"`
	Uid               int64   `json:"uid"`
	Like              int64   `json:"like"`
	Comment           int64   `json:"comment"`
	Height            int32   `json:"height"`
	Width             int32   `json:"width"`
}

type GetFeedStreamOnlyLiveReq struct {
	PageSize int    `json:"page_size" binding:"required"`
	Offset   int    `json:"offset"`
	UserID   string `json:"user_id" binding:"required"`
	RoomID   string `json:"room_id" binding:"required"`
}

type SwitchFeedStreamRoomReq struct {
	OldRoomID string `json:"old_room_id"`
	NewRoomID string `json:"new_room_id"`
	UserID    string `json:"user_id" binding:"required"`
}

type SendMessageReq struct {
	UserID  string `json:"user_id" binding:"required"`
	RoomID  string `json:"room_id" binding:"required"`
	Message string `json:"message" binding:"required"`
}

type InformMessageSend struct {
	UserID   string `json:"user_id"`
	UserName string `json:"user_name"`
	Message  string `json:"message"`
}

type InformUserJoin struct {
	UserID        string `json:"user_id"`
	UserName      string `json:"user_name"`
	AudienceCount int64  `json:"audience_count"`
}

type InformUserLeave struct {
	UserID        string `json:"user_id"`
	UserName      string `json:"user_name"`
	AudienceCount int64  `json:"audience_count"`
}

const (
	FeedLiveOnMessageSend = "feedLiveOnMessageSend"
	FeedLiveOnUserLeave   = "feedLiveOnUserLeave"
	FeedLiveOnUserJoin    = "feedLiveOnUserJoin"
)
