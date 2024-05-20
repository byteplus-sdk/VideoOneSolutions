// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsMirrorView.h"
#import "VELSettingsSegmentViewModel.h"
#import "VELSettingsSwitchViewModel.h"
#import <ToolKit/Localizator.h>
@interface VELSettingsMirrorView ()
@property (nonatomic, strong) VELSettingsSegmentViewModel *segmentUIModel;
@property (nonatomic, strong) VELSettingsSwitchViewModel *captureMirrorModel;
@property (nonatomic, strong) VELSettingsSwitchViewModel *previewMirrorModel;
@property (nonatomic, strong) VELSettingsSwitchViewModel *streamMirrorModel;
@end
@implementation VELSettingsMirrorView


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
    self.captureMirrorModel.on = self.model.captureMirror;
    [self.captureMirrorModel updateUI];
    self.previewMirrorModel.on = self.model.previewMirror;
    [self.previewMirrorModel updateUI];
    self.streamMirrorModel.on = self.model.streamMirror;
    [self.streamMirrorModel updateUI];
}

- (VELSettingsSegmentViewModel *)segmentUIModel {
    if (!_segmentUIModel) {
        _segmentUIModel = [[VELSettingsSegmentViewModel alloc] init];
        _segmentUIModel.cornerRadius = 0;
        _segmentUIModel.itemMargin = 3;
        _segmentUIModel.title = LocalizedStringFromBundle(@"medialive_mirror_title", @"MediaLive");
        _segmentUIModel.insets = UIEdgeInsetsMake(5, 0, 0, 0);
        _segmentUIModel.titleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor;
        _segmentUIModel.titleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:14];
        _segmentUIModel.margin = UIEdgeInsetsMake(10, 15, 10, 15);
        _segmentUIModel.scrollDirection = UICollectionViewScrollDirectionVertical;
        _segmentUIModel.backgroundColor = UIColor.clearColor;
        _segmentUIModel.containerBackgroundColor = UIColor.clearColor;
        _segmentUIModel.containerSelectBackgroundColor = UIColor.clearColor;
        _segmentUIModel.segmentModels = @[self.captureMirrorModel, self.previewMirrorModel, self.streamMirrorModel];
        _segmentUIModel.spacingBetweenTitleAndSegments = 12;
        _segmentUIModel.size = CGSizeMake(VELAutomaticDimension, VELAutomaticDimension);
        _segmentUIModel.disableSelectd = YES;
    }
    return _segmentUIModel;
}

- (VELSettingsSwitchViewModel *)captureMirrorModel {
    if (!_captureMirrorModel) {
        _captureMirrorModel = [[VELSettingsSwitchViewModel alloc] init];
        _captureMirrorModel.title = LocalizedStringFromBundle(@"medialive_mirror_capture", @"MediaLive");
        _captureMirrorModel.backgroundColor = UIColor.clearColor;
        _captureMirrorModel.containerBackgroundColor = UIColor.clearColor;
        _captureMirrorModel.containerSelectBackgroundColor = UIColor.clearColor;
        _captureMirrorModel.size = CGSizeMake(VELAutomaticDimension, 30);
        __weak __typeof__(self)weakSelf = self;
        [_captureMirrorModel setSwitchBlock:^(BOOL isOn) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (self.model.mirrorActionBlock) {
                self.model.mirrorActionBlock(self.model, VELSettingsMirrorTypeCapture, isOn);
            }
        }];
    }
    return _captureMirrorModel;
}

- (VELSettingsSwitchViewModel *)previewMirrorModel {
    if (!_previewMirrorModel) {
        _previewMirrorModel = [[VELSettingsSwitchViewModel alloc] init];
        _previewMirrorModel.title = LocalizedStringFromBundle(@"medialive_mirror_preview", @"MediaLive");
        _previewMirrorModel.backgroundColor = UIColor.clearColor;
        _previewMirrorModel.containerBackgroundColor = UIColor.clearColor;
        _previewMirrorModel.containerSelectBackgroundColor = UIColor.clearColor;
        _previewMirrorModel.size = CGSizeMake(VELAutomaticDimension, 30);
        __weak __typeof__(self)weakSelf = self;
        [_previewMirrorModel setSwitchBlock:^(BOOL isOn) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (self.model.mirrorActionBlock) {
                self.model.mirrorActionBlock(self.model, VELSettingsMirrorTypePreview, isOn);
            }
        }];
    }
    return _previewMirrorModel;
}

- (VELSettingsSwitchViewModel *)streamMirrorModel {
    if (!_streamMirrorModel) {
        _streamMirrorModel = [[VELSettingsSwitchViewModel alloc] init];
        _streamMirrorModel.title = LocalizedStringFromBundle(@"medialive_mirror_push", @"MediaLive");
        _streamMirrorModel.backgroundColor = UIColor.clearColor;
        _streamMirrorModel.containerBackgroundColor = UIColor.clearColor;
        _streamMirrorModel.containerSelectBackgroundColor = UIColor.clearColor;
        _streamMirrorModel.size = CGSizeMake(VELAutomaticDimension, 30);
        __weak __typeof__(self)weakSelf = self;
        [_streamMirrorModel setSwitchBlock:^(BOOL isOn) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (self.model.mirrorActionBlock) {
                self.model.mirrorActionBlock(self.model, VELSettingsMirrorTypeStream, isOn);
            }
        }];
    }
    return _streamMirrorModel;
}


@end
