//
//  RTCVideoPip.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCCustomVideoEncode.h"
#import "RTCJoinRTS.h"


@implementation RTCCustomVideoEncode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_custom_video_encode", @"APIExample");
        self.iconName = @"function_icon_ rtc_custom_video_encode";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"CustomVideoEncodeVideoCaptureViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_custom_video_encode", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end