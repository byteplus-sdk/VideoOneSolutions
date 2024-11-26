//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "PreventRecordingViewController.h"
#import "VEBaseVideoDetailViewController+Private.h"
#import <ToolKit/Localizator.h>
#import <ToolKit/ToastComponent.h>

@implementation PreventRecordingViewController

+ (Class)playerContainerClass {
    return [VEPlayerSecureContainer class];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"prevent_recording_toast", @"VodPlayer")];
}

@end
