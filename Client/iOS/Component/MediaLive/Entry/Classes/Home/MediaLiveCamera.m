// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <ToolKit/ToolKit.h>
#import <ToolKit/Localizator.h>
#import "MediaLiveCamera.h"
#import "VELPushInnerNewViewController.h"

@implementation MediaLiveCamera

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"medialive_camera_entry_title", @"MediaLive");
        self.iconName = @"function_icon_live_camera";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL))block {
    [super enterWithCallback:block];
    VELPushInnerNewViewController *vc = [[VELPushInnerNewViewController alloc] initWithCaptureType:VELSettingCaptureTypeInner];
    UIViewController *topVC = [DeviceInforTool topViewController];
    [topVC.navigationController pushViewController:vc animated:YES];
    if (block) {
        block(YES);
    }
}

@end
