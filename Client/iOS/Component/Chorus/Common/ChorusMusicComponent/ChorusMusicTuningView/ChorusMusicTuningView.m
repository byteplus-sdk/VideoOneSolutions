// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ChorusMusicTuningView.h"
#import "ChorusMusicReverberationView.h"
#import "ChorusRTCManager.h"
#import "ChorusDataManager.h"

static CGFloat DefaultEarVolume = 100;
static CGFloat DefaultMusicLeadSingerVolume = 10;
static CGFloat DefaultMusicVolume = 100;
static CGFloat DefaultVocalVolume = 100;

@interface ChorusMusicTuningView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UILabel *earLabel;
@property (nonatomic, strong) UILabel *earTipLabel;
@property (nonatomic, strong) UILabel *earRightLabel;
@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, strong) UISlider *earSlider;

@property (nonatomic, strong) UILabel *musicLeftLabel;
@property (nonatomic, strong) UILabel *musicRightLabel;
@property (nonatomic, strong) UISlider *musicSlider;

@property (nonatomic, strong) UILabel *vocalLeftLabel;
@property (nonatomic, strong) UILabel *vocalRightLabel;
@property (nonatomic, strong) UISlider *vocalSlider;

@property (nonatomic, strong) UILabel *reverberationLeftLabel;
@property (nonatomic, strong) ChorusMusicReverberationView *reverberationView;

@end

@implementation ChorusMusicTuningView


- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorFromRGBHexString:@"#06080E" andAlpha:1 * 255];
        
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(52);
            make.centerX.top.equalTo(self);
        }];
        
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(1);
            make.top.equalTo(self.titleLabel.mas_bottom);
        }];
        
        [self addSubview:self.earLabel];
        [self.earLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lineView.mas_bottom).offset(24);
            make.left.mas_equalTo(16);
            make.height.equalTo(@24);
        }];
        
        [self addSubview:self.switchView];
        [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.earLabel);
            make.right.equalTo(self).offset(-16);
        }];
        
        [self addSubview:self.earTipLabel];
        [self.earTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.earLabel.mas_bottom).offset(4);
            make.left.equalTo(self.earLabel);
            make.height.equalTo(@40);
            make.width.mas_lessThanOrEqualTo(SCREEN_WIDTH - 32);
        }];
        
        [self addSubview:self.earRightLabel];
        [self.earRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.earTipLabel.mas_bottom).offset(12);
            make.right.mas_equalTo(-16);
        }];
        
        [self addSubview:self.earSlider];
        [self.earSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.earRightLabel.mas_bottom).offset(10);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.height.equalTo(@22);
        }];
        
        [self addSubview:self.musicLeftLabel];
        [self.musicLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.earTipLabel.mas_bottom).offset(24);
            make.left.mas_equalTo(16);
            make.height.equalTo(@24);
        }];

        [self addSubview:self.musicRightLabel];
        [self.musicRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.musicLeftLabel);
            make.right.mas_equalTo(-16);
        }];

        [self addSubview:self.musicSlider];
        [self.musicSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.musicLeftLabel.mas_bottom).offset(10);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.height.equalTo(@22);
        }];
        
        [self addSubview:self.vocalLeftLabel];
        [self.vocalLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.musicSlider.mas_bottom).offset(24);
            make.left.mas_equalTo(16);
            make.height.equalTo(@24);
        }];

        [self addSubview:self.vocalRightLabel];
        [self.vocalRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.vocalLeftLabel);
            make.right.mas_equalTo(-16);
        }];

        [self addSubview:self.vocalSlider];
        [self.vocalSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.vocalLeftLabel.mas_bottom).offset(10);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.height.equalTo(@22);
        }];
        
        [self addSubview:self.reverberationLeftLabel];
        [self.reverberationLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.vocalSlider.mas_bottom).offset(24);
            make.left.mas_equalTo(16);
            make.height.equalTo(@24);
        }];
        
        [self addSubview:self.reverberationView];
        [self.reverberationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(89);
            make.top.equalTo(self.reverberationLeftLabel.mas_bottom).offset(10);
            make.bottom.equalTo(self).offset(- 14 - [DeviceInforTool getVirtualHomeHeight]);
        }];
        
        [self enableMusicVolume];
    }
    return self;
}

#pragma mark - Publish Action

