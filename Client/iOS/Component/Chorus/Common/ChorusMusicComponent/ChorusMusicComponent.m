// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "ChorusMusicComponent.h"
#import "ChorusMusicNullView.h"
#import "ChorusMusicEndView.h"
#import "ChorusMusicControlView.h"
#import "ChorusMusicTuningView.h"
#import "ChorusSingerComponent.h"
#import "ChorusWaitingSingerJoinView.h"
#import "ChorusMusicLyricView.h"
#import "ChorusDataManager.h"
#import "ChorusDownloadComponent.h"
#import "ChorusDownloadMusicComponent.h"
#import "ChorusMusicBottomView.h"

@interface ChorusMusicComponent ()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) ChorusMusicNullView *musicNullView;
@property (nonatomic, strong) ChorusMusicEndView *musicEndView;
@property (nonatomic, strong) ChorusMusicBottomView *musicBottomView;
@property (nonatomic, strong) ChorusMusicControlView *musicControlView;
@property (nonatomic, strong) ChorusMusicTuningView *tuningView;
@property (nonatomic, strong) UIButton *maskButton;
@property (nonatomic, strong) ChorusSingerComponent *singerComponent;
@property (nonatomic, strong) ChorusWaitingSingerJoinView *waitingJoinView;
@property (nonatomic, strong) ChorusMusicLyricView *lrcView;
@property (nonatomic, assign) BOOL downloadCompleteNeedPlay;

@end

@implementation ChorusMusicComponent

#pragma mark - Publish Action

- (instancetype)initWithSuperView:(UIView *)view {
    self = [super init];
    if (self) {
        [self setupViewsWithSuperView:view];
        [self updateWithChorusStatus:ChorusStatusIdle];
    }
    return self;
}

#pragma mark - Publish Action

- (void)updateWithChorusStatus:(ChorusStatus)status {
    [self updateUIWithChorusStatus:status];
    [self.singerComponent updateSingerUIWithChorusStatus:status];
    [[ChorusRTCManager shareRtc] updateAudioSubscribeWithChorusStatus:status];
    [[ChorusRTCManager shareRtc] updateSuccentorAudioMixingWithChorusState:status];
}
- (void)prepareStartSingSong:(ChorusSongModel *_Nullable)songModel
         leadSingerUserModel:(ChorusUserModel *_Nullable)leadSingerUserModel {
    [self.tuningView reset:NO];
    if (!songModel) {
        [self updateWithChorusStatus:ChorusStatusIdle];
        return;
    }
    [self updateWithChorusStatus:ChorusStatusPrepare];
    [self prepareMaterialsWithSongModel:songModel];
}

