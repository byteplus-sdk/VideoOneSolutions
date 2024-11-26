//
//  RTCNormalSei.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCNormalSei.h"
#import "RTCJoinRTS.h"


@implementation RTCNormalSei

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_sei_messaging", @"APIExample");
        self.iconName = @"function_icon_rtc_sei";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"SEIViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_sei_messaging", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