- (void)reset:(BOOL)isStartMusic {
    [self.switchView setOn:NO];
    if ([ChorusRTCManager shareRtc].canEarMonitor) {
        self.switchView.enabled = YES;
        [self enableMusicVolume];
    } else {
        self.switchView.enabled = NO;
        [self enableMusicVolume];
    }
    CGFloat curMusicVolume = [ChorusDataManager shared].isLeadSinger ? DefaultMusicLeadSingerVolume : DefaultMusicVolume;
    self.earSlider.value = DefaultEarVolume;
    self.earRightLabel.text = @(DefaultEarVolume).stringValue;
    self.musicSlider.value = curMusicVolume;
    self.musicRightLabel.text = @(curMusicVolume).stringValue;
    self.vocalSlider.value = DefaultVocalVolume;
    self.vocalRightLabel.text = @(DefaultVocalVolume).stringValue;
    [self.reverberationView resetItemState:isStartMusic];
    
    [[ChorusRTCManager shareRtc] switchAccompaniment:YES];
    [[ChorusRTCManager shareRtc] setMusicVolume:curMusicVolume];
    [[ChorusRTCManager shareRtc] setRecordingVolume:DefaultVocalVolume];
    [[ChorusRTCManager shareRtc] setEarMonitorVolume:DefaultEarVolume];
}

#pragma mark - Private Action

- (void)switchViewChanged:(UISwitch *)sender {
    if (sender.on) {
        [[ChorusRTCManager shareRtc] enableEarMonitor:YES];
        [self enableMusicVolume];
    } else {
        [[ChorusRTCManager shareRtc] enableEarMonitor:NO];
        [self enableMusicVolume];
    }
}
- (void)updateAudioRouteChanged {
    if ([ChorusRTCManager shareRtc].canEarMonitor) {
        
        self.switchView.enabled = YES;
        [self enableMusicVolume];
    } else {
        [self.switchView setOn:NO];
        self.switchView.enabled = NO;
        [self enableMusicVolume];
        
        [[ChorusRTCManager shareRtc] enableEarMonitor:NO];
    }
}

- (void)enableMusicVolume {
    BOOL isEnable = self.switchView.isOn;
    
    self.earRightLabel.hidden = !isEnable;
    self.earSlider.hidden = !isEnable;
    
    if (isEnable) {
        [self.musicLeftLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.earSlider.mas_bottom).offset(24);
            make.left.mas_equalTo(16);
        }];
    } else {
        [self.musicLeftLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.earTipLabel.mas_bottom).offset(24);
            make.left.mas_equalTo(16);
        }];
    }
}

- (void)musicSliderValueChanged:(UISlider *)musicSlider {
    [[ChorusRTCManager shareRtc] setMusicVolume:musicSlider.value];
    self.musicRightLabel.text = [NSString stringWithFormat:@"%ld", (long)musicSlider.value];
}

- (void)vocalSliderValueChanged:(UISlider *)musicSlider {
    [[ChorusRTCManager shareRtc] setRecordingVolume:musicSlider.value];
    self.vocalRightLabel.text = [NSString stringWithFormat:@"%ld", (long)musicSlider.value];
}

- (void)earValueChanged:(UISlider *)musicSlider {
    [[ChorusRTCManager shareRtc] setEarMonitorVolume:musicSlider.value];
    self.earRightLabel.text = [NSString stringWithFormat:@"%ld", (long)musicSlider.value];
}

#pragma mark - Getter

- (UILabel *)earLabel {
    if (!_earLabel) {
        _earLabel = [[UILabel alloc] init];
        _earLabel.text = LocalizedString(@"label_tuning_ear");
        _earLabel.font = [UIFont systemFontOfSize:16];
        _earLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.9 * 255];
    }
    return _earLabel;
}

