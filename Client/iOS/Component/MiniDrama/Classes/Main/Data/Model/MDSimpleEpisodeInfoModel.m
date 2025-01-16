//
//  MDSimpleEpisodeInfoModel.m
//  MiniDrama
//
//  Created by ByteDance on 2024/11/15.
//

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
