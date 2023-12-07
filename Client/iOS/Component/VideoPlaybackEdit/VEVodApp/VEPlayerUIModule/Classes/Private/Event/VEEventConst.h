// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEEventMessageBus.h"
#import "VEEventPoster+Private.h"

// static string，implement it when post this event
#pragma mark----- task message

extern NSString *const VETaskPlayCoreTransfer;

#pragma mark----- Call Play Event

extern NSString *const VEPlayEventPlay;

extern NSString *const VEPlayEventPause;

extern NSString *const VEPlayEventSeek;

extern NSString *const VEPlayEventProgressValueIncrease;

extern NSString *const VEPlayEventChangeLoopPlayMode;

extern NSString *const VEPlayEventChangePlaySpeed;

extern NSString *const VEPlayEventChangeResolution;

#pragma mark----- Play Callback Event

extern NSString *const VEPlayEventStateChanged;

extern NSString *const VEPlayEventTimeIntervalChanged;

extern NSString *const VEPlayEventResolutionChanged;

extern NSString *const VEPlayEventPlaySpeedChanged;

#pragma mark----- UI Event

extern NSString *const VEUIEventPageBack;

extern NSString *const VEUIEventScreenRotation;

extern NSString *const VEUIEventScreenOrientationChanged;

extern NSString *const VEUIEventShowMoreMenu;

extern NSString *const VEUIEventShowResolutionMenu;

extern NSString *const VEUIEventShowPlaySpeedMenu;

extern NSString *const VEUIEventLockScreen;

extern NSString *const VEUIEventScreenLockStateChanged;

extern NSString *const VEUIEventClearScreen;

extern NSString *const VEUIEventScreenClearStateChanged;

extern NSString *const VEUIEventSeeking;

extern NSString *const VEUIEventVolumeIncrease;

extern NSString *const VEUIEventBrightnessIncrease;

extern NSString *const VEUIEventReport;

extern NSString *const VEUIEventLikeVideo;
