// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "KTVDownloadComponent.h"
#import "KTVDownloadMusicComponent.h"

@interface KTVDownloadMusicComponent ()

@property (nonatomic, copy) NSArray <KTVSongModel *> *musicList;

@end

@implementation KTVDownloadMusicComponent

+ (instancetype)shared {
    static KTVDownloadMusicComponent *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KTVDownloadMusicComponent alloc] init];
    });
    return manager;
}

- (void)downloadMusicModel:(KTVSongModel *)songModel
                      type:(KTVManagerType)type
                  complete:(void(^)(KTVDownloadSongModel *downloadSongModel))complete {
    if (!songModel) {
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(nil);
            }
        });
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    __block KTVDownloadSongModel *downloadModel = [[KTVDownloadSongModel alloc] init];
    downloadModel.songModel = songModel;
    
    if (type & KTVManagerTypeMusic) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self downloadMusic:downloadModel complete:^(NSString *filePath) {
                downloadModel.musicPath = filePath;
                dispatch_group_leave(group);
            }];
        });
    }
    if (type & KTVManagerTypeLyric) {
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
    NSString *baseFilePath = [KTVDownloadComponent basePathString];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator * enumerator = [fileManager enumeratorAtPath:baseFilePath];
    for (NSString *fileName in enumerator) {
        [fileManager removeItemAtPath:[baseFilePath stringByAppendingPathComponent:fileName] error:nil];
    }
}

- (void)updateOnlineMusicList:(NSArray <KTVSongModel *> *)musicList {
    self.musicList = musicList;
}

#pragma mark - Private Action

- (void)downloadLRC:(KTVDownloadSongModel *)downloadModel
           complete:(void(^)(NSString *filePath))complete {
    NSString *filePath = [KTVDownloadComponent getLRCFilePath:downloadModel.songModel.musicId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        !complete? :complete(filePath);
        return;
    }
    
    NSString *musicLrcUrl = downloadModel.songModel.musicLrcUrl;
    if (IsEmptyStr(musicLrcUrl)) {
        musicLrcUrl = [self getLrcURLWithMusicId:downloadModel.songModel.musicId];
    }
    [KTVDownloadComponent downloadWithURL:musicLrcUrl
                                 filePath:filePath
                                 progress:^(NSProgress * _Nonnull downloadProgress) {

    } complete:^(NSError * _Nonnull error) {
        if (complete) {
            complete(!error ? filePath : @"");
        }
    }];
}

- (void)downloadMusic:(KTVDownloadSongModel *)downloadModel
             complete:(void(^)(NSString *filePath))complete {
    NSString *filePath = [KTVDownloadComponent getMP3FilePath:downloadModel.songModel.musicId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        !complete? :complete(filePath);
        return;
    }
    
    NSString *musicFileUrl = downloadModel.songModel.musicFileUrl;
    if (IsEmptyStr(musicFileUrl)) {
        musicFileUrl = [self getMusicURLWithMusicId:downloadModel.songModel.musicId];
    }
    [KTVDownloadComponent downloadWithURL:musicFileUrl
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
    for (KTVSongModel *model in self.musicList) {
        if ([model.musicId isEqualToString:musicId]) {
            lrcURL = model.musicLrcUrl;
            break;
        }
    }
    return lrcURL;
}

- (NSString *)getMusicURLWithMusicId:(NSString *)musicId {
    NSString *musicURL = @"";
    for (KTVSongModel *model in self.musicList) {
        if ([model.musicId isEqualToString:musicId]) {
            musicURL = model.musicFileUrl;
            break;
        }
    }
    return musicURL;
}

@end
