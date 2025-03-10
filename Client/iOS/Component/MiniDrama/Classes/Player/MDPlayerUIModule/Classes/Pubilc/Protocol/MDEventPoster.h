// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#pragma mark ----- Public Event
#pragma mark ----- Call Play Event
// Player should play.
extern NSString *const MDPlayEventPlay;
// Player should pause.
extern NSString *const MDPlayEventPause;
// Player should seek.
extern NSString *const MDPlayEventSeek;
// Player should change loop mode, param -> MDEventPoster.loopPlayOpen.
extern NSString *const MDPlayEventChangeLoopPlayMode;
// Player super resolution enbale
extern NSString *const MDPlayEventChangeSREnable;

extern NSString *const MDUIEventScreenOrientationChanged;


#pragma mark ----- Play Callback Event
// Player progress did changed, param @{MDPlayEventProgressValueIncrease : (NSNumber *)}.
extern NSString *const MDPlayEventProgressValueIncrease;
// Player state did changed, param -> MDEventPoster.currentPlaybackState or @{MDPlayEventStateChanged : @{(NSString *)state : NSDictionary *(stateChangeInfo)}}.
extern NSString *const MDPlayEventStateChanged;
// Player time interval did changed, param -> @{MDPlayEventTimeIntervalChanged : (NSNumber *)}.
extern NSString *const MDPlayEventTimeIntervalChanged;
// Player current resolution did changed, param -> MDEventPoster.currentResolution or @{MDPlayEventResolutionChanged : @{(NSInteger)resolution : NSDictionary *(resolutionChangeInfo)}}.
extern NSString *const MDPlayEventResolutionChanged;
// Player current play speed ratio did changed, param -> MDEventPoster.currentPlaySpeed or @{MDPlayEventPlaySpeedChanged : @{(NSInteger)speed : NSDictionary *(speedChangeInfo)}}.
extern NSString *const MDPlayEventPlaySpeedChanged;

extern NSString *const MDPlayEventEpisodesChanged;

extern NSString *const MDPlayEventPiPStatusChanged;

#pragma mark ----- Call UI Event
// The screen of MDInterface should rotation.
extern NSString *const MDUIEventScreenRotation;
// The page of MDInterface should back.
extern NSString *const MDUIEventPageBack;
// MDInterface should lock, param -> MDEventPoster.screenIsLocking
extern NSString *const MDUIEventLockScreen;
// MDInterface pip, param -> MDEventPoster.startPip
extern NSString *const MDUIEventStartPip;
// MDInterface should clear, param -> MDEventPoster.screenIsClear
extern NSString *const MDUIEventClearScreen;
// MDInterface should show slide menu.
extern NSString *const MDUIEventShowMoreMenu;
// MDInterface should show resolution menu.
extern NSString *const MDUIEventShowResolutionMenu;
// MDInterface should show play speed menu.
extern NSString *const MDUIEventShowPlaySpeedMenu;
// show smart subtitle
extern NSString *const MDPlayEventShowSubtitleMenu;
extern NSString *const MDPlayEventSmartSubtitleChanged;
// MDInterface should show episodes view;
extern NSString *const MDUIEventShowEpisodesView;
// The volume should changed which implemented in protocol 'MDPlayProtocol'.
extern NSString *const MDUIEventVolumeIncrease;
// The brightness should changed which implemented in protocol 'MDPlayProtocol'.
extern NSString *const MDUIEventBrightnessIncrease;


#pragma mark ----- UI Callback Event
// MDInterface's state of lock did changed, param -> MDEventPoster.screenIsLocking
extern NSString *const MDUIEventScreenLockStateChanged;
// MDInterface's state of screen clear did changed, param -> MDEventPoster.screenIsClear or @{MDUIEventClearScreen : (NSNumber *)}.
extern NSString *const MDUIEventScreenClearStateChanged;


#import "MDPlayProtocol.h"
@protocol MDInterfaceElementDescription;

@interface MDEventPoster : NSObject

+ (instancetype)currentPoster;

+ (void)destroyUnit;

// The playback state of the player current runing.
- (MDPlaybackState)currentPlaybackState;
// The play duration of the player current runing.
- (NSTimeInterval)duration;
// The cache duration of current player loaded.
- (NSTimeInterval)playableDuration;
// The play title of current play session.
- (NSString *)title;
// The loop mode of the player current runing.
- (BOOL)loopPlayOpen;
// super resolution open
- (BOOL)srOpen;
// The play speed range which you want in protocol 'MDPlayProtocol'.
- (NSArray *)playSpeedSet;
// The method param by play speed of the player current runing.
- (CGFloat)currentPlaySpeed;
// The UI display param by play speed of the player current runing.
- (NSString *)currentPlaySpeedForDisplay;
// The resolutions all you want in protocol 'MDPlayProtocol'.
- (NSArray *)resolutionSet;
// The method param by resolution of the player current runing.
- (NSInteger)currentResolution;
// The UI display param by resolution of the player current runing.
- (NSString *)currentResolutionForDisplay;
// The volume value of you want which implemented in protocol 'MDPlayProtocol'.
- (CGFloat)currentVolume;
// The brightness value of you want which implemented in protocol 'MDPlayProtocol'.
- (CGFloat)currentBrightness;
// The locking state of MDInterface.
- (BOOL)screenIsLocking;
// The clear state of MDInterface.
- (BOOL)screenIsClear;

- (BOOL)isPipOpen;
- (void)enablePIP:(void (^)(BOOL isOpenPip))block;
- (void)disablePIP;
@end
