//
//  TTVideoModel.m
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/5.
//

#import "TTVideoModel.h"
#import "TTVideoEngineSourceCategory.h"

@implementation TTVideoModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"videoId": @"vid",
        @"title": @"caption",
        @"duration": @"duration",
        @"playTimes": @"play_times",
        @"playAuthToken": @"play_auth_token",
        @"subtitleAuthToken": @"subtitle_auth_token",
        @"coverUrl": @"cover_url",
        @"subTitle": @"subtitle",
        @"createTime": @"create_time",
        @"userName": @"name",
        @"likeCount": @"like",
        @"commentCount": @"comment",
    };
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end