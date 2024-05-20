// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

typedef NS_ENUM(NSInteger, VEPlaybackState) {
    VEPlaybackStateUnknown = 0,
    VEPlaybackStatePlaying,
    VEPlaybackStatePaused,
    VEPlaybackStateStopped,
    VEPlaybackStateError,
    VEPlaybackStateFinished,
    VEPlaybackStateFinishedBecauseUser
};

typedef NS_ENUM(NSInteger, VEPlaybackLoadState) {
    VEPlaybackLoadStateUnkown = 0,
    VEPlaybackLoadStateStalled,
    VEPlaybackLoadStatePlayable,
    VEPlaybackLoadStateError
};

typedef NS_ENUM(NSInteger, PIPManagerStatus) {
    PIPManagerStatusNone,
    PIPManagerStatusStartSuccess,
    PIPManagerStatusParameterFailed,
    PIPManagerStatusPermissionFailed,
    PIPManagerStatusDeviceSupportFailure,
    PIPManagerStatusExceptionFailed,
};

@protocol VEPlayCoreAbilityProtocol;

@protocol VEPlayCoreCallBackAbilityProtocol <NSObject>

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core playbackStateDidChanged:(VEPlaybackState)currentState info:(NSDictionary *)info;

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core playTimeDidChanged:(NSTimeInterval)interval info:(NSDictionary *)info;

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core resolutionChanged:(NSInteger)currentResolution info:(NSDictionary *)info;

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core loadStateDidChange:(VEPlaybackLoadState)state;

- (void)playerCoreReadyToPlay:(id<VEPlayCoreAbilityProtocol>)core;

@end

@protocol VEPlayCoreAbilityProtocol <NSObject>

// The receiver means you should provide a instance to help the implementor of this protocol(VEPlayCoreAbilityProtocol) to notify message of protocol 'VEPlayCoreCallBackAbilityProtocol'.
@property (nonatomic, weak) id<VEPlayCoreCallBackAbilityProtocol> receiver;

// Looping means a switcher, if looping = YES, it will start a new play action by interval zero after play end.
@property (nonatomic, assign) BOOL looping;

// Playback speed means the speed how many times faster do you want it to be.
@property (nonatomic, assign) CGFloat playbackSpeed;

// Current resolution means the resolution type now using.
@property (nonatomic, assign) NSInteger currentResolution;

// The volume of system / Player core.
@property (nonatomic, assign) CGFloat volume;

@property (nonatomic, assign) BOOL muted;

// Play method fire player start.
- (void)play;

// Pause method fire player temporary stop.
- (void)pause;

// Seek method fire player to find the point which you give(destination).
- (void)seek:(NSTimeInterval)destination;

// Reture the current state of VEInterface, not origin player state.
- (VEPlaybackState)currentPlaybackState;

// Reture the current load state of VEInterface, not origin player state.
- (VEPlaybackLoadState)currentLoadState;

// Reture the title of current playing video.
- (NSString *)title;

// Return the duration of current playing video.
- (NSTimeInterval)duration;

// Return the duration of the cached data can support playing.
- (NSTimeInterval)playableDuration;

// Current playback time
- (NSTimeInterval)currentPlaybackTime;

// Accurate watched duration.
- (NSTimeInterval)durationWatched;

/**
 * Return the map of play speed.
 * @"1.5x" : @(1.5) -> UI-title : speed-param
 */
- (NSArray<NSDictionary<NSString *, NSNumber *> *> *)playSpeedSet;

/**
 * Return the map of resolution can be play.
 * @"720P" : @"720" -> UI-title : resolution-Key
 */
- (NSArray<NSDictionary<NSString *, NSString *> *> *)resolutionSet;

- (UIView *)playerView;

- (void)setCloseResumePlay:(BOOL)closeResumePlay;

@end
