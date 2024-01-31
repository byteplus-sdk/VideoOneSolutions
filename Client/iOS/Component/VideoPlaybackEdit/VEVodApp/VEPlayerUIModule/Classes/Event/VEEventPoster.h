// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#pragma mark----- Public Event
#pragma mark----- Call Play Event
// Player should play.
extern NSString *const VEPlayEventPlay;
// Player should pause.
extern NSString *const VEPlayEventPause;
// Player should seek.
extern NSString *const VEPlayEventSeek;
// Player should change loop mode, param -> VEEventPoster.loopPlayOpen.
extern NSString *const VEPlayEventChangeLoopPlayMode;

#pragma mark----- Play Callback Event
// Player progress did changed, param @{VEPlayEventProgressValueIncrease : (NSNumber *)}.
extern NSString *const VEPlayEventProgressValueIncrease;
// Player state did changed, param -> VEEventPoster.currentPlaybackState or @{VEPlayEventStateChanged : @{(NSNumber *)state : NSDictionary *(stateChangeInfo)}}.
extern NSString *const VEPlayEventStateChanged;
// Player load state did changed, param -> VEEventPoster.currentLoadState or @{VEPlayEventLoadStateChanged : (NSNumber *)state}.
extern NSString *const VEPlayEventLoadStateChanged;
// Player time interval did changed, param -> @{VEPlayEventTimeIntervalChanged : (NSNumber *)}.
extern NSString *const VEPlayEventTimeIntervalChanged;
// Player current resolution did changed, param -> VEEventPoster.currentResolution or @{VEPlayEventResolutionChanged : @{(NSInteger)resolution : NSDictionary *(resolutionChangeInfo)}}.
extern NSString *const VEPlayEventResolutionChanged;
// Player current play speed ratio did changed, param -> VEEventPoster.currentPlaySpeed or @{VEPlayEventPlaySpeedChanged : @{(NSInteger)speed : NSDictionary *(speedChangeInfo)}}.
extern NSString *const VEPlayEventPlaySpeedChanged;
// Player current  subTitle did changed
extern NSString *const VEPlayEventSmartSubtitleChanged;

extern NSString *const VEPlayEventPiPStatusChanged;

#pragma mark----- Call UI Event
// The screen of VEInterface should rotation.
extern NSString *const VEUIEventScreenRotation;
// The page of VEInterface should back.
extern NSString *const VEUIEventPageBack;
// VEInterface should lock, param -> VEEventPoster.screenIsLocking
extern NSString *const VEUIEventLockScreen;
// VEInterface should clear, param -> VEEventPoster.screenIsClear
extern NSString *const VEUIEventClearScreen;
// User is seeking.
extern NSString *const VEUIEventSeeking;
// VEInterface should show slide menu.
extern NSString *const VEUIEventShowMoreMenu;
// VEInterface should show resolution menu.
extern NSString *const VEUIEventShowResolutionMenu;
// VEInterface should show play speed menu.
extern NSString *const VEUIEventShowPlaySpeedMenu;
//   VEInterface should show smartSubtitle menu
extern NSString *const VEUIEventShowSubtitleMenu;
// VEInterface should show playList
extern NSString *const VEUIEventShowPlayListMenu;
// player play previous video
extern NSString *const VEUIEventPlayPreviousVideo;
// player play next video
extern NSString *const VEUIEventPlayNextVideo;

// The volume should changed which implemented in protocol 'VEPlayProtocol'.
extern NSString *const VEUIEventVolumeIncrease;
// The brightness should changed which implemented in protocol 'VEPlayProtocol'.
extern NSString *const VEUIEventBrightnessIncrease;

extern NSString *const VEUIEventResetAutoHideController;

#pragma mark----- UI Callback Event
// VEInterface's state of lock did changed, param -> VEEventPoster.screenIsLocking
extern NSString *const VEUIEventScreenLockStateChanged;
// VEInterface's state of screen clear did changed, param -> VEEventPoster.screenIsClear or @{VEUIEventClearScreen : (NSNumber *)}.
extern NSString *const VEUIEventScreenClearStateChanged;

extern NSString *const VEUIEventScreenOrientationChanged;

#import "VEPlayProtocol.h"
@protocol VEInterfaceElementDescription;
@class VEEventMessageBus;
@interface VEEventPoster : NSObject

- (instancetype)initWithEventMessageBus:(VEEventMessageBus *)eventMessageBus;

// The playback state of the player current runing.
- (VEPlaybackState)currentPlaybackState;
// The load state of the player current runing.
- (VEPlaybackLoadState)currentLoadState;
// The play duration of the player current runing.
- (NSTimeInterval)duration;
// The cache duration of current player loaded.
- (NSTimeInterval)playableDuration;
// Current playback time
- (NSTimeInterval)currentPlaybackTime;
// The play title of current play session.
- (NSString *)title;
// The loop mode of the player current runing.
- (BOOL)loopPlayOpen;
// The play speed range which you want in protocol 'VEPlayProtocol'.
- (NSArray *)playSpeedSet;
// The method param by play speed of the player current runing.
- (CGFloat)currentPlaySpeed;
// The UI display param by play speed of the player current runing.
- (NSString *)currentPlaySpeedForDisplay;
// The resolutions all you want in protocol 'VEPlayProtocol'.
- (NSArray *)resolutionSet;
// The method param by resolution of the player current runing.
- (NSInteger)currentResolution;
// The UI display param by resolution of the player current runing.
- (NSString *)currentResolutionForDisplay;
// The volume value of you want which implemented in protocol 'VEPlayProtocol'.
- (CGFloat)currentVolume;
// The brightness value of you want which implemented in protocol 'VEPlayProtocol'.
- (CGFloat)currentBrightness;
// The locking state of VEInterface.
- (BOOL)screenIsLocking;
// The clear state of VEInterface.
- (BOOL)screenIsClear;
// isSeekingProgressByUI. We current won't hide the interface.
- (BOOL)isSeekingProgress;
// Accumulated watched duration, you can check the video has been played by this api.
- (NSTimeInterval)durationWatched;

- (PIPManagerStatus)pipStatus;

- (void)updatePIPPlayUrl:(NSString *)playUrlString;

- (void)cancelPreparePIP;

- (BOOL)isEnabledPIP;

- (void)enablePIP:(void (^)(PIPManagerStatus status))block;

- (void)disablePIP;

@end
