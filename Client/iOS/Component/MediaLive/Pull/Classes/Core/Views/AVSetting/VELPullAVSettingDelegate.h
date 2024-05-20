// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELPullAVSettingDelegate_h
#define VELPullAVSettingDelegate_h

#import <MediaLive/VELSettings.h>
#import <MediaLive/VELCore.h>

@protocol VELPullAVSettingDelegate <NSObject>
@optional
- (void)snapshot;
- (void)mute;
- (void)unMute;
- (void)changeVolume:(float)volume;
- (BOOL)isPlaying;
@end

#endif /* VELPullAVSettingDelegate_h */
