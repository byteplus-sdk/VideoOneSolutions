//
//  RTCByteAIBeauty.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCByteAIBeauty.h"
#import "RTCJoinRTS.h"

@implementation RTCByteAIBeauty

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"title_byte_beauty", @"APIExample");
        self.iconName = @"function_icon_rtc_beauty";
        self.bundleName = @"App";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"VolcBeautyViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"title_byte_beauty", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}
@end
