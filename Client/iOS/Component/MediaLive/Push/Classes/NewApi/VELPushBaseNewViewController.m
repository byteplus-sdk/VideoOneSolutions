// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushBaseNewViewController.h"
#import "VELPushUIViewController+Preview.h"
#import <MediaLive/VELCore.h>

#define LOG_TAG @"NEW_PUSH_BASE"
@interface VELPushBaseNewViewController ()
@property (nonatomic, strong) VELIQKeyboardManager *keyboardManager;
@end

@implementation VELPushBaseNewViewController

+ (BOOL)isEnabled {
    return  YES;
}

- (void)setupUIForNotStreaming {
    [super setupUIForNotStreaming];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.keyboardManager = [[VELIQKeyboardManager alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.keyboardManager.enable = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.keyboardManager.enable = NO;
    self.keyboardManager = nil;
}

@end
