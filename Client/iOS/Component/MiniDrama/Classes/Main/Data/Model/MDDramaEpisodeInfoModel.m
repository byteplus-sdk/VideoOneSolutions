// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDDramaEpisodeInfoModel.h"
#import "MDVideoPlayerController+Resolution.h"

@implementation MDDramaEpisodeInfoModel

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
        @"dramaTitle": @"drama_title",
        @"order": @"order",
        @"vip": @"vip",
        @"playTimes": @"play_times",
        @"videoId": @"vid",
        @"playAuthToken": @"play_auth_token",
        @"videoTitle": @"caption",
        @"videoDescription": @"subtitle",
        @"createTime": @"create_time",
        @"coverUrl": @"cover_url",
        @"duration": @"duration",
        @"videoWidth": @"width",
        @"videoHeight": @"height",
        @"authorName": @"name",
        @"authorId": @"uid",
        @"likeCount": @"like",
        @"commentCount": @"comment",
        @"dramaId": @"drama_id",
        @"displayType":@"display_type",
        @"subtitleToken": @"subtitle_auth_token",
    };
}

+ (TTVideoEngineVidSource *)videoEngineVidSource:(MDDramaEpisodeInfoModel *)videoModel {
    TTVideoEngineVidSource *source = [[TTVideoEngineVidSource alloc] initWithVid:videoModel.videoId playAuthToken:videoModel.playAuthToken resolution:[MDVideoPlayerController getPlayerCurrentResolution]];
    source.title = videoModel.videoTitle;
    source.cover = videoModel.coverUrl;
    source.startTime = videoModel.startTime;
    return source;
}
@end
