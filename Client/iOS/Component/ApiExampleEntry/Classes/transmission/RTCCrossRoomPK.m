//
//  RTCCrossRoomPK.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCCrossRoomPK.h"
#import "RTCJoinRTS.h"


@implementation RTCCrossRoomPK

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_cross_room_pk", @"APIExample");
        self.iconName = @"function_icon_rtc_pk";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"CrossRoomPKViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_cross_room_pk", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
