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

package drama_model

type GetDramaChannelReq struct {
}

type GetDramaChannelResp struct {
	Loop      []DramaMetaInfo `json:"loop"`
	Trending  []DramaMetaInfo `json:"trending"`
	New       []DramaMetaInfo `json:"new"`
	Recommend []DramaMetaInfo `json:"recommend"`
}

type DramaMetaInfo struct {
	DramaID               string `json:"drama_id"`
	DramaTitle            string `json:"drama_title"`
	DramaPlayTimes        int64  `json:"drama_play_times"`
	DramaCoverURL         string `json:"drama_cover_url"`
	NewRelease            bool   `json:"new_release"`
	DramaLength           int    `json:"drama_length"`
	DramaVideoOrientation int    `json:"drama_video_orientation"`
}

type GetDramaFeedReq struct {
	PageSize     int `json:"page_size" binding:"required"`
	Offset       int `json:"offset"`
	PlayInfoType int `json:"play_info_type"`
}

const (
	PlayInfoTypeByPlayAuthToken int = 0
	PlayInfoTypeByVideoModel    int = 1
)

type GetDramaFeedResp struct {
	DramaMeta DramaMetaInfo `json:"drama_meta"`
	VideoMeta VideoMetaInfo `json:"video_meta"`
}

type VideoMetaInfo struct {
	Vid               string  `json:"vid"`
	DramaID           string  `json:"drama_id"`
	Caption           string  `json:"caption"`
	Duration          float32 `json:"duration"`
	CoverUrl          string  `json:"cover_url"`
	PlayAuthToken     string  `json:"play_auth_token,omitempty"`
	VideoModel        string  `json:"video_model,omitempty"`
	PlayTimes         int64   `json:"play_times"`
	Subtitle          string  `json:"subtitle"`
	CreateTime        string  `json:"create_time"`
	Name              string  `json:"name"`
	Uid               int64   `json:"uid"`
	Like              int64   `json:"like"`
	Comment           int64   `json:"comment"`
	Height            int32   `json:"height"`
	Width             int32   `json:"width"`
	Order             int     `json:"order"`
	DisplayType       int     `json:"display_type"`
	SubtitleAuthToken string  `json:"subtitle_auth_token,omitempty"`
	VIP               bool    `json:"vip"`
}

type GetDramaListReq struct {
	UserID       string `json:"user_id" binding:"required"`
	DramaID      string `json:"drama_id" binding:"required"`
	PlayInfoType int    `json:"play_info_type"`
}

type GetDramaListResp struct {
	VID               string  `json:"vid"`
	Order             int     `json:"order"`
	PlayAuthToken     string  `json:"play_auth_token,omitempty"`
	SubtitleAuthToken string  `json:"subtitle_auth_token,omitempty"`
	VideoModel        string  `json:"video_model,omitempty"`
	Caption           string  `json:"caption"`
	Duration          float32 `json:"duration"`
	CoverUrl          string  `json:"cover_url"`
	PlayTimes         int64   `json:"play_times"`
	DramaTitle        string  `json:"drama_title"`
	Height            int32   `json:"height"`
	Width             int32   `json:"width"`
	Like              int64   `json:"like"`
	Comment           int64   `json:"comment"`
}

type GetDramaDetailReq struct {
	UserID       string   `json:"user_id" binding:"required"`
	VIDList      []string `json:"vid_list" binding:"required"`
	DramaID      string   `json:"drama_id" binding:"required"`
	PlayInfoType int      `json:"play_info_type"`
}

type GetDramaDetailResp struct {
	VID               string `json:"vid"`
	Order             int    `json:"order"`
	PlayAuthToken     string `json:"play_auth_token,omitempty"`
	SubtitleAuthToken string `json:"subtitle_auth_token,omitempty"`
	VideoModel        string `json:"video_model,omitempty"`
}

type Comments struct {
	Content    string `json:"content"`
	Name       string `json:"name"`
	Uid        int64  `json:"uid"`
	CreateTime string `json:"createTime"`
	Like       int64  `json:"like"`
}
