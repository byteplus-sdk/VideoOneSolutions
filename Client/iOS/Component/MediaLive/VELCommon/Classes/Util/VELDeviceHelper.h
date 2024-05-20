// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VELDeviceHelper : NSObject
+ (CGFloat)statusBarHeight;
+ (CGFloat)navigationBarHeight;
+ (BOOL)isNotchScreen;
+ (BOOL)isLandSpace;
+ (UIEdgeInsets)safeAreaInsets;
+ (void)requestCameraAuthorization:(void (^)(BOOL granted))handler;
+ (void)requestMicrophoneAuthorization:(void (^)(BOOL granted))handler;
+ (void)sendFeedback;
+ (void)setPlaybackAudioSessionWithOptions:(AVAudioSessionCategoryOptions)options;
@end