- (void)reallyStartSingSong:(ChorusSongModel *)songModel {
    
    if (!songModel) {
        return;
    }
    
    [self updateWithChorusStatus:ChorusStatusSinging];
    [self.musicControlView updateUI];
    [self.musicBottomView update];

    if ([ChorusDataManager shared].isLeadSinger) {
        self.downloadCompleteNeedPlay = NO;
        NSString *filePath = [ChorusDownloadComponent getMP3FilePath:songModel.musicId];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[ChorusRTCManager shareRtc] startAudioMixingWithFilePath:filePath];
            [self.tuningView reset:YES];
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_start_singing")];
        } else {
            self.downloadCompleteNeedPlay = YES;
        }
    }
    
    if ([ChorusDataManager shared].isSuccentor) {
        [self.tuningView reset:YES];
    }
}
- (void)prepareMaterialsWithSongModel:(ChorusSongModel *)songModel {
    self.downloadCompleteNeedPlay = NO;
    
    ChorusManagerType type = ChorusManagerTypeLyric;
    if ([ChorusDataManager shared].isLeadSinger) {
        type = ChorusManagerTypeLyric | ChorusManagerTypeMusic;
    }
    
    __weak typeof(self) weakSelf = self;
    [[ChorusDownloadMusicComponent shared] downloadMusicModel:songModel type:type complete:^(ChorusDownloadSongModel * _Nonnull downloadSongModel) {
        // LRC
        if (NOEmptyStr(downloadSongModel.lrcPath)) {
            ChorusMusicLyricConfig *config = [[ChorusMusicLyricConfig alloc] init];
            config.playingColor = [UIColor colorFromHexString:@"#FF4E75"];
            config.normalColor = [UIColor whiteColor];
            config.playingFont = [UIFont systemFontOfSize:18 weight:UIFontWeightHeavy];
            config.lrcFormat = ChorusMusicLrcFormatLRC;
            
            [weakSelf.lrcView loadLrcByPath:downloadSongModel.lrcPath
                                     config:config
                                      error:nil];
            [weakSelf.lrcView playAtTime:0];
            // Singer
            if ([ChorusDataManager shared].isLeadSinger) {
                [[ChorusRTCManager shareRtc] sendStreamSyncTime:@"0"];
            }
        }
        
        // Music
        if ([ChorusDataManager shared].isLeadSinger) {
            if (weakSelf.downloadCompleteNeedPlay) {
                [[ChorusRTCManager shareRtc] startAudioMixingWithFilePath:downloadSongModel.musicPath];
                [weakSelf.tuningView reset:YES];
                [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_start_singing")];
            }
        }
        
    }];
}

- (void)stopSong {
    if (IsEmptyStr([ChorusDataManager shared].roomModel.roomID) ||
        IsEmptyStr([ChorusDataManager shared].currentSongModel.musicId)) {
        return;
    }
    [ChorusRTSManager finishSing:[ChorusDataManager shared].roomModel.roomID
                          songID:[ChorusDataManager shared].currentSongModel.musicId
                           score:75
                           block:^(ChorusSongModel * _Nonnull songModel,
                                       RTSACKModel * _Nonnull model) {
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        }
    }];
    
    // Close ear return
    [[ChorusRTCManager shareRtc] enableEarMonitor:NO];
    // Turn off the reverb effect
    [[ChorusRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbOriginal];
    // Close the tuning panel
    [self maskButtonAction];
}

- (void)showSongEndWithNextSongModel:(ChorusSongModel *)nextSongModel {
    if (nextSongModel) {
        [self updateWithChorusStatus:ChorusStatusSingEnd];
        [self.musicEndView showEndViewWithNextSongModel:nextSongModel];
        if ([ChorusDataManager shared].isLeadSinger) {
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf cutOffSongWithHost];
            });
        }
    } else {
        [self updateWithChorusStatus:ChorusStatusIdle];
        [self cutOffSongWithHost];
    }
}

- (void)cutOffSongWithHost {
    [self loadDataWithCutOffSong:^(RTSACKModel *model) {
        
    }];
}

- (void)updateCurrentSongTime:(NSString *)json {
    NSDictionary *dic = [NetworkingTool decodeJsonMessage:json];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        NSInteger progress = [dic[@"progress"] integerValue];
        NSString *musicId = dic[@"music_id"];
        if ([musicId isEqualToString:[ChorusDataManager shared].currentSongModel.musicId]) {
            [self.lrcView playAtTime:progress];
            
            NSTimeInterval second = (NSTimeInterval)progress / 1000;
            self.musicControlView.time = second;
        }
    }
}

- (void)dismissTuningPanel {
    [self maskButtonAction];
}

- (void)sendSongTime:(NSInteger)songTime {
    ChorusSongModel *songModel = [ChorusDataManager shared].currentSongModel;
    if ([ChorusDataManager shared].isLeadSinger &&
        songModel && NOEmptyStr(songModel.musicId)) {
        NSDictionary *dic = @{@"progress" : @(songTime),
                              @"music_id" : songModel.musicId};
        NSString *json = [dic yy_modelToJSONString];
        [[ChorusRTCManager shareRtc] sendStreamSyncTime:json];
        [self updateCurrentSongTime:json];
    }
}

- (void)updateNetworkQuality:(ChorusNetworkQualityStatus)status uid:(NSString *)uid {
    [self.singerComponent updateNetworkQuality:status uid:uid];
}

- (void)updateFirstVideoFrameRenderedWithUid:(NSString *)uid {
    [self.singerComponent updateFirstVideoFrameRenderedWithUid:uid];
}
- (void)updateUserAudioVolume:(NSDictionary<NSString *, NSNumber *> *)dict {
    [self.singerComponent updateUserAudioVolume:dict];
}
- (void)updateAudioRouteChanged {
    [self.tuningView updateAudioRouteChanged];
}

