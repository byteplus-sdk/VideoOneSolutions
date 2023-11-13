// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveReconnectModel.h"

@implementation LiveReconnectModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"rtcUserList": [LiveUserModel class]};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"roomModel": @"live_room_info",
        @"streamPushUrl": @"stream_push_url",
        @"rtcRoomID": @"rtc_room_id",
        @"rtcToken": @"rtc_token",
        @"rtcUserList": @"linkmic_user_list",
    };
}

@end
