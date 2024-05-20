// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVMusicComponent.h"
#import "KTVMusicView.h"
#import "KTVMusicNullView.h"
#import "KTVMusicEndView.h"
#import "KTVDownloadMusicComponent.h"

typedef NS_ENUM(NSInteger, KTVMusicViewStatus) {
    KTVMusicViewStatusShowMusic     = 0,
    KTVMusicViewStatusShowNull      = 1,
    KTVMusicViewStatusShowResult    = 2,
};

@interface KTVMusicComponent () <KTVMusicViewdelegate>

@property (nonatomic, strong) KTVMusicNullView *musicNullView;
@property (nonatomic, strong) KTVMusicView *musicView;
@property (nonatomic, strong) KTVMusicEndView *musicEndView;

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, strong) KTVUserModel *loginUserModel;
@property (nonatomic, strong) KTVSongModel *songModel;
@property (nonatomic, strong) KTVSongModel *aboveSongModel;

@end

@implementation KTVMusicComponent

#pragma mark - Publish Action

- (instancetype)initWithSuperView:(UIView *)view
                           roomID:(NSString *)roomID {
    self = [super init];
    if (self) {
        _roomID = roomID;
        [view addSubview:self.musicView];
        [self.musicView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(view);
            make.top.mas_equalTo([DeviceInforTool getSafeAreaInsets].bottom + 88);
            make.height.mas_equalTo(248);
        }];
        
        [view addSubview:self.musicNullView];
        [self.musicNullView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(view);
            make.top.mas_equalTo([DeviceInforTool getSafeAreaInsets].bottom + 136);
            make.height.mas_equalTo(200);
        }];
        
        [view addSubview:self.musicEndView];
        [self.musicEndView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(view);
            make.top.mas_equalTo([DeviceInforTool getSafeAreaInsets].bottom + 136);
            make.height.mas_equalTo(200);
        }];
        
        __weak __typeof(self) wself = self;
        self.musicNullView.clickPlayMusicBlock = ^{
            if ([wself.delegate respondsToSelector:@selector(musicComponent:clickPlayMusic:)]) {
                [wself.delegate musicComponent:wself clickPlayMusic:YES];
            }
        };
        self.musicEndView.clickPlayMusicBlock = ^{
            if ([wself.delegate respondsToSelector:@selector(musicComponent:clickPlayMusic:)]) {
                [wself.delegate musicComponent:wself clickPlayMusic:YES];
            }
        };
    }
    return self;
}

