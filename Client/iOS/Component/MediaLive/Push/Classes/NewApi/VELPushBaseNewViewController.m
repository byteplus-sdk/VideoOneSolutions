// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushBaseNewViewController.h"
#import "VELPushUIViewController+Preview.h"
#import <MediaLive/VELCore.h>

#define LOG_TAG @"NEW_PUSH_BASE"
@interface VELPushBaseNewViewController ()
@end

@implementation VELPushBaseNewViewController

+ (BOOL)isEnabled {
    return  YES;
}

- (void)setupUIForNotStreaming {
    [super setupUIForNotStreaming];
}

@end
