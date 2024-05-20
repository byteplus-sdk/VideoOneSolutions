// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushUIViewController.h"
#import <MediaLive/VELCore.h>
#import <MediaLive/VELCommon.h>
NS_ASSUME_NONNULL_BEGIN

@interface VELPushBaseNewViewController : VELPushUIViewController
+ (BOOL)isEnabled;
- (void)setupUIForNotStreaming;
@end

NS_ASSUME_NONNULL_END
