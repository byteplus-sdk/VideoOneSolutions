//
//  RTCPushCDN.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCPushCDN.h"
#import "RTCJoinRTS.h"

@implementation RTCPushCDN

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_cdn_stream", @"APIExample");
        self.iconName = @"function_icon_rtc_push_cdn";
        self.bundleName = @"App";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"PushCDNViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_cdn_stream", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
