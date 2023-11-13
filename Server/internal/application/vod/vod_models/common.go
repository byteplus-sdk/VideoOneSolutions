/*
 * Copyright 2023 CloudWeGo Authors
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

package vod_models

type ResponseMetadata struct {
	RequestId string         `json:"requestId"`
	Action    string         `json:"action"`
	Version   string         `json:"version"`
	Service   string         `json:"service"`
	Region    string         `json:"region"`
	Error     *ResponseError `json:"error,omitempty"`
}

type ResponseError struct {
	Code    string `protobuf:"bytes,1,opt,name=code,proto3" json:"code,omitempty"`
	Message string `protobuf:"bytes,2,opt,name=message,proto3" json:"message,omitempty"`
}

type STS2 struct {
	AccessKeyID     string `json:"AccessKeyID"`
	SecretAccessKey string `json:"SecretAccessKey"`
	SessionToken    string `json:"SessionToken"`
	ExpiredTime     string `json:"ExpiredTime"`
	CurrentTime     string `json:"CurrentTime"`
	SpaceName       string `json:"SpaceName"`
}

type VideoInfo struct {
	Vid       string `json:"vid"`
	VideoType int    `json:"video_type"`
}

type VideoDetail struct {
	Vid               string  `json:"vid,omitempty"`
	Caption           string  `json:"caption,omitempty"`
	Duration          float64 `json:"duration,omitempty"`
	CoverUrl          string  `json:"coverUrl,omitempty"`
	VideoModel        string  `json:"videoModel,omitempty"`
	PlayAuthToken     string  `json:"playAuthToken,omitempty"`
	SubtitleAuthToken string  `json:"subtitleAuthToken,omitempty"`
	PlayTimes         int64   `json:"playTimes"`
	Subtitle          string  `json:"subtitle"`
	CreateTime        string  `json:"createTime"`
}

type Codec int32

const (
	Codec_H264Codec     Codec = 0
	Codec_MByteVC1Codec Codec = 1
	Codec_OByteVC1Codec Codec = 2
	Codec_OPUSCodec     Codec = 4
	Codec_AACCodec      Codec = 5
	Codec_MP3Codec      Codec = 6
	Codec_ByteVC1Codec  Codec = 7
	Codec_H266Codec     Codec = 9
)

type Format int32

const (
	Format_UndefinedFormat Format = 0
	Format_MP4Format       Format = 1
	Format_M4AFormat       Format = 2
	Format_M3U8Format      Format = 4
	Format_GIFFormat       Format = 5
	Format_DASHFormat      Format = 6
	Format_OGGFormat       Format = 7
	Format_FMP4Format      Format = 8
	Format_HLSFormat       Format = 9
	Format_MP3Format       Format = 10
)

type Definition int32

const (
	Definition_AllDefinition    Definition = 0
	Definition_V360PDefinition  Definition = 1
	Definition_V480PDefinition  Definition = 2
	Definition_V720PDefinition  Definition = 3
	Definition_V1080PDefinition Definition = 4
	Definition_V240PDefinition  Definition = 5
	Definition_V540PDefinition  Definition = 6
	Definition_V420PDefinition  Definition = 8
	Definition_V2KDefinition    Definition = 9
	Definition_V4KDefinition    Definition = 10
)

type CdnType int32

const (
	CdnType_NormalCdnType    CdnType = 0
	CdnType_P2PCdnType       CdnType = 1
	CdnType_OwnVDPCdnType    CdnType = 2
	CdnType_KsyP2PCdnType    CdnType = 3
	CdnType_YunFanP2PCdnType CdnType = 4
	CdnType_AliyunP2PCdnType CdnType = 5
	CdnType_WangsuP2PCdnType CdnType = 6
	CdnType_OthersP2PCdnType CdnType = 20
)

type GetFeedStreamRequest struct {
	Offset             int        `json:"offset"`
	PageSize           int        `json:"pageSize"`
	VideoType          int        `json:"videoType"`
	AppID              string     `json:"AppId" form:"AppId"`
	Vid                string     `json:"vid" form:"vid"`
	Format             Format     `json:"format" form:"format"`
	Codec              Codec      `json:"codec" form:"codec"`
	Definition         Definition `json:"definition" form:"definition"`
	FileType           string     `json:"fileType" form:"fileType"`
	NeedThumbs         bool       `json:"needThumbs" form:"needThumbs"`
	NeedSsl            bool       `json:"needSsl" form:"needSsl"`
	LogoType           string     `json:"logoType" form:"logoType"`
	NeedBarrageMask    bool       `json:"needBarrageMask" form:"needBarrageMask"`
	CdnType            CdnType    `json:"cdnType" form:"cdnType"`
	UnionInfo          string     `json:"UnionInfo" form:"UnionInfo"`
	HdrDefinition      string     `json:"hdrDefinition" form:"hdrDefinition"`
	DrmExpireTimestamp string     `json:"drmExpireTimestamp" form:"drmExpireTimestamp"`
	Quality            string     `json:"quality" form:"quality"`
}
