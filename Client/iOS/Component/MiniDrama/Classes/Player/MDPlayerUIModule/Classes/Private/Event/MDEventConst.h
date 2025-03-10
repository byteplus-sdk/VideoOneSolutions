// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDEventMessageBus.h"
#import "MDEventPoster+Private.h"
#pragma mark ----- task message

extern NSString *const MDTaskPlayCoreTransfer;

#pragma mark ----- Call Play Event

extern NSString *const MDPlayEventPlay;

extern NSString *const MDPlayEventPause;

extern NSString *const MDPlayEventSeek;

extern NSString *const MDPlayEventProgressValueIncrease;

extern NSString *const MDPlayEventChangeLoopPlayMode;

extern NSString *const MDPlayEventChangeSREnable;

extern NSString *const MDPlayEventChangePlaySpeed;

extern NSString *const MDPlayEventChangeResolution;

extern NSString *const MDUIEventScreenOrientationChanged;


#pragma mark ----- Play Callback Event

extern NSString *const MDPlayEventStateChanged;

extern NSString *const MDPlayEventTimeIntervalChanged;

extern NSString *const MDPlayEventResolutionChanged;

extern NSString *const MDPlayEventPlaySpeedChanged;

extern NSString *const MDPlayEventEpisodesChanged;

extern NSString *const MDPlayEventPiPStatusChanged;

#pragma mark ----- UI Event

extern NSString *const MDUIEventPageBack;

extern NSString *const MDUIEventScreenRotation;

extern NSString *const MDUIEventScreenOrientationChanged;

extern NSString *const MDUIEventShowMoreMenu;

extern NSString *const MDUIEventShowResolutionMenu;

extern NSString *const MDUIEventShowPlaySpeedMenu;

extern NSString *const MDPlayEventShowSubtitleMenu;

extern NSString *const MDPlayEventSmartSubtitleChanged;

extern NSString *const MDUIEventShowEpisodesView;

extern NSString *const MDUIEventLockScreen;

extern NSString *const MDUIEventStartPip;

extern NSString *const MDUIEventScreenLockStateChanged;

extern NSString *const MDUIEventClearScreen;

extern NSString *const MDUIEventScreenClearStateChanged;

extern NSString *const MDUIEventVolumeIncrease;

extern NSString *const MDUIEventBrightnessIncrease;