- (void)showMusicViewWithStatus:(KTVMusicViewStatus)status {
    switch (status) {
        case KTVMusicViewStatusShowMusic: {
            self.musicEndView.hidden = YES;
            self.musicNullView.hidden = YES;
            self.musicView.hidden = NO;
        }
            break;
        case KTVMusicViewStatusShowNull: {
            self.musicEndView.hidden = YES;
            self.musicView.hidden = YES;
            self.musicNullView.hidden = NO;
        }
            break;
        case KTVMusicViewStatusShowResult: {
            self.musicEndView.hidden = NO;
            self.musicNullView.hidden = YES;
            self.musicView.hidden = YES;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Publish Action

- (void)startSingWithSongModel:(KTVSongModel * _Nullable)songModel {
    _songModel = songModel;
    if (songModel && NOEmptyStr(songModel.musicId)) {
        __weak __typeof(self) wself = self;
        [self showMusicViewWithStatus:KTVMusicViewStatusShowMusic];
        [self startWithSongModel:songModel
                  loginUserModel:self.loginUserModel];
    } else {
        [self showMusicViewWithStatus:KTVMusicViewStatusShowNull];
        if ([_aboveSongModel.pickedUserID isEqualToString:[LocalUserComponent userModel].uid]) {
            [[KTVRTCManager shareRtc] enableEarMonitor:NO];
            [[KTVRTCManager shareRtc] stopSinging];
        }
        [self.musicView resetTuningView:NO];
    }
    [self.musicView dismissTuningPanel];
    _aboveSongModel = songModel;
}

- (void)stopSong {
    if (IsEmptyStr(self.roomID) ||
        IsEmptyStr(self.songModel.musicId)) {
        return;
    }
    [KTVRTSManager finishSing:self.roomID
                              songID:self.songModel.musicId
                               score:75
                               block:^(KTVSongModel * _Nonnull songModel,
                                       RTSACKModel * _Nonnull model) {
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        }
    }];
    
    // Close ear return
    [[KTVRTCManager shareRtc] enableEarMonitor:NO];
    // Turn off the reverb effect
    [[KTVRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbOriginal];
    // Close the tuning panel
    [self.musicView dismissTuningPanel];
}

- (void)showSongEndSongModel:(KTVSongModel * _Nullable)nextSongModel
                curSongModel:(KTVSongModel * _Nullable)curSongModel
                       score:(NSInteger)score {
    // Display the singing result
    [self showMusicViewWithStatus:KTVMusicViewStatusShowResult];
    [[KTVRTCManager shareRtc] resetAudioMixingStatus];
    __weak __typeof(self) wself = self;
    [self.musicEndView showWithModel:nextSongModel
                               block:^(BOOL result) {
        // After the countdown is over, the anchor performs song cutting
        if (wself.loginUserModel.userRole == KTVUserRoleHost) {
            [wself loadDataWithCutOffSong:^(RTSACKModel *model) {
                if (!model.result) {
                    [[ToastComponent shareToastComponent] showWithMessage:model.message];
                }
            }];
        }
    }];
}

- (void)updateUserModel:(KTVUserModel *)loginUserModel {
    _loginUserModel = loginUserModel;
    
    self.musicNullView.loginUserModel = loginUserModel;
    [self.musicView updateTopWithSongModel:self.songModel
                            loginUserModel:loginUserModel];
}

- (void)updateCurrentSongTime:(NSDictionary *)infoDic {
    // The remote end receives the synchronization information
    if (infoDic && [infoDic isKindOfClass:[NSDictionary class]]) {
        self.musicView.time = [infoDic[@"progress"] doubleValue];
    }
}

- (void)dismissTuningPanel {
    [self.musicView dismissTuningPanel];
}

- (void)sendSongTime:(NSInteger)songTime {
    if ([self isSingerWithSongModel:self.songModel 
                     loginUserModel:self.loginUserModel]) {
        self.musicView.time = songTime;
        NSString *timeStr = [NSString stringWithFormat:@"%ld", (long)songTime];
        NSDictionary *syncInfoDic = [[NSMutableDictionary alloc] init];
        [syncInfoDic setValue:timeStr forKey:@"progress"];
        [syncInfoDic setValue:self.songModel.musicId ?: @"" forKey:@"music_id"];
        [[KTVRTCManager shareRtc] sendStreamSyncTime:[syncInfoDic copy]];
    }
}
- (void)updateAudioRouteChanged {
    [self.musicView updateAudioRouteChanged];
}

#pragma mark - KTVMusicViewdelegate

- (void)musicViewdelegate:(KTVMusicView *)musicViewdelegate topViewClickCut:(BOOL)isResult {
    [[ToastComponent shareToastComponent] showLoading];
    musicViewdelegate.userInteractionEnabled = NO;
    [self loadDataWithCutOffSong:^(RTSACKModel *model) {
        [[ToastComponent shareToastComponent] dismiss];
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        }
        musicViewdelegate.userInteractionEnabled = YES;
    }];
}

- (void)musicViewdelegate:(KTVMusicView *)musicViewdelegate topViewClickSongList:(BOOL)isOpen {
    if ([self.delegate respondsToSelector:@selector(musicComponent:clickOpenSongList:)]) {
        [self.delegate musicComponent:self clickOpenSongList:YES];
    }
}

#pragma mark - Network request Method

- (void)loadDataWithCutOffSong:(void(^)(RTSACKModel *model))complete {
    [KTVRTSManager cutOffSong:self.roomID
                        block:^(RTSACKModel * _Nonnull model) {
        if (complete) {
            complete(model);
        }
    }];
}

#pragma mark - Private Action

- (BOOL)isSingerWithSongModel:(KTVSongModel *)songModel
               loginUserModel:(KTVUserModel *)loginUserModel {
    BOOL isCompetence = (loginUserModel.status == KTVUserStatusActive || loginUserModel.userRole == KTVUserRoleHost);
    if (isCompetence &&
        [songModel.pickedUserID isEqualToString:loginUserModel.uid]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)startWithSongModel:(KTVSongModel *)songModel
            loginUserModel:(KTVUserModel *)loginUserModel {
    NSString *aboveSongID = [NSString stringWithFormat:@"%@_%@", _aboveSongModel.musicId, _aboveSongModel.pickedUserID];
    NSString *songID = [NSString stringWithFormat:@"%@_%@", songModel.musicId, songModel.pickedUserID];
    
    if ([aboveSongID isEqualToString:songID]) {
        // If it is the same song, the same singer discards the message
        return;
    } else {
        // When switching songs, a new song will be released, and the singer needs to pause the previous song first.
        if ([_aboveSongModel.pickedUserID isEqualToString:[LocalUserComponent userModel].uid]) {
            [[KTVRTCManager shareRtc] enableEarMonitor:NO];
            [[KTVRTCManager shareRtc] stopSinging];
        }
    }
    
    [self.musicView updateTopWithSongModel:songModel
                            loginUserModel:loginUserModel];
    // If the singer needs to download lyrics and songs at the same time
    KTVManagerType type = KTVManagerTypeLyric;
    if ([self isSingerWithSongModel:songModel
                     loginUserModel:loginUserModel]) {
        type = KTVManagerTypeLyric | KTVManagerTypeMusic;
    }
    
    __weak __typeof(self) wself = self;
    [wself.musicView resetLrc];
    [[KTVDownloadMusicComponent shared] downloadMusicModel:songModel
                                                      type:type
                                                  complete:^(KTVDownloadSongModel * _Nonnull downloadSongModel) {
        if (NOEmptyStr(downloadSongModel.lrcPath)) {
            // Initialize lyrics
            [wself.musicView loadLrcByPath:downloadSongModel];
            // Singer
            if ([wself isSingerWithSongModel:songModel
                              loginUserModel:loginUserModel]) {
                NSDictionary *syncInfoDic = [[NSMutableDictionary alloc] init];
                [syncInfoDic setValue:@"0" forKey:@"progress"];
                [syncInfoDic setValue:songModel.musicId ?: @"" forKey:@"music_id"];
                [[KTVRTCManager shareRtc] sendStreamSyncTime:[syncInfoDic copy]];
            }
        }
        
        // Music
        if ([wself isSingerWithSongModel:songModel
                          loginUserModel:loginUserModel]) {
            [[KTVRTCManager shareRtc] startStartSinging:downloadSongModel.musicPath];
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_start_singing")];
            [wself.musicView resetTuningView:YES];
        } else {
            [wself.musicView resetTuningView:NO];
        }
    }];
}


#pragma mark - Getter

- (KTVMusicNullView *)musicNullView {
    if (!_musicNullView) {
        _musicNullView = [[KTVMusicNullView alloc] init];
        _musicNullView.backgroundColor = [UIColor clearColor];
        _musicNullView.hidden = NO;
    }
    return _musicNullView;
}

- (KTVMusicView *)musicView {
    if (!_musicView) {
        _musicView = [[KTVMusicView alloc] init];
        _musicView.musicDelegate = self;
        [_musicView setBackgroundColor:[UIColor clearColor]];
        _musicView.hidden = YES;
    }
    return _musicView;
}

- (KTVMusicEndView *)musicEndView {
    if (!_musicEndView) {
        _musicEndView = [[KTVMusicEndView alloc] init];
        [_musicEndView setBackgroundColor:[UIColor clearColor]];
        _musicEndView.hidden = YES;
    }
    return _musicEndView;
}

@end
