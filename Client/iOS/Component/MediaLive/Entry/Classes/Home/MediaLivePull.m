// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <ToolKit/ToolKit.h>
#import <ToolKit/Localizator.h>
#import "MediaLivePull.h"
#import "VELPullViewController.h"

@implementation MediaLivePull

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"medialive_pull_entry_title", @"MediaLive");
        self.iconName = @"function_icon_live_pull";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL))block {
    [super enterWithCallback:block];
    VELPullViewController *vc = [[VELPullViewController alloc] init];
    UIViewController *topVC = [DeviceInforTool topViewController];
    [topVC.navigationController pushViewController:vc animated:YES];
    if (block) {
        block(YES);
    }
}

@end
