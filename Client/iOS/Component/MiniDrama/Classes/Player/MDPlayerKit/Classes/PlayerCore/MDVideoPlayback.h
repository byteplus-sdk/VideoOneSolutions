//
//  MDVideoPlayback.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/3.
//  Copyright © 2021 ByteDance. All rights reserved.
//

@import Foundation;

#import <TTSDK/TTVideoEngineModelDef.h>
#import <TTSDK/TTVideoEngineHeader.h>
#import <TTSDK/TTVideoEngineMediaSource.h>
#import "MDPlayFinishStatus.h"
#import "MDVideoPlaybackDefine.h"

@protocol MDVideoPlayback;

@protocol MDVideoPlaybackDelegate <NSObject>

@optional

- (void)videoPlayerPrepared:(id<MDVideoPlayback> _Nullable)player;

- (void)videoPlayerReadyToDisplay:(id<MDVideoPlayback> _Nullable)player;

- (void)videoPlayer:(id<MDVideoPlayback> _Nullable)player loadStateDidChange:(MDVideoLoadState)state;

- (void)videoPlayer:(id<MDVideoPlayback> _Nullable)player playbackStateDidChange:(MDVideoPlaybackState)state;

- (void)videoPlayer:(id<MDVideoPlayback> _Nullable)player didFinishedWithStatus:(MDPlayFinishStatus *_Nullable)finishStatus;

- (void)videoPlayer:(id<MDVideoPlayback> _Nullable)player key:(NSString * _Nullable)key hitVideoPreloadDataSize:(NSInteger)dataSize;

- (void)videoPlayerBitrateDidChange:(id<MDVideoPlayback> _Nullable)player resolution:(TTVideoEngineResolutionType)resolution bitrate:(NSInteger)bitrate;

- (void)videoPlayerViewSizeDidChange:(id<MDVideoPlayback> _Nullable)player videoWidth:(NSInteger)videoWidth videoHeight:(NSInteger)videoHeight;

- (void)videoPlayer:(id<MDVideoPlayback> _Nullable)player fetchedVideoModel:(TTVideoEngineModel *_Nonnull)videoModel;

@end


@protocol MDVideoPlayback <NSObject>

@property (nonatomic, weak, nullable) id<MDVideoPlaybackDelegate> delegate;
@property (nonatomic, strong, nullable, readonly) UIView *playerView;

@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval currentPlaybackTime;
@property (nonatomic, assign, readonly) NSTimeInterval playableDuration;

@property (nonatomic, assign, readonly) MDVideoPlaybackState playbackState;
@property (nonatomic, assign, readonly) MDVideoLoadState loadState;

@property (nonatomic, assign) MDVideoViewMode videoViewMode;

@property (nonatomic, assign) NSTimeInterval startTime;

@property (nonatomic, assign) CGFloat playbackRate;
@property (nonatomic, assign) CGFloat playbackVolume;

@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) BOOL audioMode;
@property (nonatomic, assign) BOOL looping;
/// download speed (KB / s)
@property (nonatomic, assign) CGFloat netWorkSpeed;

@property (nonatomic, strong, nullable) NSString *playerTitle;

/// Set play media source, initialization TTVideoEngine
/// @param mediaSource media source
- (void)setMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;
- (id<TTVideoEngineMediaSource>_Nullable)mediaSource;

/// Play with media source
/// @param mediaSource media source
- (void)playWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;

- (void)prepareToPlay;
- (void)play;
- (void)pause;
- (void)stop;
- (void)close;

- (BOOL)isPlaying;
- (BOOL)isPause;

/// Seek to a given time.
/// @param time the time to seek to, in seconds.
/// @param finised the completion handler
/// @param renderComplete called when seek complete and target time video or audio rendered
- (void)seekToTime:(NSTimeInterval)time
          complete:(void(^ _Nullable)(BOOL success))finised
    renderComplete:(void(^ _Nullable)(void)) renderComplete;

@end




