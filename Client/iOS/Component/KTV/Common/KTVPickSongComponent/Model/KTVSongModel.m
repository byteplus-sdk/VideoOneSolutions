//
//  KTVSongModel.m
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
//

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