- (UISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[UISwitch alloc] init];
        _switchView.onTintColor = [UIColor colorFromHexString:@"#165DFF"];
        [_switchView addTarget:self action:@selector(switchViewChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (UISlider *)earSlider {
    if (!_earSlider) {
        _earSlider = [[UISlider alloc] init];
        [_earSlider setTintColor:[UIColor colorFromHexString:@"#FF1764"]];
        [_earSlider addTarget:self action:@selector(earValueChanged:) forControlEvents:UIControlEventValueChanged];
        _earSlider.minimumValue = 0;
        _earSlider.maximumValue = 100;
        _earSlider.value = DefaultEarVolume;
    }
    return _earSlider;
}

- (UILabel *)earTipLabel {
    if (!_earTipLabel) {
        _earTipLabel = [[UILabel alloc] init];
        _earTipLabel.text = LocalizedString(@"label_tuning_ear_tip");
        _earTipLabel.numberOfLines = 2;
        _earTipLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _earTipLabel.textColor = [UIColor colorFromRGBHexString:@"#737A87" andAlpha:0.75 * 255];
    }
    return _earTipLabel;
}

- (UILabel *)earRightLabel {
    if (!_earRightLabel) {
        _earRightLabel = [[UILabel alloc] init];
        _earRightLabel.text = @(DefaultEarVolume).stringValue;
        _earRightLabel.font = [UIFont systemFontOfSize:14];
        _earRightLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.75 * 255];
    }
    return _earRightLabel;
}

- (UILabel *)musicLeftLabel {
    if (!_musicLeftLabel) {
        _musicLeftLabel = [[UILabel alloc] init];
        _musicLeftLabel.text = LocalizedString(@"label_tuning_music_volume");
        _musicLeftLabel.font = [UIFont systemFontOfSize:16];
        _musicLeftLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.9 * 255];
    }
    return _musicLeftLabel;
}

- (UILabel *)musicRightLabel {
    if (!_musicRightLabel) {
        _musicRightLabel = [[UILabel alloc] init];
        _musicRightLabel.text = @(DefaultMusicVolume).stringValue;
        _musicRightLabel.font = [UIFont systemFontOfSize:14];
        _musicRightLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.75 * 255];
    }
    return _musicRightLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = LocalizedString(@"label_tuning_title");
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        _titleLabel.textColor = [UIColor colorFromHexString:@"#FFFFFF"];
    }
    return _titleLabel;
}

- (UISlider *)musicSlider {
    if (!_musicSlider) {
        _musicSlider = [[UISlider alloc] init];
        [_musicSlider setTintColor:[UIColor colorFromHexString:@"#FF1764"]];
        [_musicSlider addTarget:self action:@selector(musicSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _musicSlider.minimumValue = 0;
        _musicSlider.maximumValue = 100;
        _musicSlider.value = DefaultMusicVolume;
    }
    return _musicSlider;
}

- (UILabel *)vocalLeftLabel {
    if (!_vocalLeftLabel) {
        _vocalLeftLabel = [[UILabel alloc] init];
        _vocalLeftLabel.text = LocalizedString(@"label_tuning_vocal_volume");
        _vocalLeftLabel.font = [UIFont systemFontOfSize:16];
        _vocalLeftLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.9 * 255];
    }
    return _vocalLeftLabel;
}

- (UILabel *)vocalRightLabel {
    if (!_vocalRightLabel) {
        _vocalRightLabel = [[UILabel alloc] init];
        _vocalRightLabel.text = @(DefaultVocalVolume).stringValue;
        _vocalRightLabel.font = [UIFont systemFontOfSize:14];
        _vocalRightLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.75 * 255];
    }
    return _vocalRightLabel;
}

- (UILabel *)reverberationLeftLabel {
    if (!_reverberationLeftLabel) {
        _reverberationLeftLabel = [[UILabel alloc] init];
        _reverberationLeftLabel.text = LocalizedString(@"label_reverberation_title");
        _reverberationLeftLabel.font = [UIFont systemFontOfSize:16];
        _reverberationLeftLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.9 * 255];
    }
    return _reverberationLeftLabel;
}

- (UISlider *)vocalSlider {
    if (!_vocalSlider) {
        _vocalSlider = [[UISlider alloc] init];
        [_vocalSlider setTintColor:[UIColor colorFromHexString:@"#FF1764"]];
        [_vocalSlider addTarget:self action:@selector(vocalSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _vocalSlider.minimumValue = 0;
        _vocalSlider.maximumValue = 100;
        _vocalSlider.value = DefaultVocalVolume;
    }
    return _vocalSlider;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorFromRGBHexString:@"#DDE2E9" andAlpha:0.15 * 255];
    }
    return _lineView;
}

- (ChorusMusicReverberationView *)reverberationView {
    if (!_reverberationView) {
        _reverberationView = [[ChorusMusicReverberationView alloc] init];
        _reverberationView.backgroundColor = [UIColor clearColor];
    }
    return _reverberationView;
}


@end
