// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVUserModel.h"

@implementation KTVUserModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"roomID" : @"room_id",
             @"uid" : @"user_id",
             @"name" : @"user_name",
             @"userRole" : @"user_role",
    };
}

- (BOOL)isSpeak {
    if (self.volume > 10) {
        _isSpeak = YES;
    } else {
        _isSpeak = NO;
    }
    return _isSpeak;
}


@end
