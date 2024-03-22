//
//  KTVMusicView.m
//  veRTC_Demo
//
//  Created by on 2021/11/30.
//  
//

#import "KTVMusicView.h"
#import "KTVMusicTuningView.h"
#import "KTVMusicTopView.h"
#import "KTVMusicBottomView.h"
#import "KTVMusicLyricView.h"
#import "KTVRTSManager.h"
#import "KTVRTCManager.h"

@interface KTVMusicView ()

@property (nonatomic, strong) KTVMusicTopView *topView;
@property (nonatomic, strong) KTVMusicLyricView *KTVMusicLyricView;
@property (nonatomic, strong) KTVMusicBottomView *bottomView;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) KTVMusicTuningView *tuningView;
@property (nonatomic, strong) UIButton *tuningMaskButton;

@end

@implementation KTVMusicView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubviewAndConstraints];
        
        __weak __typeof(self) wself = self;
        self.bottomView.clickButtonBlock = ^(MusicTopState state, BOOL isSelect) {
            [wself topViewClick:state isSelect:isSelect];
        };
    }
    return self;
}

#pragma mark - Publish Action

- (void)updateTopWithSongModel:(KTVSongModel *)songModel
                loginUserModel:(KTVUserModel *)loginUserModel {
    [self.topView updateWithSongModel:songModel
                       loginUserModel:loginUserModel];
    
    [self.bottomView updateWithSongModel:songModel
                          loginUserModel:loginUserModel];
}

- (void)resetTuningView:(BOOL)isStartMusic {
    [self.tuningView reset:isStartMusic];
}

- (void)loadLrcByPath:(KTVDownloadSongModel *)downloadSongModel  {
    KTVMusicLyricConfig *config = [[KTVMusicLyricConfig alloc] init];
    config.playingColor = [UIColor colorFromHexString:@"#FF4E75"];
    config.normalColor = [UIColor whiteColor];
    config.playingFont = [UIFont systemFontOfSize:18 weight:UIFontWeightHeavy];
    config.lrcFormat = KTVMusicLrcFormatLRC;
    [self.KTVMusicLyricView loadLrcByPath:downloadSongModel.lrcPath
                                   config:config
                                    error:nil];
}

- (void)resetLrc {
    [self.KTVMusicLyricView reset];
}

- (void)setTime:(NSTimeInterval)time {
    _time = time;
    
    // 更新 顶部UI
    self.topView.time = time / 1000;
    // 更新 歌词
    [self.KTVMusicLyricView playAtTime:time];
}

- (void)dismissTuningPanel {
    [self tuningMaskButtonAction];
}

/// 音频播放路由改变
- (void)updateAudioRouteChanged {
    [self.tuningView updateAudioRouteChanged];
}

#pragma mark - Private Action

- (void)tuningMaskButtonAction {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tuningMaskButton.hidden = YES;
        [self.tuningMaskButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tuningMaskButton.superview).offset(SCREEN_HEIGHT);
        }];
    });
}

- (void)topViewClick:(MusicTopState)state isSelect:(BOOL)isSelect {
    if (state == MusicTopStateOriginal) {
        [[KTVRTCManager shareRtc] switchAccompaniment:!isSelect];
        if (isSelect) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_original_vocals_enabled")];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_backing_track_enabled")];
        }
    } else if (state == MusicTopStateTuning) {
        [self tuningViewShow];
    } else if (state == MusicTopStatePause) {
        if (isSelect) {
            [[KTVRTCManager shareRtc] pauseSinging];
        } else {
            [[KTVRTCManager shareRtc] resumeSinging];
        }
    } else if (state == MusicTopStateNext) {
        if ([self.musicDelegate respondsToSelector:@selector(musicViewdelegate:topViewClickCut:)]) {
            [self.musicDelegate musicViewdelegate:self topViewClickCut:YES];
        }
    } else if (state == MusicTopStateSongList) {
        if ([self.musicDelegate respondsToSelector:@selector(musicViewdelegate:topViewClickSongList:)]) {
            [self.musicDelegate musicViewdelegate:self topViewClickSongList:YES];
        }
    } else {
        
    }
}

- (void)addSubviewAndConstraints {
    [self addSubview:self.topView];
    [self addSubview:self.KTVMusicLyricView];
    [self addSubview:self.bottomView];
    [self addSubview:self.bottomLineView];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(72);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@47.5);
        make.right.equalTo(@-47.5);
        make.bottom.equalTo(@-15);
        make.height.mas_equalTo(56);
    }];
    
    [self.KTVMusicLyricView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.right.equalTo(@-20);
        make.top.equalTo(self.topView.mas_bottom).offset(24);
        make.bottom.equalTo(self.bottomView.mas_top).offset(-20);
    }];
    
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.equalTo(@1);
    }];
    
    UIView *keyView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [keyView addSubview:self.tuningMaskButton];
    [self.tuningMaskButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.height.equalTo(keyView);
        make.top.equalTo(keyView).offset(SCREEN_HEIGHT);
    }];
    
    [self.tuningMaskButton addSubview:self.tuningView];
    [self.tuningView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.tuningMaskButton);
    }];
}

- (void)tuningViewShow {
    self.tuningMaskButton.hidden = NO;
    
    // Start animation
    [self.tuningMaskButton.superview layoutIfNeeded];
    [self.tuningMaskButton.superview setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.25
                     animations:^{
        [self.tuningMaskButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tuningMaskButton.superview).offset(0);
        }];
        [self.tuningMaskButton.superview layoutIfNeeded];
    }];
}

#pragma mark - Getter

- (KTVMusicTopView *)topView {
    if (!_topView) {
        _topView = [[KTVMusicTopView alloc] init];
    }
    return _topView;
}

- (KTVMusicLyricView *)KTVMusicLyricView {
    if (!_KTVMusicLyricView) {
        _KTVMusicLyricView = [[KTVMusicLyricView alloc] init];
    }
    return _KTVMusicLyricView;
}

- (KTVMusicBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[KTVMusicBottomView alloc] init];
    }
    return _bottomView;
}

- (KTVMusicTuningView *)tuningView {
    if (!_tuningView) {
        _tuningView = [[KTVMusicTuningView alloc] init];
    }
    return _tuningView;
}

- (UIButton *)tuningMaskButton {
    if (!_tuningMaskButton) {
        _tuningMaskButton = [[UIButton alloc] init];
        [_tuningMaskButton addTarget:self action:@selector(tuningMaskButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_tuningMaskButton setBackgroundColor:[UIColor clearColor]];
    }
    return _tuningMaskButton;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = [UIColor colorFromRGBHexString:@"#DDE2E9" andAlpha:0.15 * 255];
    }
    return _bottomLineView;
}

@end
