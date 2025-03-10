// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDSimpleEpisodeInfoModel.h"

@implementation MDSimpleEpisodeInfoModel

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
        @"videoId": @"vid",
        @"order": @"order",
        @"playAuthToken": @"play_auth_token",
        @"subtitleToken": @"subtitle_auth_token",
    };
}

@end
