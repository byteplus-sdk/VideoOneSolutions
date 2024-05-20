// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELBasicSettingPlayControlViewModel.h"
#import <ToolKit/Localizator.h>
@interface VELBasicSettingPlayControlViewModel ()
@property (nonatomic, strong) VELSettingsButtonViewModel *pauseResumeBtn;
@end

@implementation VELBasicSettingPlayControlViewModel

- (void)setupSettingsView {
    [self.settingsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *settingView = [[UIView alloc] init];
    UIView *lastSettingView = nil;
    [self.settingsView addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.settingsView);
        make.height.mas_equalTo(1);
    }];
    lastSettingView = settingView;
    
    settingView = self.topViewModel.settingView;
    [self.settingsView addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastSettingView.mas_bottom);
        make.left.right.equalTo(self.settingsView);
    }];
    lastSettingView = settingView;
    
    if (self.supportResolutions.count > 1) {
        settingView = self.resolutionViewModel.settingView;
        [self.settingsView addSubview:settingView];
        [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lastSettingView.mas_bottom);
            make.left.right.equalTo(lastSettingView);
        }];
        lastSettingView = settingView;
        [self refreshResolutionView];
    }
    settingView = [[UIView alloc] init];
    [self.settingsView addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastSettingView.mas_bottom).mas_offset(10);
        make.left.equalTo(lastSettingView);
        make.bottom.equalTo(self.settingsView).mas_offset(-10);
        make.height.mas_equalTo(1);
    }];
}

- (void)refreshResolutionView {
    NSMutableArray <VELSettingsButtonViewModel *>* segments = [NSMutableArray arrayWithCapacity:self.supportResolutions.count];
    [self.resolutionViewModel.segmentModels enumerateObjectsUsingBlock:^(VELSettingsButtonViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger res = [obj.extraInfo[@"RESOLUTION"] integerValue];
        if ([self.supportResolutions containsObject:@(res)]) {
            [segments addObject:obj];
        }
    }];
    self.resolutionViewModel.segmentModels = segments;
    [self.resolutionViewModel updateUI];
    
    __block NSInteger selectIndex = 0;
    [self.resolutionViewModel.segmentModels enumerateObjectsUsingBlock:^(VELSettingsButtonViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger res = [obj.extraInfo[@"RESOLUTION"] integerValue];
        if (res == self.defaultResolution) {
            obj.isSelected = YES;
            [obj updateUI];
            selectIndex = idx;
            *stop = YES;
        }
    }];
    self.resolutionViewModel.selectIndex = selectIndex;
    [self.resolutionViewModel updateUI];
}

- (void)setShouldPlayInBackground:(BOOL)playInBackground {
    self.backgroundPlayViewModel.isSelected = playInBackground;
    [self.backgroundPlayViewModel updateUI];
}

- (void)setSupportResolutions:(NSArray<NSNumber *> *)supportResolutions defaultResolution:(NSInteger)defaultRes {
    _defaultResolution = defaultRes;
    if (_supportResolutions.count <= 1 || supportResolutions.count <= 1) {
        if (self.settingsView.subviews.count > 0) {
            _supportResolutions = supportResolutions;
            [self setupSettingsView];
            return;
        }
    }
    _supportResolutions = supportResolutions;
    [self refreshResolutionView];
}

