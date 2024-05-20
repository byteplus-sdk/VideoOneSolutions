// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVSongModel.h"

@implementation KTVSongModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"singerUserName" : @"artist",
        @"coverURL" : @"cover_url",
        @"musicAllTime" : @"song_duration",
        @"musicId" : @"song_id",
        @"musicName" : @"song_name",
        @"pickedUserID" : @"owner_user_id",
        @"pickedUserName" : @"owner_user_name",
        @"singStatus" : @"status",
        @"musicFileUrl" : @"song_file_url",
        @"musicLrcUrl" : @"song_lrc_url",
    };
}

@end
