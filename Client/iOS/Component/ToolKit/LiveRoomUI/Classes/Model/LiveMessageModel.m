// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveMessageModel.h"

@implementation LiveMessageModel


+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"type": @"type",
        @"content": @"content",
        @"giftType": @"giftType",
        @"count": @"count",
        @"userId": @"user_id",
        @"userName": @"user_name",
    };
}

@end
