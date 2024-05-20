// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushUIViewController+Private.h"
#import "VELPushUIViewController+Info.h"
#import <ToolKit/Localizator.h>
@interface VELPushUIViewController (Preview_Settings_Delegate) <VELPushSettingProtocol>
@end

@implementation VELPushUIViewController (Preview)

- (void)setupUIForNotStreaming {
    if (!self.isViewLoaded) {
        return;
    }
    self.netQualityView.hidden = YES;
    [self setupUIForNotStreamingLandSpace:(self.view.vel_width > self.view.vel_height) force:NO];
}

- (void)setupUIForNotStreamingLandSpace:(BOOL)isLandSpace force:(BOOL)force {
    if (!self.isViewLoaded) {
        return;
    }
    if (!self.previewControl.isHidden && !force) {
        return;
    }
    [self hideAllPopView];
    [self hideAllConsoleInfoView];
    _streamingControl.hidden = YES;
    [self.popControlView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (self.startPushBtn.superview != self.controlContainerView
        || self.startPushBtn.isHidden
        || force) {
        [self.startPushBtn removeFromSuperview];
        [self.controlContainerView insertSubview:self.startPushBtn atIndex:0];
        [self.startPushBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(213, 48));
            make.centerX.equalTo(self.controlContainerView);
            make.bottom.equalTo(self.controlContainerView).mas_offset(-(isLandSpace ? 25 : 80));
        }];
    }
    if (self.previewControl.superview != self.controlContainerView
        || self.previewControl.isHidden
        || force) {
        [self.previewControl removeFromSuperview];
        [self.controlContainerView insertSubview:self.previewControl atIndex:0];
        CGSize itemSize = self.previewControl.models.firstObject.size;
         CGFloat preControlHeight = itemSize.height;
        __block CGFloat totalWidth = 0;
        [self.previewControl.models enumerateObjectsUsingBlock:^(__kindof VELSettingsBaseViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            totalWidth += obj.size.width;
        }];
        [self.previewControl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.startPushBtn);
            make.size.mas_equalTo(CGSizeMake(totalWidth,preControlHeight));
            make.bottom.equalTo(self.startPushBtn.mas_top).mas_offset(-(isLandSpace ? 15 : 37));
        }];
        
        [self.popControlView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (isLandSpace) {
                make.top.equalTo(self.view).mas_offset(10);
            } else {
                make.top.equalTo(self.navigationBar.mas_bottom);
            }
            if (@available(iOS 11.0, *)) {
                make.left.equalTo(self.controlContainerView.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.controlContainerView.mas_safeAreaLayoutGuideRight);
                make.bottom.equalTo(self.controlContainerView);
            } else {
                make.left.right.bottom.equalTo(self.controlContainerView);
            }
        }];
    }
    [self.rotateViewModel setTitle:isLandSpace ? LocalizedStringFromBundle(@"medialive_portrait", @"MediaLive") : LocalizedStringFromBundle(@"medialive_landscape", @"MediaLive")];
    [self.rotateViewModel updateUI];
    self.startPushBtn.hidden = NO;
    self.previewControl.hidden = NO;
}

- (void)showPreviewSettings {
    if (!self.isPreviewSettingsShowing) {
        VELPushSettingConfig *oldConfig = [self.config mutableCopy];
        self.previewSettingVC.pushConfig = self.config;
        __weak __typeof__(self)weakSelf = self;
        [self.previewSettingVC showFromVC:self
                               completion:^(VELPushSettingViewController * _Nonnull vc, VELPushSettingConfig * _Nonnull config) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if ([config needRestartEngineFrom:oldConfig]) {
                [self restartEngine];
            } else if (config.renderMode != oldConfig.renderMode) {
                [self setPreviewRenderMode:(VELSettingPreviewRenderMode)config.renderMode];
            }
        }];
        self.currentPopObj = self.previewSettingViewModel;
    }
}

- (void)hidePreviewSettings {
    if (self.isPreviewSettingsShowing) {
        [self.previewSettingVC hide];
        if (self.currentPopObj == self.effectViewModel) {
            self.currentPopObj = nil;
        }
    }
}

- (BOOL)isPreviewSettingsShowing {
    return self.previewSettingVC.isShowing;
}

- (VELSettingsCollectionView *)previewControl {
    if (!_previewControl) {
        _previewControl = [[VELSettingsCollectionView alloc] init];
        _previewControl.hidden = YES;
        _previewControl.backgroundColor = [UIColor clearColor];
        _previewControl.itemMargin = 0;
        _previewControl.allowSelection = YES;
        _previewControl.layoutMode = VELCollectionViewLayoutModeLeft;
        _previewControl.models = [self getNoStreamingControlModels];
        __weak __typeof__(self)weakSelf = self;
        [_previewControl setSelectedItemBlock:^(__kindof VELSettingsBaseViewModel * _Nonnull model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (model != self.currentPopObj) {
                [self hideAllPopView];
            }
        }];
    }
    return _previewControl;
}

- (NSArray <VELSettingsButtonViewModel *> *)getNoStreamingControlModels {
    NSMutableArray <VELSettingsButtonViewModel *> *models = [NSMutableArray arrayWithCapacity:6];
    if (self.config.captureType == VELSettingCaptureTypeInner) {
        [models addObject:self.cameraViewModel];
        [models addObject:self.torchViewModel];
    }
    
    if (self.isSupportEffect) {
        [models addObject:self.effectViewModel];
    }
    
    [models addObject:self.rotateViewModel];
    
    [models addObject:self.previewSettingViewModel];
    return models;
}

- (VELPushSettingViewController *)previewSettingVC {
    if (!_previewSettingVC) {
        _previewSettingVC = [[VELPushSettingViewController alloc] init];
        _previewSettingVC.delegate = self;
    }
    return _previewSettingVC;
}
@end


@implementation VELPushUIViewController (Preview_Settings_Delegate)
- (void)pushSetting:(id)vc onRenderModeChanged:(VELSettingPreviewRenderMode)renderMode {
    [self setPreviewRenderMode:renderMode];
}
@end
