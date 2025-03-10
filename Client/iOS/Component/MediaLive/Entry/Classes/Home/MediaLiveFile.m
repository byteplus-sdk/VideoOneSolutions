// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <ToolKit/ToolKit.h>
#import <ToolKit/Localizator.h>
#import "MediaLiveFile.h"
#import "VELPushFileNewViewController.h"

@implementation MediaLiveFile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"medialive_file_entry_title", @"MediaLive");
        self.iconName = @"function_icon_live_file";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL))block {
    [super enterWithCallback:block];
    VELPushFileNewViewController *vc = [[VELPushFileNewViewController alloc] initWithCaptureType:VELSettingCaptureTypeFile];
    UIViewController *topVC = [DeviceInforTool topViewController];
    [topVC.navigationController pushViewController:vc animated:YES];
    if (block) {
        block(YES);
    }
}

@end
