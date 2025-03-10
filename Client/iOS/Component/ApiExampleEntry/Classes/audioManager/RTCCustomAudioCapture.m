// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "RTCCustomAudioCapture.h"
#import "RTCJoinRTS.h"


@implementation RTCCustomAudioCapture

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_custom_audio_capture", @"APIExample");
        self.iconName = @"function_icon_rtc_custom_audio_capture";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"CustomAudioCaptureViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_custom_audio_capture", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
