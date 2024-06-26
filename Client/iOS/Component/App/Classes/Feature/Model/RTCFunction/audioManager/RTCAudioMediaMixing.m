//
//  RTCAudioMediaMixing.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCAudioMediaMixing.h"
#import "RTCJoinRTS.h"


@implementation RTCAudioMediaMixing

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"title_audio_media_mixing", @"APIExample");
        self.iconName = @"function_icon_rtc_audio_media";
        self.bundleName = @"App";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"AudioMediaMixingViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"title_audio_media_mixing", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