#pragma mark - Private Action

- (void)startSingWithActionType:(ChorusSingingType)actionType {
    [[ToastComponent shareToastComponent] showLoading];
    [ChorusRTSManager startSingWithRoomID:[ChorusDataManager shared].roomModel.roomID
                                   songID:[ChorusDataManager shared].currentSongModel.musicId
                                     type:actionType
                                    block:^(RTSACKModel * _Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        }
    }];
}

- (void)setupViewsWithSuperView:(UIView *)superView {
    [superView addSubview:self.backgroundView];
    [superView addSubview:self.musicControlView];
    
    [self singerComponent];
    
    [self.backgroundView addSubview:self.musicNullView];
    [self.backgroundView addSubview:self.musicEndView];
    
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(superView);
        make.top.mas_equalTo([DeviceInforTool getSafeAreaInsets].bottom + 68);
        make.height.mas_equalTo(300);
    }];
    [self.musicNullView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.backgroundView);
        make.top.equalTo(@100);
    }];
    [self.musicEndView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.musicNullView);
    }];
    [self.musicControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.backgroundView);
        make.top.equalTo(self.backgroundView.mas_bottom).offset(-14);
        make.height.mas_equalTo(72);
    }];
    
    [superView addSubview:self.waitingJoinView];
    [self.waitingJoinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.backgroundView);
        make.bottom.equalTo(self.backgroundView).offset(-60);
    }];
    [self.backgroundView addSubview:self.lrcView];
    [self.lrcView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.backgroundView);
        make.height.mas_equalTo(65);
        make.bottom.equalTo(self.backgroundView).offset(-84);
    }];
    
    [self.backgroundView addSubview:self.musicBottomView];
    [self.musicBottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(56 * 4));
        make.centerX.equalTo(self.lrcView);
        make.height.mas_equalTo(56);
        make.top.equalTo(self.lrcView.mas_bottom).offset(12);
    }];
    
    UIView *keyView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [keyView addSubview:self.maskButton];
    [self.maskButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.height.equalTo(keyView);
        make.top.equalTo(keyView).offset(SCREEN_HEIGHT);
    }];
    [self.maskButton addSubview:self.tuningView];
    [self.tuningView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.maskButton);
    }];
}
- (void)updateUIWithChorusStatus:(ChorusStatus)status {
    
    self.musicNullView.hidden = YES;
    self.musicEndView.hidden = YES;
    self.musicControlView.hidden = YES;
    self.singerComponent.backgroundView.hidden = YES;
    self.waitingJoinView.hidden = YES;
    self.lrcView.hidden = YES;
    self.musicBottomView.hidden = YES;
    
    switch (status) {
        case ChorusStatusIdle: {
            self.musicNullView.hidden = NO;
        }
            break;
        case ChorusStatusPrepare: {
            self.singerComponent.backgroundView.hidden = NO;
            self.waitingJoinView.hidden = NO;
            [self.waitingJoinView updateUI];
        }
            break;
        case ChorusStatusSinging: {
            self.musicControlView.hidden = NO;
            self.singerComponent.backgroundView.hidden = NO;
            self.lrcView.hidden = NO;
            self.musicBottomView.hidden = NO;
        }
            break;
        
        case ChorusStatusSingEnd: {
            self.singerComponent.backgroundView.hidden = NO;
            self.musicEndView.hidden = NO;
        }
            break;
        default:
            break;
    }
}

#pragma mark - musicControl

