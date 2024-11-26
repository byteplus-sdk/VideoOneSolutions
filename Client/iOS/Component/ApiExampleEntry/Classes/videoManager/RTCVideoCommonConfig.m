//
//  RTCVideoCommonConfig.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCVideoCommonConfig.h"
#import "RTCJoinRTS.h"


@implementation RTCVideoCommonConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_video_config", @"APIExample");
        self.iconName = @"function_icon_rtc_video_config";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"CommonVideoConfigViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_video_config", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}


@end
