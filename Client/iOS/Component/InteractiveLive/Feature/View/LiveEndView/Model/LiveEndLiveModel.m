// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveEndLiveModel.h"

@implementation LiveEndLiveModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"likes": @"likes",
        @"gifts": @"gifts",
        @"viewers": @"viewers",
        @"duration": @"duration",
    };
}

@end