- (void)setupViewModels {
    NSMutableArray <VELSettingsButtonViewModel *> *segmentModels = [NSMutableArray arrayWithCapacity:5];
    __weak __typeof__(self)weakSelf = self;
    VELSettingsButtonViewModel *btnModel = [VELSettingsButtonViewModel modelWithTitle:LocalizedStringFromBundle(@"medialive_start_play", @"MediaLive") action:^(VELSettingsButtonViewModel *model, NSInteger index) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if ([self.delegate respondsToSelector:@selector(play)]) {
            [self.delegate play];
        }
        self.pauseResumeBtn.isSelected = NO;
        [self.pauseResumeBtn updateUI];
    }];
    [segmentModels addObject:btnModel];
    
    btnModel = [VELSettingsButtonViewModel modelWithTitle:LocalizedStringFromBundle(@"medialive_stop_play", @"MediaLive") action:^(VELSettingsButtonViewModel *model, NSInteger index) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if ([self.delegate respondsToSelector:@selector(stop)]) {
            [self.delegate stop];
        }
    }];
    [segmentModels addObject:btnModel];
    
    btnModel = [VELSettingsButtonViewModel modelWithTitle:LocalizedStringFromBundle(@"medialive_pause", @"MediaLive") action:^(VELSettingsButtonViewModel *model, NSInteger index) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (model.isSelected) {
            if ([self.delegate respondsToSelector:@selector(pause)]) {
                [self.delegate pause];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(resume)]) {
                [self.delegate resume];
            }
        }
    }];
    self.pauseResumeBtn = btnModel;
    btnModel.selectTitle = LocalizedStringFromBundle(@"medialive_resume", @"MediaLive");
    btnModel.containerSelectBackgroundColor = VELColorWithHexString(@"#E5E8EF");
    btnModel.selectTitleAttributes[NSForegroundColorAttributeName] = VELColorWithHexString(@"#535552");
    [segmentModels addObject:btnModel];
    
    btnModel = [VELSettingsButtonViewModel checkBoxModelWithTitle:LocalizedStringFromBundle(@"medialive_play_background", @"MediaLive") action:^(VELSettingsButtonViewModel *model, NSInteger index) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (model.isSelected) {
            if ([self.delegate respondsToSelector:@selector(startPlayInBackground)]) {
                [self.delegate startPlayInBackground];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(stopPlayInBackground)]) {
                [self.delegate stopPlayInBackground];
            }
        }
    }];
    btnModel.margin = UIEdgeInsetsZero;
    btnModel.insets = UIEdgeInsetsZero;
    self.backgroundPlayViewModel = btnModel;
    [segmentModels addObject:btnModel];


    self.topViewModel.size = CGSizeMake(VELAutomaticDimension, 90);
    self.topViewModel.segmentModels = segmentModels.copy;
    
    [segmentModels removeAllObjects];
    NSArray *resolutions = @[@"Origin", @"UHD", @"HD", @"LD", @"SD"];
    _supportResolutions = @[@(0), @(1), @(2), @(3), @(4)];
    [resolutions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        VELSettingsButtonViewModel *model = [VELSettingsButtonViewModel modelWithTitle:obj action:nil];
        model.containerSelectBackgroundColor = VELColorWithHexString(@"#E5E8EF");
        model.selectTitleAttributes[NSForegroundColorAttributeName] = VELColorWithHexString(@"#535552");
        model.useCellSelect = YES;
        model.userInteractionEnabled = NO;
        model.size = CGSizeMake(44, 27);
        model.extraInfo[@"RESOLUTION"] = @(idx);
        [segmentModels addObject:model];
    }];
    self.resolutionViewModel.segmentModels = segmentModels.copy;
    [self.resolutionViewModel setSegmentModelSelectedBlock:^(VELSettingsButtonViewModel * _Nonnull model, NSInteger index) {
        __strong __typeof__(weakSelf)self = weakSelf;
        NSInteger currentResolution = [self.resolutionViewModel.selectModel.extraInfo[@"RESOLUTION"] integerValue];
        NSInteger selectResolution = [model.extraInfo[@"RESOLUTION"] integerValue];
        if (currentResolution == selectResolution) {
            return;
        }
        BOOL shouldChange = YES;
        if ([self.delegate respondsToSelector:@selector(resolutionShouldChanged:to:)]) {
            shouldChange = [self.delegate resolutionShouldChanged:currentResolution to:selectResolution];
        }
        if (!shouldChange) {
            [VELUIToast showText:LocalizedStringFromBundle(@"medialive_resume", @"MediaLive"), model.title];
            return;
        }
        if (shouldChange && [self.delegate respondsToSelector:@selector(resolutionDidChanged:to:)]) {
            [self.delegate resolutionDidChanged:currentResolution to:selectResolution];
        }
    }];
}

- (VELSettingsSegmentViewModel *)topViewModel {
    if (!_topViewModel) {
        _topViewModel = [[VELSettingsSegmentViewModel alloc] init];
        [_topViewModel clearDefault];
        _topViewModel.disableSelectd = YES;
        _topViewModel.scrollDirection = UICollectionViewScrollDirectionVertical;
        _topViewModel.itemMargin = 10;
        _topViewModel.margin = UIEdgeInsetsMake(8, 10, 8, 10);
        _topViewModel.size = CGSizeMake(VELAutomaticDimension, 90);
    }
    return _topViewModel;
}

- (VELSettingsSegmentViewModel *)resolutionViewModel {
    if (!_resolutionViewModel) {
        _resolutionViewModel = [[VELSettingsSegmentViewModel alloc] init];
        [_resolutionViewModel clearDefault];
        _resolutionViewModel.title = LocalizedStringFromBundle(@"medialive_change_resolution", @"MediaLive");
        _resolutionViewModel.size = CGSizeMake(VELAutomaticDimension, 76);
        _resolutionViewModel.margin = UIEdgeInsetsMake(8, 10, 8, 10);
        _resolutionViewModel.titleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor;
    }
    return _resolutionViewModel;
}


- (VELSettingsButtonViewModel *)hdrViewModel {
    if (!_hdrViewModel) {
        __weak __typeof__(self)weakSelf = self;
        _hdrViewModel = [VELSettingsButtonViewModel checkBoxModelWithTitle:LocalizedStringFromBundle(@"medialive_open_hdr", @"MediaLive") action:^(VELSettingsButtonViewModel *model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            BOOL supportHDR = NO;
            if ([self.delegate respondsToSelector:@selector(isSupportHDR)]) {
                supportHDR = [self.delegate isSupportHDR];
            }
            if (!supportHDR) {
                model.isSelected = NO;
                [model updateUI];
                [VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_hdr", @"MediaLive")];
                return;
            }
            if (model.isSelected && [self.delegate respondsToSelector:@selector(openHDR)]) {
                [self.delegate openHDR];
            } else if (!model.isSelected && [self.delegate respondsToSelector:@selector(closeHDR)]) {
                [self.delegate closeHDR];
            }
        }];
        _hdrViewModel.margin = UIEdgeInsetsMake(8, 10, 8, 10);
        _hdrViewModel.size = CGSizeMake(VELAutomaticDimension, 27);
    }
    return _hdrViewModel;
}


@end
