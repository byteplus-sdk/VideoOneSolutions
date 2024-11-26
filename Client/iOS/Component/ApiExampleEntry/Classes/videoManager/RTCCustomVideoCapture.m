//
//  RTCVideoPip.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCCustomVideoCapture.h"
#import "RTCJoinRTS.h"


@implementation RTCCustomVideoCapture

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_custom_video_capture", @"APIExample");
        self.iconName = @"function_icon_rtc_custom_video_capture";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"CustomVideoCaptureViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_custom_video_capture", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
