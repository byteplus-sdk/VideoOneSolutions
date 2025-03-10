// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaBaseVideoModel.h"
#import "MDVideoPlayerController+Resolution.h"

@implementation MiniDramaBaseVideoModel

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
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
        @"playTimes": @"play_times",
    };
}


+ (id)videoEngineVidSource:(MiniDramaBaseVideoModel *)videoModel {
    TTVideoEngineVidSource *source = [[TTVideoEngineVidSource alloc] initWithVid:videoModel.videoId playAuthToken:videoModel.playAuthToken resolution:[MDVideoPlayerController getPlayerCurrentResolution]];
    source.title = videoModel.videoTitle;
    source.cover = videoModel.coverUrl;
    return source;
}



@end
