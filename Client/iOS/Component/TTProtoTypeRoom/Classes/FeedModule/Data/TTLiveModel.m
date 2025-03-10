// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "TTLiveModel.h"
#import <ToolKit/ToolKit.h>

@implementation TTLiveModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"appId": @"rtc_app_id",
        @"roomId": @"room_id",
        @"roomName": @"room_name",
        @"hostName": @"host_name",
        @"hostUserId": @"host_user_id",
        @"rtsToken": @"rts_token",
        @"streamDic": @"stream_pull_url_list",
        @"roomDescription": @"room_desc",
        @"coverUrl": @"cover_url",
    };
}
@end
