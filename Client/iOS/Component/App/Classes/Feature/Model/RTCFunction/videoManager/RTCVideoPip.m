//
//  RTCVideoPip.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCVideoPip.h"
#import "RTCJoinRTS.h"


@implementation RTCVideoPip

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_picture_in_picture", @"APIExample");
        self.iconName = @"function_icon_rtc_pip";
        self.bundleName = @"App";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"PipViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_picture_in_picture", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
