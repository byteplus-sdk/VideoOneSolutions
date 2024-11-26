// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "BaseVideoModel.h"
#import "NSString+VE.h"
#import "VEVideoPlayerController+Resolution.h"
#import <ToolKit/Localizator.h>
#import <ToolKit/NSString+Valid.h>

@implementation BaseVideoModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"videoId": @"vid",
        @"title": @"caption",
        @"subTitle": @"subtitle",
        @"createTime": @"createTime",
        @"coverUrl": @"coverUrl",
        @"playTimes": @"playTimes",
        @"playAuthToken": @"playAuthToken",
        @"subtitleAuthToken": @"subtitleAuthToken",
        @"duration": @"duration",
        @"userName": @"name",
        @"likeCount": @"like",
        @"commentCount": @"comment",
        @"playUrl": @"httpUrl"
    };
}
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *createTime = dic[@"createTime"];
    if (createTime) {
        _createTime = [NSString timeStringForUTCTime:createTime];
    }
    return YES;
}

- (NSString *)playTimeToString {
    return [NSString stringWithFormat:@"%@ %@", [NSString stringForCount:_playTimes], LocalizedStringFromBundle(@"views", @"VodPlayer")];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

+ (TTVideoEngineVidSource *)videoEngineVidSource:(BaseVideoModel *)videoModel {
    TTVideoEngineVidSource *source = [[TTVideoEngineVidSource alloc] initWithVid:videoModel.videoId playAuthToken:videoModel.playAuthToken resolution:TTVideoEngineResolutionTypeHD];
    source.title = videoModel.title;
    source.cover = videoModel.coverUrl;
    return source;
}

+ (TTVideoEngineUrlSource *)videoEngineUrlSource:(BaseVideoModel *)videoModel {
    TTVideoEngineUrlSource *source = [[TTVideoEngineUrlSource alloc] initWithUrl:videoModel.playUrl cacheKey:videoModel.playUrl.vloc_md5String videoId:videoModel.videoId];
    source.title = videoModel.title;
    source.cover = videoModel.coverUrl;
    return source;
}

@end
