// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullAVSettingAudioViewModel.h"
#import <ToolKit/Localizator.h>

@interface VELPullAVSettingAudioViewModel ()
@property (nonatomic, strong) VELUILabel *volumeLabel;
@end

@implementation VELPullAVSettingAudioViewModel

- (void)setupSettingsView {
    UIView *settingView = [[UIView alloc] init];
    UIView *lastSettingView = nil;
    [self.settingsView addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.settingsView);
        make.height.mas_equalTo(1);
    }];
    lastSettingView = settingView;
    
    settingView = self.volumeLabel;
    [self.settingsView addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastSettingView.mas_bottom).mas_offset(10);
        make.left.equalTo(self.settingsView).mas_offset(10);
    }];
    lastSettingView = settingView;
    
    settingView = self.volumeViewModel.settingView;
    [self.settingsView addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.settingsView).mas_offset(10);
        make.top.equalTo(lastSettingView.mas_bottom);
    }];
    lastSettingView = settingView;
    
    settingView = self.muteViewModel.settingView;
    [self.settingsView addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lastSettingView);
        make.left.equalTo(lastSettingView.mas_right);
        make.right.equalTo(self.settingsView.mas_right);
    }];
    lastSettingView = settingView;
    settingView = [[UIView alloc] init];
    [self.settingsView addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastSettingView.mas_bottom).mas_offset(10);
        make.left.equalTo(lastSettingView);
        make.bottom.equalTo(self.settingsView).mas_offset(-10);
        make.height.mas_equalTo(1);
    }];
}

- (void)setupViewModels {
    __weak __typeof__(self)weakSelf = self;
    self.muteViewModel =  [VELSettingsButtonViewModel checkBoxModelWithTitle:LocalizedStringFromBundle(@"medialive_mute", @"MediaLive") action:^(VELSettingsButtonViewModel * _Nonnull model, NSInteger index) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (model.isSelected) {
            if ([self.delegate respondsToSelector:@selector(mute)]) {
                [self.delegate mute];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(unMute)]) {
                [self.delegate unMute];
            }
        }
    }];
    self.muteViewModel.useCellSelect = NO;
    self.muteViewModel.margin = UIEdgeInsetsMake(8, 10, 8, 10);
    self.muteViewModel.size = CGSizeMake(80, 45);
    
    self.volumeViewModel = [[VELSettingsSliderInputViewModel alloc] init];
    [self.volumeViewModel clearDefault];
    self.volumeViewModel.showInput = NO;
    self.volumeViewModel.minimumValue = 0;
    self.volumeViewModel.maximumValue = 1;
    self.volumeViewModel.size = CGSizeMake(VELAutomaticDimension, 30);
    self.volumeViewModel.minimumTrackColor = UIColor.whiteColor;
    self.volumeViewModel.thumbColor = UIColor.whiteColor;
    self.volumeViewModel.maximumTrackColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    self.volumeViewModel.size = CGSizeMake(190, VELAutomaticDimension);
    [self.volumeViewModel setValueChangedBlock:^(VELSettingsSliderInputViewModel * _Nonnull model) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if ([self.delegate respondsToSelector:@selector(changeVolume:)]) {
            [self.delegate changeVolume:model.value];
        }
    }];
}

- (void)setCurrentVolume:(float)currentVolume {
    _currentVolume = currentVolume;
    self.volumeViewModel.value = currentVolume;
    [self.volumeViewModel updateUI];
}

- (VELUILabel *)volumeLabel {
    if (!_volumeLabel) {
        _volumeLabel = [[VELUILabel alloc] init];
        _volumeLabel.font = [UIFont systemFontOfSize:14];
        _volumeLabel.textColor = UIColor.whiteColor;
        _volumeLabel.text = LocalizedStringFromBundle(@"medialive_loudness", @"MediaLive");
    }
    return _volumeLabel;
}
@end
