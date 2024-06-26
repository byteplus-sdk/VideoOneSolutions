// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "ChorusSongModel.h"
#import "ChorusDownloadSongModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, ChorusManagerType) {
    ChorusManagerTypeMusic   = 1 << 0,
    ChorusManagerTypeLyric   = 1 << 1,
};

@interface ChorusDownloadMusicComponent : NSObject

+ (instancetype)shared;

- (void)downloadMusicModel:(ChorusSongModel *)songModel
                      type:(ChorusManagerType)type
                  complete:(void(^)(ChorusDownloadSongModel *downloadSongModel))complete;

- (void)removeLocalMusicFile;

- (void)updateOnlineMusicList:(NSArray <ChorusSongModel *> *)musicList;

@end

NS_ASSUME_NONNULL_END
