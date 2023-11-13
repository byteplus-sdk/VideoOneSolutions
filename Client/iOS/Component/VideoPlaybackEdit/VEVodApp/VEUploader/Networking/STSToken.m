//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "STSToken.h"

@implementation STSToken

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"accessKey": @"AccessKeyID",
        @"secretAccessKey": @"SecretAccessKey",
        @"sessionToken": @"SessionToken",
        @"expiredTime": @"ExpiredTime",
        @"currentTime": @"CurrentTime",
        @"spaceName": @"SpaceName",
    };
}

@end
