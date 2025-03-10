// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDDramaInfoModel.h"

@implementation MDDramaInfoModel
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
        @"dramaId": @"drama_id",
        @"dramaTitle": @"drama_title",
        @"dramaPlayTimes": @"drama_play_times",
        @"dramaCoverUrl": @"drama_cover_url",
        @"dramaLength": @"drama_length",
        @"newReleased": @"new_release",
        @"dramaDisplayType": @"drama_video_orientation",
    };
}
@end
