//
//  RTCStreamSyncSei.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCStreamSyncSei.h"
#import "RTCJoinRTS.h"


@implementation RTCStreamSyncSei

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_stream_sync_info", @"APIExample");
        self.iconName = @"function_icon_rtc_frame_sei";
        self.bundleName = @"App";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"AudioSEIViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_stream_sync_info", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
