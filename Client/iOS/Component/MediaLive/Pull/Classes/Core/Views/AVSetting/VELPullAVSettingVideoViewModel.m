// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullAVSettingVideoViewModel.h"
#import <ToolKit/Localizator.h>
@interface VELPullAVSettingVideoViewModel ()
@property (nonatomic, strong) VELSettingsButtonViewModel *currentRotateObj;
@property (nonatomic, strong) VELSettingsButtonViewModel *currentFillObj;
@property (nonatomic, strong) VELSettingsButtonViewModel *currentMirrorObj;
@end
@implementation VELPullAVSettingVideoViewModel
- (void)setupSettingsView {
    UIView *settingView = [[UIView alloc] init];
    UIView *lastSettingView = nil;
    [self.settingsView addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.settingsView);
        make.height.mas_equalTo(1);
    }];
    lastSettingView = settingView;
    
    settingView = self.snapShotViewModel.settingView;
    [self.settingsView addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastSettingView.mas_bottom);
        make.left.equalTo(self.settingsView);
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

- (void)resetAVSettings {}

- (void)setupViewModels {
    __weak __typeof__(self)weakSelf = self;
    self.snapShotViewModel =  [VELSettingsButtonViewModel modelWithTitle:LocalizedStringFromBundle(@"medialive_snapshot", @"MediaLive") action:^(VELSettingsButtonViewModel * _Nonnull model, NSInteger index) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if ([self.delegate respondsToSelector:@selector(snapshot)]) {
            [self.delegate snapshot];
        }
    }];
    self.snapShotViewModel.margin = UIEdgeInsetsMake(8, 10, 8, 10);
    self.snapShotViewModel.size = CGSizeMake(100, 45);
}

- (VELSettingsSegmentViewModel *)createSegmentWithTitle:(NSString *)title models:(NSArray <__kindof VELSettingsBaseViewModel *> *)models {
    VELSettingsSegmentViewModel *segmentModel = [[VELSettingsSegmentViewModel alloc] init];
    [segmentModel clearDefault];
    segmentModel.disableSelectd = YES;
    segmentModel.segmentModels = models;
    segmentModel.titleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor;
    segmentModel.margin = UIEdgeInsetsMake(8, 10, 0, 10);
    segmentModel.spacingBetweenTitleAndSegments = 0;
    segmentModel.size = CGSizeMake(VELAutomaticDimension, 65);
    segmentModel.title = title;
    return segmentModel;
}

@end
