// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoModel.h"
#import "NSString+VE.h"
#import "VESettingManager.h"
#import "VEVideoPlayerController+Resolution.h"
#import <ToolKit/Localizator.h>
#import <ToolKit/NSString+Valid.h>

@implementation VEVideoModel

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
        @"playUrl": @"httpUrl",
        @"playType": @"type"
    };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *createTime = dic[@"createTime"];
    if (createTime) {
        self.createTime = [NSString timeStringForUTCTime:createTime];
    }
    return YES;
}

- (NSString *)playTimeToString {
    return [NSString stringWithFormat:@"%@ %@", [NSString stringForCount:self.playTimes], LocalizedStringFromBundle(@"views", @"VodPlayer")];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

+ (TTVideoEngineVidSource *)videoEngineVidSource:(BaseVideoModel *)videoModel {
    VESettingModel *h265 = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalH265];
    TTVideoEngineEncodeType codec = h265.open ? TTVideoEngineh265 : TTVideoEngineH264;
    TTVideoEngineVidSource *source = [[TTVideoEngineVidSource alloc] initWithVid:videoModel.videoId playAuthToken:videoModel.playAuthToken resolution:[VEVideoPlayerController getPlayerCurrentResolution] encodeType:codec isDash:NO isHLS:NO];
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
