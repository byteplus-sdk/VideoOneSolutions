// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
// 

#import <Foundation/Foundation.h>
#import "KTVSongModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, KTVManagerType) {
    KTVManagerTypeMusic   = 1 << 0,
    KTVManagerTypeLyric   = 1 << 1,
};

@interface KTVDownloadMusicComponent : NSObject

+ (instancetype)shared;

- (void)downloadMusicModel:(KTVSongModel *)songModel
                      type:(KTVManagerType)type
                  complete:(void(^)(KTVDownloadSongModel *downloadSongModel))complete;

- (void)removeLocalMusicFile;

- (void)updateOnlineMusicList:(NSArray <KTVSongModel *> *)musicList;

@end

NS_ASSUME_NONNULL_END
