//
//  RTCVideoPip.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCScreenShare.h"
#import "RTCJoinRTS.h"


@implementation RTCScreenShare

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_screen_share", @"APIExample");
        self.iconName = @"function_icon_rtc_screen_share";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"ScreenShareViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_screen_share", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end