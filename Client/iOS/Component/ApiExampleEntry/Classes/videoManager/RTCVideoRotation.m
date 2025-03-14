// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "RTCVideoRotation.h"
#import "RTCJoinRTS.h"


@implementation RTCVideoRotation

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_video_rotation", @"APIExample");
        self.iconName = @"function_icon_rtc_video_rotation";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"VideoRotationViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_video_rotation", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
