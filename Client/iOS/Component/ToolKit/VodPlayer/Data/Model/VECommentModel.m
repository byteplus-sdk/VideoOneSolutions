//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VECommentModel.h"
#import <ToolKit/NSString+Valid.h>

@implementation VECommentModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"likeCount": @"like",
    };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *createTime = dic[@"createTime"];
    if (createTime) {
        _createTime = [NSString timeStringForUTCTime:createTime];
    }
    return YES;
}

@end
