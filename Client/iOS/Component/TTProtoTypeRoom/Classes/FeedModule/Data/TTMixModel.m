// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "TTMixModel.h"


@implementation TTMixModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"modelType": @"video_type",
        @"userStatus": @"user_status",
        @"liveModel": @"room_info",
        @"videoModel": @"video_info"
    };
}

@end