- (void)musicControlViewClick:(MusicTopState)state
                     isSelect:(BOOL)isSelect
                       button:(BaseButton *)button {
    if (state == MusicTopStateOriginal) {
        [[ChorusRTCManager shareRtc] switchAccompaniment:!isSelect];
        if (isSelect) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_start_original")];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_start_accompaniment")];
        }
    } else if (state == MusicTopStateTuning) {
        [self tuningViewShow];
    } else if (state == MusicTopStateNext) {
        [[ToastComponent shareToastComponent] showLoading];
        button.userInteractionEnabled = NO;
        [self loadDataWithCutOffSong:^(RTSACKModel * _Nonnull model) {
            [[ToastComponent shareToastComponent] dismiss];
            button.userInteractionEnabled = YES;
            if (!model.result) {
                [[ToastComponent shareToastComponent] showWithMessage:model.message];
            }
        }];
    } else if (state == MusicTopStateSongList) {
        if ([self.delegate respondsToSelector:@selector(musicComponent:clickOpenSongList:)]) {
            [self.delegate musicComponent:self clickOpenSongList:YES];
        }
    } else {
        
    }
}

- (void)tuningViewShow {
    self.maskButton.hidden = NO;
    [self.maskButton.superview layoutIfNeeded];
    [self.maskButton.superview setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.25
                     animations:^{
        [self.maskButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.maskButton.superview).offset(0);
        }];
        [self.maskButton.superview layoutIfNeeded];
    }];
}

- (void)maskButtonAction {
    self.maskButton.hidden = YES;
    [self.maskButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.maskButton.superview).offset(SCREEN_HEIGHT);
    }];
}

- (void)loadDataWithCutOffSong:(void(^)(RTSACKModel *model))complete {
    [ChorusRTSManager cutOffSong:[ChorusDataManager shared].roomModel.roomID
                               block:^(RTSACKModel * _Nonnull model) {
        if (complete) {
            complete(model);
        }
    }];
}

#pragma mark - Getter

- (ChorusMusicBottomView *)musicBottomView {
    if (!_musicBottomView) {
        _musicBottomView = [[ChorusMusicBottomView alloc] init];
        _musicBottomView.hidden = YES;
        __weak typeof(self) weakSelf = self;
        _musicBottomView.clickButtonBlock = ^(MusicTopState state, BOOL isSelect, BaseButton * _Nonnull button) {
            [weakSelf musicControlViewClick:state
                                   isSelect:isSelect
                                     button:button];
        };
    }
    return _musicBottomView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor clearColor];
    }
    return _backgroundView;
}

- (ChorusMusicNullView *)musicNullView {
    if (!_musicNullView) {
        _musicNullView = [[ChorusMusicNullView alloc] init];
        _musicNullView.backgroundColor = [UIColor clearColor];
        _musicNullView.hidden = NO;
    }
    return _musicNullView;
}

- (ChorusMusicEndView *)musicEndView {
    if (!_musicEndView) {
        _musicEndView = [[ChorusMusicEndView alloc] init];
        [_musicEndView setBackgroundColor:[UIColor clearColor]];
        _musicEndView.hidden = YES;
    }
    return _musicEndView;
}

- (ChorusMusicControlView *)musicControlView {
    if (!_musicControlView) {
        _musicControlView = [[ChorusMusicControlView alloc] init];
        _musicControlView.hidden = YES;
    }
    return _musicControlView;
}

- (ChorusMusicTuningView *)tuningView {
    if (!_tuningView) {
        _tuningView = [[ChorusMusicTuningView alloc] init];
    }
    return _tuningView;
}

- (UIButton *)maskButton {
    if (!_maskButton) {
        _maskButton = [[UIButton alloc] init];
        [_maskButton addTarget:self action:@selector(maskButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_maskButton setBackgroundColor:[UIColor clearColor]];
    }
    return _maskButton;
}

- (ChorusSingerComponent *)singerComponent {
    if (!_singerComponent) {
        _singerComponent = [[ChorusSingerComponent alloc] initWithSuperView:self.backgroundView];
    }
    return _singerComponent;
}

- (ChorusWaitingSingerJoinView *)waitingJoinView {
    if (!_waitingJoinView) {
        _waitingJoinView = [[ChorusWaitingSingerJoinView alloc] init];
        __weak typeof(self) weakSelf = self;
        _waitingJoinView.startSingingTypeBlock = ^(ChorusSingingType actionType) {
            [weakSelf startSingWithActionType:actionType];
        };
    }
    return _waitingJoinView;
}

- (ChorusMusicLyricView *)lrcView {
    if (!_lrcView) {
        _lrcView = [[ChorusMusicLyricView alloc] init];
    }
    return _lrcView;
}

@end
