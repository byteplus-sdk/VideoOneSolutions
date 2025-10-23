// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

// 短剧频道数据模型
export interface DramaChannelMeta {
  dramaId: string;
  dramaTitle: string;
  dramaPlayTimes: number;
  dramaCoverUrl: string;
  newRelease: boolean;
  dramaLength: number;
  dramaVideoOrientation: number;
}

// 短剧频道数据结构
export interface DramaChannelData {
  loop: DramaChannelMeta[];
  trending: DramaChannelMeta[];
  new: DramaChannelMeta[];
  recommend: DramaChannelMeta[];
}

// 短剧列表项组件属性
export interface DramaItemProps {
  drama: DramaChannelMeta;
  onPress: (drama: DramaChannelMeta) => void;
  showRank?: boolean;
  rank?: number;
  showPlayCount?: boolean;
  showNewBadge?: boolean;
  width?: number;
  height?: number;
}

// 轮播图组件属性
export interface CarouselProps {
  data: DramaMeta[];
  onItemPress: (drama: DramaMeta) => void;
}

// 列表组件属性
export interface DramaListProps {
  data: DramaMeta[];
  onItemPress: (drama: DramaMeta) => void;
  type: "trending" | "new" | "recommend";
}

// API响应数据结构
export interface DramaApiResponse {
  code: number;
  message: string;
  response: {
    loop: DramaApiItem[];
    trending: DramaApiItem[];
    new: DramaApiItem[];
    recommend: DramaApiItem[];
  };
}

// API返回的原始数据项
export interface DramaApiItem {
  drama_id: string;
  drama_title: string;
  drama_play_times: number;
  drama_cover_url: string;
  new_release: boolean;
  drama_length: number;
  drama_video_orientation: number;
}

// 剧集数据结构
export interface DramaEpisode {
  vid: string;
  drama_id: string;
  caption: string;
  duration: number;
  cover_url: string;
  video_model: string;
  play_times: number;
  subtitle: string;
  create_time: string;
  name: string;
  uid: number;
  like: number;
  comment: number;
  height: number;
  width: number;
  order: number;
  display_type: number;
  subtitle_auth_token: string;
  vip: boolean;
}

// Feed流相关类型定义
export interface DramaMeta {
  drama_id: string;
  drama_title: string;
  drama_play_times: number;
  drama_cover_url: string;
  new_release: boolean;
  drama_length: number;
  drama_video_orientation: number;
}

export interface VideoMeta {
  vid: string;
  drama_id: string;
  caption: string;
  duration: number;
  cover_url: string;
  video_model: string;
  play_times: number;
  subtitle: string;
  create_time: string;
  name: string;
  uid: number;
  like: number;
  comment: number;
  height: number;
  width: number;
  order: number;
  display_type: number;
  subtitle_auth_token: string;
  vip: boolean;
}

export interface FeedItem {
  drama_meta: DramaMeta;
  video_meta: VideoMeta;
}

export interface FeedResponse {
  message_type: string;
  code: number;
  request_id: string;
  message: string;
  timestamp: number;
  response: FeedItem[];
  responseMetadata: {
    requestId: string;
    action: string;
    version: string;
    service: string;
    region: string;
  };
}

export interface IVolume {
  Loudness: number;
  Peak: number;
}

/** {zh}
 * @hidden
 */
export interface IPlayInfoListItem {
  BackupPlayUrl: string;
  BackupUrlExpire: string;
  BarrageMaskOffset: string;
  Bitrate: number;
  CheckInfo: string;
  Codec: string;
  Definition: string;
  Duration: number;
  FileId: string;
  FileType: string;
  Format: string;
  Height: number;
  IndexRange: string;
  InitRange: string;
  KeyFrameAlignment: string;
  LogoType: string;
  MainPlayUrl: string;
  MainUrlExpire: string;
  Md5: string;
  PlayAuth: string;
  PlayAuthId: string;
  Quality: string;
  Size: number;
  Volume?: number;
  Width: number;
  DrmType?: string;
}

export interface ISubtitleInfoList {
  CreateTime: string;
  FileId: string;
  Format: string;
  Language: string;
  LanguageId: number;
  Source: string;
  Status: string;
  StoreUri: string;
  SubtitleId: string;
  SubtitleUrl: string;
  Tag: string;
  Title: string;
  Version: string;
  Vid: string;
}

export interface IThumbInfoItem {
  CaptureNum: number;
  CellHeight: number;
  CellWidth: number;
  Format: string;
  ImgXLen: number;
  ImgYLen: number;
  Interval: number;
  StoreUrls: string[];
}

export interface IBarrageMaskInfo {
  Version: string;
  BarrageMaskUrl: string;
  FileId: string;
  FileSize: number;
  FileHash: string;
  UpdatedAt: string;
  Bitrate: number;
  HeadLen: number;
}

interface DashAdaptiveInfo {
  AdaptiveType: string;
  BackupPlayUrl: string;
  MainPlayUrl: string;
}

export interface ABRInfo {
  AbrFormat: string;
  BackupPlayUrl: string;
  MainPlayUrl: string;
}

export interface DramaVideoModel {
  Vid: string;
  AdaptiveInfo?: DashAdaptiveInfo;
  AdaptiveBitrateStreamingInfo?: ABRInfo;
  BarrageMaskInfo?: IBarrageMaskInfo;
  BarrageMaskUrl: string;
  Duration: number;
  EnableAdaptive: boolean;
  FileType: string;
  PlayInfoList: IPlayInfoListItem[];
  PosterUrl: string;
  Status: number;
  SubtitleInfoList: ISubtitleInfoList[];
  ThumbInfoList: IThumbInfoItem[];
  TotalCount: number;
  Version: number;
}

// 剧集列表API响应
export interface DramaListApiResponse {
  message_type: string;
  code: number;
  request_id: string;
  message: string;
  timestamp: number;
  response: DramaEpisode[];
  responseMetadata: {
    requestId: string;
    action: string;
    version: string;
    service: string;
    region: string;
  };
}

// 剧集列表请求参数
export interface DramaListRequestParams {
  drama_id: string;
}
