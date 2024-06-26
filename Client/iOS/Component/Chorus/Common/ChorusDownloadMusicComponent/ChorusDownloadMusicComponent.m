// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ChorusDownloadComponent.h"
#import "ChorusDownloadMusicComponent.h"

@interface ChorusDownloadMusicComponent ()

@property (nonatomic, copy) NSArray <ChorusSongModel *> *musicList;

@end

@implementation ChorusDownloadMusicComponent

+ (instancetype)shared {
    static ChorusDownloadMusicComponent *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ChorusDownloadMusicComponent alloc] init];
    });
    return manager;
}

- (void)downloadMusicModel:(ChorusSongModel *)songModel
                      type:(ChorusManagerType)type
                  complete:(void(^)(ChorusDownloadSongModel *downloadSongModel))complete {
    if (!songModel) {
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(nil);
            }
        });
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    __block ChorusDownloadSongModel *downloadModel = [[ChorusDownloadSongModel alloc] init];
    downloadModel.songModel = songModel;
    
    if (type & ChorusManagerTypeMusic) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self downloadMusic:downloadModel complete:^(NSString *filePath) {
                downloadModel.musicPath = filePath;
                dispatch_group_leave(group);
            }];
        });
    }
    if (type & ChorusManagerTypeLyric) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self downloadLRC:downloadModel complete:^(NSString *filePath) {
                downloadModel.lrcPath = filePath;
                dispatch_group_leave(group);
            }];
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (complete) {
            complete(downloadModel);
        }
    });
}

- (void)removeLocalMusicFile {
    NSString *baseFilePath = [ChorusDownloadComponent basePathString];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator * enumerator = [fileManager enumeratorAtPath:baseFilePath];
    for (NSString *fileName in enumerator) {
        [fileManager removeItemAtPath:[baseFilePath stringByAppendingPathComponent:fileName] error:nil];
    }
}

- (void)updateOnlineMusicList:(NSArray <ChorusSongModel *> *)musicList {
    self.musicList = musicList;
}

#pragma mark - Private Action

- (void)downloadLRC:(ChorusDownloadSongModel *)downloadModel
           complete:(void(^)(NSString *filePath))complete {
    NSString *filePath = [ChorusDownloadComponent getLRCFilePath:downloadModel.songModel.musicId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        !complete? :complete(filePath);
        return;
    }
    
    NSString *musicLrcUrl = downloadModel.songModel.musicLrcUrl;
    if (IsEmptyStr(musicLrcUrl)) {
        musicLrcUrl = [self getLrcURLWithMusicId:downloadModel.songModel.musicId];
    }
    [ChorusDownloadComponent downloadWithURL:musicLrcUrl
                                 filePath:filePath
                                 progress:^(NSProgress * _Nonnull downloadProgress) {

    } complete:^(NSError * _Nonnull error) {
        if (complete) {
            complete(!error ? filePath : @"");
        }
    }];
}

- (void)downloadMusic:(ChorusDownloadSongModel *)downloadModel
             complete:(void(^)(NSString *filePath))complete {
    NSString *filePath = [ChorusDownloadComponent getMP3FilePath:downloadModel.songModel.musicId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        !complete? :complete(filePath);
        return;
    }
    
    NSString *musicFileUrl = downloadModel.songModel.musicFileUrl;
    if (IsEmptyStr(musicFileUrl)) {
        musicFileUrl = [self getMusicURLWithMusicId:downloadModel.songModel.musicId];
    }
    [ChorusDownloadComponent downloadWithURL:musicFileUrl
                                 filePath:filePath
                                 progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } complete:^(NSError * _Nonnull error) {
        if (complete) {
            complete(!error ? filePath : @"");
        }
    }];
}

- (NSString *)getLrcURLWithMusicId:(NSString *)musicId {
    NSString *lrcURL = @"";
    for (ChorusSongModel *model in self.musicList) {
        if ([model.musicId isEqualToString:musicId]) {
            lrcURL = model.musicLrcUrl;
            break;
        }
    }
    return lrcURL;
}

- (NSString *)getMusicURLWithMusicId:(NSString *)musicId {
    NSString *musicURL = @"";
    for (ChorusSongModel *model in self.musicList) {
        if ([model.musicId isEqualToString:musicId]) {
            musicURL = model.musicFileUrl;
            break;
        }
    }
    return musicURL;
}

@end
