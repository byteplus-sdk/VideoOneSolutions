// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "JoinRTSParamsModel.h"

@implementation JoinRTSParamsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"appId": @"app_id",
        @"bid": @"bid"
    };
}

@end
