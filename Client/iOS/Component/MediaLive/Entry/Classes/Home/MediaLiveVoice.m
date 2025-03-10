// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <ToolKit/ToolKit.h>
#import <ToolKit/Localizator.h>
#import "MediaLiveVoice.h"
#import "VELPushAudioOnlyNewViewController.h"


@implementation MediaLiveVoice

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"medialive_voice_entry_title", @"MediaLive");
        self.iconName = @"function_icon_live_voice";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL))block {
    [super enterWithCallback:block];
    VELPushAudioOnlyNewViewController *vc = [[VELPushAudioOnlyNewViewController alloc] initWithCaptureType:VELSettingCaptureTypeAudioOnly];
    UIViewController *topVC = [DeviceInforTool topViewController];
    [topVC.navigationController pushViewController:vc animated:YES];
    if (block) {
        block(YES);
    }
}

@end
