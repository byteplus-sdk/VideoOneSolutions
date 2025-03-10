// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef MDVideoPlaybackDefine_h
#define MDVideoPlaybackDefine_h


typedef NS_ENUM(NSUInteger, MDPlayerVideoSource) {
    MDPlayerVideoSourceFromUnknown,
    MDPlayerVideoSourceFromVid,///vid
    MDPlayerVideoSourceFromLocal,
    MDPlayerVideoSourceFromUrl,
    MDPlayerVideoSourceFromUrlArray,
    MDPlayerVideoSourceFromVideoModel,///videoModel
};

typedef NS_ENUM(NSInteger, MDVideoPlaybackState) {
    MDVideoPlaybackStateUnkown = 0,
    MDVideoPlaybackStatePlaying,
    MDVideoPlaybackStatePaused,
    MDVideoPlaybackStateStopped,
    MDVideoPlaybackStateError,
};

typedef NS_ENUM(NSInteger, MDVideoLoadState) {
    MDVideoLoadStateUnkown = 0,
    MDVideoLoadStatePlayable,
    MDVideoLoadStateStalled,
    MDVideoLoadStateError
};

typedef NS_ENUM(NSInteger, MDVideoViewMode) {
    MDVideoViewModeNone = 0,
    MDVideoViewModeAspectFit,
    MDVideoViewModeAspectFill,
    MDVideoViewModeModeFill
};


typedef NS_ENUM(NSUInteger, MDVideoPlayFinishStatusType) {
    MDVideoPlayFinishStatusType_Unknown =  0,
    MDVideoPlayFinishStatusType_SystemFinish = 1 << 0,
    MDVideoPlayFinishStatusType_UserFinish = 1 << 1,
    MDVideoPlayFinishStatusType_CloseAnsync = 1 << 2,    /// closeAnsync
    MDVideoPlayFinishStatusType_Finish = MDVideoPlayFinishStatusType_SystemFinish | MDVideoPlayFinishStatusType_UserFinish | MDVideoPlayFinishStatusType_CloseAnsync,
};

#endif /* MDVideoPlaybackDefine_h */
