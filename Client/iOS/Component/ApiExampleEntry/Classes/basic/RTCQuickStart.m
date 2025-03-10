// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "RTCQuickStart.h"
#import "RTCJoinRTS.h"


@implementation RTCQuickStart

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_quick_start", @"APIExample");
        self.iconName = @"function_icon_rtc_quickstart";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"QuickStartViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_quick_start", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
