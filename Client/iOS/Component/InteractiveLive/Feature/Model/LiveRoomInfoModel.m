// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRoomInfoModel.h"

@implementation LiveRoomInfoModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"liveAppID": @"live_app_id",
        @"rtcAppID": @"rtc_app_id",
        @"roomID": @"room_id",
        @"roomName": @"room_name",
        @"anchorUserID": @"host_user_id",
        @"anchorUserName": @"host_user_name",
        @"startTime": @"start_time",
        @"audienceCount": @"audience_count",
        @"streamPullStreamList": @"stream_pull_url_list",
    };
}

- (NSDate *)startTime {
    if (!_startTime) {
        _startTime = [NSDate date];
    }
    return _startTime;
}

@end
