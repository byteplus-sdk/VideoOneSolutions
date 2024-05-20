// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingPushVCfgView.h"
#import "VELSettingsSegmentViewModel.h"
#import "VELSettingsSwitchViewModel.h"
#import "VELSettingsPopChooseViewModel.h"
#import "VELSettingsSliderInputViewModel.h"
#import <ToolKit/Localizator.h>
@interface VELSettingPushVCfgView ()
@property (nonatomic, strong) VELSettingsSegmentViewModel *segmentUIModel;
@property (nonatomic, strong) VELSettingsPopChooseViewModel *videoResolutionViewModel;
@property (nonatomic, strong) NSArray <NSNumber *> *videoResolutionMenuValues;
@property (nonatomic, strong) VELSettingsSliderInputViewModel *fpsViewModel;
@end
@implementation VELSettingPushVCfgView

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
    self.videoResolutionViewModel.selectIndex = [self.videoResolutionMenuValues indexOfObject:@(self.model.resolutionType)];
    self.fpsViewModel.value = self.model.fps;
}

- (VELSettingsSegmentViewModel *)segmentUIModel {
    if (!_segmentUIModel) {
        _segmentUIModel = [[VELSettingsSegmentViewModel alloc] init];
        _segmentUIModel.cornerRadius = 0;
        _segmentUIModel.itemMargin = 3;
        _segmentUIModel.title = LocalizedStringFromBundle(@"medialive_video_title", @"MediaLive");
        _segmentUIModel.insets = UIEdgeInsetsMake(5, 0, 0, 0);
        _segmentUIModel.titleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor;
        _segmentUIModel.titleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:14];
        _segmentUIModel.margin = UIEdgeInsetsMake(10, 15, 10, 15);
        _segmentUIModel.scrollDirection = UICollectionViewScrollDirectionVertical;
        _segmentUIModel.backgroundColor = UIColor.clearColor;
        _segmentUIModel.containerBackgroundColor = UIColor.clearColor;
        _segmentUIModel.containerSelectBackgroundColor = UIColor.clearColor;
        _segmentUIModel.segmentModels = @[self.videoResolutionViewModel, self.fpsViewModel];
        _segmentUIModel.spacingBetweenTitleAndSegments = 12;
        _segmentUIModel.size = CGSizeMake(VELAutomaticDimension, VELAutomaticDimension);
        _segmentUIModel.disableSelectd = YES;
    }
    return _segmentUIModel;
}

- (VELSettingsPopChooseViewModel *)videoResolutionViewModel {
    if (!_videoResolutionViewModel) {
        NSArray *menuValues = @[@(VELSettingResolutionType_360),
                                @(VELSettingResolutionType_480),
                                @(VELSettingResolutionType_540),
                                @(VELSettingResolutionType_720),
                                @(VELSettingResolutionType_1080)];
        self.videoResolutionMenuValues = menuValues;
        __weak __typeof__(self)weakSelf = self;
        _videoResolutionViewModel = [VELSettingsPopChooseViewModel createCommonMenuModelWithTitle: LocalizedStringFromBundle(@"medialive_encode_resolution", @"MediaLive")
                                                                                       menuTitles:@[@"360P", @"480P", @"540P", @"720P", @"1080P"]
                                                                                       menuValues:menuValues
                                                                                      selectBlock:^BOOL(NSInteger index, NSNumber * _Nonnull value) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (self.model.videoResolutionChanged) {
                self.model.videoResolutionChanged(value.integerValue);
            }
            return YES;
        }];
        [_videoResolutionViewModel clearDefault];
        _videoResolutionViewModel.size = CGSizeMake(VELAutomaticDimension, 30);
    }
    return _videoResolutionViewModel;
}

- (VELSettingsSliderInputViewModel *)fpsViewModel {
    if (!_fpsViewModel) {
        _fpsViewModel = [[VELSettingsSliderInputViewModel alloc] init];
        [_fpsViewModel clearDefault];
        _fpsViewModel.leftText = LocalizedStringFromBundle(@"medialive_encode_fps", @"MediaLive");
        _fpsViewModel.textAttribute[NSFontAttributeName] = [UIFont systemFontOfSize:14];
        _fpsViewModel.textAttribute[NSForegroundColorAttributeName] = UIColor.whiteColor;
        _fpsViewModel.maximumValue = 30;
        _fpsViewModel.minimumValue = 15;
        _fpsViewModel.valueFormat = @"%d";
        _fpsViewModel.showInput = YES;
        [_fpsViewModel.inputTextAttribute setObject:UIColor.whiteColor forKey:NSForegroundColorAttributeName];
        _fpsViewModel.size = CGSizeMake(VELAutomaticDimension, 30);
        _fpsViewModel.inputSize = CGSizeMake(36, 24);
        _fpsViewModel.minimumTrackColor = UIColor.whiteColor;
        _fpsViewModel.thumbColor = UIColor.whiteColor;
        _fpsViewModel.maximumTrackColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        __weak __typeof__(self)weakSelf = self;
        [_fpsViewModel setValueChangedBlock:^(VELSettingsSliderInputViewModel * _Nonnull model) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self delayCallFpsValueChanged:model.value];
        }];
    }
    return _fpsViewModel;
}

- (void)delayCallFpsValueChanged:(int)fps {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(callFpsValueChanged:) withObject:@(fps) afterDelay:0.1];
}

- (void)callFpsValueChanged:(NSNumber *)value {
    if (self.model.videoFpsChanged) {
        self.model.videoFpsChanged(value.intValue);
    }
}
@end
