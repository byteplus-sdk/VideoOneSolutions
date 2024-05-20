// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MediaLiveAll.h"
#import "VELHomeViewController.h"
#import <ToolKit/ToolKit.h>
#import <ToolKit/Localizator.h>

@implementation MediaLiveAll

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"medialive_entry_title", @"MediaLive");
        self.des = LocalizedStringFromBundle(@"medialive_entry_des", @"MediaLive");
        self.iconName = @"function_icon_media_live";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL))block {
    [super enterWithCallback:block];
    VELHomeViewController *vc = [[VELHomeViewController alloc] init];
    UIViewController *topVC = [DeviceInforTool topViewController];
    [topVC.navigationController pushViewController:vc animated:YES];
    if (block) {
        block(YES);
    }
}
@end

