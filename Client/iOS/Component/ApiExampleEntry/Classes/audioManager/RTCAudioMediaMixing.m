// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "RTCAudioMediaMixing.h"
#import "RTCJoinRTS.h"


@implementation RTCAudioMediaMixing

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"title_audio_media_mixing", @"APIExample");
        self.iconName = @"function_icon_rtc_audio_media";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"AudioMediaMixingViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"title_audio_media_mixing", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
