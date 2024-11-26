//
//  RTCVideoPip.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCCustomVideoRender.h"
#import "RTCJoinRTS.h"


@implementation RTCCustomVideoRender

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_custom_video_render", @"APIExample");
        self.iconName = @"function_icon_ rtc_custom_video_render";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"CustomVideoRenderViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_custom_video_render", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
