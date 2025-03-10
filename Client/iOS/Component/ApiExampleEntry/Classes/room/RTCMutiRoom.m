// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "RTCMutiRoom.h"
#import "RTCJoinRTS.h"


@implementation RTCMutiRoom

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_multi_room", @"APIExample");
        self.iconName = @"function_icon_rtc_multiroom";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"MutiRoomViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_multi_room", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
