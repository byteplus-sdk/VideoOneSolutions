// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "RTCAudioRawData.h"
#import "RTCJoinRTS.h"


@implementation RTCAudioRawData

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_raw_audio_data", @"APIExample");
        self.iconName = @"function_icon_rtc_raw_audio";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"AudioRawDataViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_raw_audio_data", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
