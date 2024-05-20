// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELPullBasicSettingDelegate_h
#define VELPullBasicSettingDelegate_h

#import <MediaLive/VELSettings.h>
#import <MediaLive/VELCore.h>

@protocol VELPullBasicSettingDelegate <NSObject>
@optional
- (void)play;
- (void)stop;
- (void)pause;
- (void)resume;
- (void)startPlayInBackground;
- (void)stopPlayInBackground;
- (BOOL)resolutionShouldChanged:(VELPullResolutionType)fromResolution to:(VELPullResolutionType)toResolution;
- (void)resolutionDidChanged:(VELPullResolutionType)fromResolution to:(VELPullResolutionType)toResolution;
- (void)openHDR;
- (void)closeHDR;
- (BOOL)isSupportHDR;
- (void)showCycleInfo;
- (void)hideCycleInfo;
- (void)showCallbackNote;
- (void)hideCallbackNote;
@end


#endif /* VELPullBasicSettingDelegate_h */
