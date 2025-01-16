//
//  MDVideoPlaybackDefine.h
//  MDPlayerKit
//

#ifndef MDVideoPlaybackDefine_h
#define MDVideoPlaybackDefine_h


typedef NS_ENUM(NSUInteger, MDPlayerVideoSource) {
    MDPlayerVideoSourceFromUnknown,
    MDPlayerVideoSourceFromVid,///vid
    MDPlayerVideoSourceFromLocal,///本地播放视频
    MDPlayerVideoSourceFromUrl,///远程播放地址
    MDPlayerVideoSourceFromUrlArray, ///远程播放地址数组
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
    MDVideoPlayFinishStatusType_SystemFinish = 1 << 0,   /// 系统正常播放结束 或者 出错结束（数据源出错，播放过程中出错）
    MDVideoPlayFinishStatusType_UserFinish = 1 << 1,     /// 用户手动调用 stop
    MDVideoPlayFinishStatusType_CloseAnsync = 1 << 2,    /// closeAnsync
    MDVideoPlayFinishStatusType_Finish = MDVideoPlayFinishStatusType_SystemFinish | MDVideoPlayFinishStatusType_UserFinish | MDVideoPlayFinishStatusType_CloseAnsync,
};

#endif /* MDVideoPlaybackDefine_h */
