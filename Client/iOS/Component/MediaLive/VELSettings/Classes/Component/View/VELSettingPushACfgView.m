// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingPushACfgView.h"
#import "VELSettingsSegmentViewModel.h"
#import "VELSettingsSwitchViewModel.h"
#import "VELSettingsSliderInputViewModel.h"
#import <ToolKit/Localizator.h>
@interface VELSettingPushACfgView ()
@property (nonatomic, strong) VELSettingsSegmentViewModel *segmentUIModel;
@property (nonatomic, strong) VELSettingsSwitchViewModel *audioEchoModel;
@property (nonatomic, strong) VELSettingsSliderInputViewModel *audioLoudnessModel;
@end
@implementation VELSettingPushACfgView


- (void)initSubviewsInContainer:(UIView *)container {
    UIView *segmentView = self.segmentUIModel.settingView;
    [container addSubview:segmentView];
    [segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(container).mas_offset(self.model.insets);
    }];
}

- (void)layoutSubViewWithModel {
    [super layoutSubViewWithModel];
    UIView *segmentView = self.segmentUIModel.settingView;
    [segmentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.container).mas_offset(self.model.insets);
    }];
}
- (void)updateSubViewStateWithModel {
    [super updateSubViewStateWithModel];
    
    self.audioLoudnessModel.value = self.model.audioLoudness;
    [self.audioLoudnessModel updateUI];
    
    self.audioEchoModel.on = self.model.enableAudioEcho;
    [self.audioEchoModel updateUI];
}

- (VELSettingsSegmentViewModel *)segmentUIModel {
    if (!_segmentUIModel) {
        _segmentUIModel = [[VELSettingsSegmentViewModel alloc] init];
        _segmentUIModel.cornerRadius = 0;
        _segmentUIModel.itemMargin = 3;
        _segmentUIModel.title = LocalizedStringFromBundle(@"medialive_audio_title", @"MediaLive");
        _segmentUIModel.insets = UIEdgeInsetsMake(5, 0, 0, 0);
        _segmentUIModel.titleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor;
        _segmentUIModel.titleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:14];
        _segmentUIModel.margin = UIEdgeInsetsMake(10, 15, 10, 15);
        _segmentUIModel.scrollDirection = UICollectionViewScrollDirectionVertical;
        _segmentUIModel.backgroundColor = UIColor.clearColor;
        _segmentUIModel.containerBackgroundColor = UIColor.clearColor;
        _segmentUIModel.containerSelectBackgroundColor = UIColor.clearColor;
        _segmentUIModel.segmentModels = @[ self.audioEchoModel, self.audioLoudnessModel];
        _segmentUIModel.spacingBetweenTitleAndSegments = 12;
        _segmentUIModel.size = CGSizeMake(VELAutomaticDimension, VELAutomaticDimension);
        _segmentUIModel.disableSelectd = YES;
    }
    return _segmentUIModel;
}


- (VELSettingsSwitchViewModel *)audioEchoModel {
    if (!_audioEchoModel) {
        _audioEchoModel = [[VELSettingsSwitchViewModel alloc] init];
        _audioEchoModel.title = LocalizedStringFromBundle(@"medialive_audio_echo", @"MediaLive");
        _audioEchoModel.backgroundColor = UIColor.clearColor;
        _audioEchoModel.containerBackgroundColor = UIColor.clearColor;
        _audioEchoModel.containerSelectBackgroundColor = UIColor.clearColor;
        _audioEchoModel.size = CGSizeMake(VELAutomaticDimension, 30);
        __weak __typeof__(self)weakSelf = self;
        [_audioEchoModel setSwitchBlock:^(BOOL isOn) {
            __strong __typeof__(weakSelf)self = weakSelf;
            self.model.enableAudioEcho = isOn;
            if (self.model.enableAudioEchoBlock) {
                self.model.enableAudioEchoBlock(self.model, isOn);
            }
        }];
    }
    return _audioEchoModel;
}
- (VELSettingsSliderInputViewModel *)audioLoudnessModel {
    if (!_audioLoudnessModel) {
        _audioLoudnessModel = [[VELSettingsSliderInputViewModel alloc] init];
        [_audioLoudnessModel clearDefault];
        _audioLoudnessModel.leftText = LocalizedStringFromBundle(@"medialive_audio_loudness", @"MediaLive");
        _audioLoudnessModel.textAttribute[NSFontAttributeName] = [UIFont systemFontOfSize:14];
        _audioLoudnessModel.textAttribute[NSForegroundColorAttributeName] = UIColor.whiteColor;
        _audioLoudnessModel.maximumValue = 1;
        _audioLoudnessModel.minimumValue = 0;
        _audioLoudnessModel.size = CGSizeMake(VELAutomaticDimension, 30);
        _audioLoudnessModel.minimumTrackColor = UIColor.whiteColor;
        _audioLoudnessModel.thumbColor = UIColor.whiteColor;
        _audioLoudnessModel.maximumTrackColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        
        __weak __typeof__(self)weakSelf = self;
        [_audioLoudnessModel setValueChangedBlock:^(VELSettingsSliderInputViewModel * _Nonnull model) {
            __strong __typeof__(weakSelf)self = weakSelf;
            self.model.audioLoudness = model.value;
            if (self.model.audioLoudnessValueChangedBlock) {
                self.model.audioLoudnessValueChangedBlock(self.model, model.value);
            }
        }];
    }
    return _audioLoudnessModel;
}
@end
