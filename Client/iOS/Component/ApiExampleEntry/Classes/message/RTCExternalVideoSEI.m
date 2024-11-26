//
//  RTCNormalSei.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCExternalVideoSEI.h"
#import "RTCJoinRTS.h"


@implementation RTCExternalVideoSEI

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_external_video_sei_message", @"APIExample");
        self.iconName = @"function_icon_rtc_sei";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"ExternalVidoeSourceSEIViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_external_video_sei_message", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
