// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushUIViewController+Private.h"
#import <ToolKit/Localizator.h>
#import <Toolkit/ToolKit.h>

@implementation VELPushUIViewController (Stream)
- (void)showStreamSettings {
    if (!self.isStreamSettingsShowing) {
        self.pushSettingView.hidden = NO;
        self.vCfgViewModel.fps = (int)self.config.encodeFPS;
        self.vCfgViewModel.resolutionType = self.config.encodeResolutionType;
        CGFloat height = self.popControlView.vel_height;
        self.pushSettingView.frame = CGRectMake(0,
                                                self.popControlView.vel_height,
                                                self.popControlView.vel_width,
                                                height);
        [self.popControlView addSubview:self.pushSettingView];
        [UIView animateWithDuration:0.3 animations:^{
            self.pushSettingView.vel_top = self.popControlView.vel_height - height;
        }];
        self.currentPopObj = self.streamSettingViewModel;
    }
}

- (void)hideStreamSettings {
    if (self.isStreamSettingsShowing) {
        [UIView animateWithDuration:0.3 animations:^{
            self.pushSettingView.vel_top = self.popControlView.vel_height;
        } completion:^(BOOL finished) {
            [self.pushSettingView removeFromSuperview];
        }];
        if (self.currentPopObj == self.effectViewModel) {
            self.currentPopObj = nil;
        }
    }
}

- (BOOL)isStreamSettingsShowing {
    return (self.pushSettingView.superview == self.popControlView && !self.pushSettingView.isHidden);
}

- (void)resetSettingView {
    [_pushSettingView removeFromSuperview];
    _pushSettingView = nil;
    _recordViewModel = nil;
    _mirrorViewModel = nil;
    _seiViewModel = nil;
    _aCfgViewModel = nil;
    _vCfgViewModel = nil;
}

- (void)setupUIForStreaming {
    if (!self.isViewLoaded) {
        return;
    }
    self.netQualityView.hidden = NO;
    [self setupUIForStreamingLandspace:(self.view.vel_width > self.view.vel_height) force:NO];
}
- (void)setupUIForStreamingLandspace:(BOOL)isLandSpace force:(BOOL)force {
    if (!self.isViewLoaded) {
        return;
    }
    if (!self.streamingControl.isHidden && !force) {
        return;
    }
    _pushSettingView = nil;
    _infoSettingVM = nil;
    [self hideAllPopView];
    [self hideCycleInfo];
    [self hideCallbackNote];
    self.startPushBtn.hidden = YES;
    self.previewControl.hidden = YES;
    [self.popControlView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (self.streamingControl.superview != self.controlContainerView
        || self.streamingControl.isHidden
        || force) {
        [self.streamingControl removeFromSuperview];
        [self.controlContainerView insertSubview:self.streamingControl atIndex:0];
        
        [self.streamingControl mas_remakeConstraints:^(MASConstraintMaker *make) {
            CGSize itemSize = self.streamingControl.models.firstObject.size;
            CGSize controlSize = CGSizeMake(itemSize.width, self.streamingControl.models.count * itemSize.height);
            CGFloat maxHeight = isLandSpace ? VEL_DEVICE_WIDTH : VEL_DEVICE_HEIGHT;
            CGFloat layoutBottom = VEL_SAFE_INSERT.bottom + (isLandSpace ? 10 : 30);
            CGFloat layoutTop = VEL_SAFE_INSERT.top + (isLandSpace ? 10 : 30);
            maxHeight = maxHeight - layoutBottom - layoutTop;
            make.size.mas_equalTo(CGSizeMake(controlSize.width, MIN(controlSize.height, maxHeight)));
            if (@available(iOS 11.0, *)) {
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).mas_offset(-10);
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).mas_offset(-(isLandSpace ? 10 : 30));
            } else {
                make.right.equalTo(self.view).mas_offset(-10);
                make.bottom.equalTo(self.mas_bottomLayoutGuideTop).mas_offset(-(isLandSpace ? 10 : 30));
            }
        }];
        
        [self.popControlView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (isLandSpace) {
                make.top.equalTo(self.view).mas_offset(44);
                make.right.equalTo(self.streamingControl.mas_left).mas_offset(-10);
                make.bottom.equalTo(self.streamingControl.mas_bottom);
                make.width.mas_equalTo(VEL_DEVICE_WIDTH - 44);
            } else {
                make.top.equalTo(self.navigationBar.mas_bottom);
                make.right.equalTo(self.streamingControl.mas_left).mas_offset(-10);
                make.bottom.equalTo(self.streamingControl.mas_bottom);
                if (@available(iOS 11.0, *)) {
                    make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).mas_offset(10);
                } else {
                    make.left.equalTo(self.view).mas_offset(10);
                }
            }
        }];
    }
    self.streamingControl.hidden = NO;
    [self.rotateViewModel setTitle:isLandSpace ? LocalizedStringFromBundle(@"medialive_portrait", @"MediaLive") : LocalizedStringFromBundle(@"medialive_landscape", @"MediaLive")];
    [self.rotateViewModel updateUI];
}

- (VELSettingsTableView *)pushSettingView {
    if (!_pushSettingView) {
        _pushSettingView = [[VELSettingsTableView alloc] init];
        _pushSettingView.backgroundColor = UIColor.clearColor;
    }
    [self setupSettingModels];
    return _pushSettingView;
}

- (void)setupSettingModels {
    VOLogD(VOMediaLive, @"captureType: %ld", self.config.captureType);
    NSArray *models = nil;
    BOOL needResetModel = NO;
    if (self.config.enableAudioOnly) {
        self.recordViewModel.showSanpShot = NO;
        models = @[self.recordViewModel, self.aCfgViewModel];
    } else {
        self.recordViewModel.showSanpShot = YES;
        NSMutableArray *settingModels = [NSMutableArray arrayWithCapacity:20];
        if (self.config.captureType == VELSettingCaptureTypeScreen) {
            [settingModels addObjectsFromArray:@[self.aCfgViewModel, self.vCfgViewModel]];
        } else {
            [settingModels addObjectsFromArray:@[self.recordViewModel, self.aCfgViewModel, self.vCfgViewModel,self.mirrorViewModel, self.seiViewModel]];
        }
        models = settingModels;
    }
    if (_pushSettingView.models.count != models.count || needResetModel) {
        _pushSettingView.models = models;
    }
}


- (VELSettingsRecordViewModel *)recordViewModel {
    if (!_recordViewModel) {
        _recordViewModel = [[VELSettingsRecordViewModel alloc] init];
        _recordViewModel.showVisualEffect = YES;
        _recordViewModel.margin = UIEdgeInsetsMake(0, 0, 6, 8);
        _recordViewModel.backgroundColor = UIColor.clearColor;
        _recordViewModel.containerBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _recordViewModel.containerSelectBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        if (self.config.enableAudioOnly) {
            _recordViewModel.size = CGSizeMake(VELAutomaticDimension, 55);
        }
        __weak __typeof__(self)weakSelf = self;
        [_recordViewModel setRecordActionBlock:^(VELSettingsRecordViewModel * _Nonnull model, VELSettingsRecordState state, int width, int height) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (state == VELSettingsRecordStateStart) {
                [self startRecord:width height:height];
            } else if (state == VELSettingsRecordStateStop) {
                [self stopRecord];
            } else if (state == VELSettingsRecordStateSnapshot) {
                [self snapShot];
            }
        }];
    }
    return _recordViewModel;
}
- (VELSettingsMirrorViewModel *)mirrorViewModel {
    if (!_mirrorViewModel) {
        _mirrorViewModel = [[VELSettingsMirrorViewModel alloc] init];
        _mirrorViewModel.showVisualEffect = YES;
        _mirrorViewModel.margin = UIEdgeInsetsMake(0, 0, 6, 8);
        _mirrorViewModel.backgroundColor = UIColor.clearColor;
        _mirrorViewModel.containerBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _mirrorViewModel.containerSelectBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        __weak __typeof__(self)weakSelf = self;
        [_mirrorViewModel setMirrorActionBlock:^(VELSettingsMirrorViewModel * _Nonnull model, VELSettingsMirrorType mirrorType, BOOL isOn) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (mirrorType == VELSettingsMirrorTypeCapture) {
                [self setCaptureMirror:isOn];
            } else if (mirrorType == VELSettingsMirrorTypePreview) {
                [self setPreviewMirror:isOn];
            } else if (mirrorType == VELSettingsMirrorTypeStream) {
                [self setStreamMirror:isOn];
            }
        }];
    }
    return _mirrorViewModel;
}

- (VELSettingPushVCfgViewModel *)vCfgViewModel {
    if (!_vCfgViewModel) {
        _vCfgViewModel = [[VELSettingPushVCfgViewModel alloc] init];
        _vCfgViewModel.showVisualEffect = YES;
        _vCfgViewModel.margin = UIEdgeInsetsMake(0, 0, 6, 8);
        _vCfgViewModel.backgroundColor = UIColor.clearColor;
        _vCfgViewModel.containerBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _vCfgViewModel.containerSelectBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _vCfgViewModel.size = CGSizeMake(VELAutomaticDimension, VELAutomaticDimension);
        __weak __typeof__(self)weakSelf = self;
        [_vCfgViewModel setVideoResolutionChanged:^(VELSettingResolutionType resolutionType) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self updateVideoEncodeResolution:resolutionType];
        }];
        [_vCfgViewModel setVideoFpsChanged:^(int fps) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self updateVideoEncodeFps:fps];
        }];
    }
    return _vCfgViewModel;
}

- (VELSettingPushACfgViewModel *)aCfgViewModel {
    if (!_aCfgViewModel) {
        _aCfgViewModel = [[VELSettingPushACfgViewModel alloc] init];
        _aCfgViewModel.showVisualEffect = YES;
        _aCfgViewModel.margin = UIEdgeInsetsMake(0, 0, 6, 8);
        _aCfgViewModel.backgroundColor = UIColor.clearColor;
        _aCfgViewModel.containerBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _aCfgViewModel.containerSelectBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _aCfgViewModel.size = CGSizeMake(VELAutomaticDimension, VELAutomaticDimension);
        __weak __typeof__(self)weakSelf = self;
        [_aCfgViewModel setEnableAudioEchoBlock:^(VELSettingPushACfgViewModel * _Nonnull m, BOOL enable) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self setEnableAudioHardwareEcho:enable];
        }];
        [_aCfgViewModel setAudioLoudnessValueChangedBlock:^(VELSettingPushACfgViewModel * _Nonnull m, float value) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self setAudioLoudness:value];
        }];
    }
    _aCfgViewModel.isSupportAudioEcho = self.isSupportAudioHardwareEcho;
    _aCfgViewModel.audioLoudness = self.getCurrentAudioLoudness;
    _aCfgViewModel.enableAudioEcho = self.isHardwareEchoEnable;
    return _aCfgViewModel;
}

- (VELSettingsInputActionViewModel *)seiViewModel {
    if (!_seiViewModel) {
        _seiViewModel = [[VELSettingsInputActionViewModel alloc] init];
        _seiViewModel.showVisualEffect = YES;
        _seiViewModel.margin = UIEdgeInsetsMake(0, 0, 6, 8);
        _seiViewModel.backgroundColor = UIColor.clearColor;
        _seiViewModel.title = LocalizedStringFromBundle(@"medialive_custom_sei", @"MediaLive");
        _seiViewModel.btnTitle = LocalizedStringFromBundle(@"medialive_sei_send", @"MediaLive");
        _seiViewModel.selectBtnTitle = LocalizedStringFromBundle(@"medialive_sei_puase", @"MediaLive");
        _seiViewModel.placeHolder = LocalizedStringFromBundle(@"medialive_sei_placeholder", @"MediaLive");
        _seiViewModel.containerBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _seiViewModel.containerSelectBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        __weak __typeof__(self)weakSelf = self;
        [_seiViewModel setSendBtnActionBlock:^(VELSettingsInputActionViewModel * _Nonnull model, BOOL send) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (send) {
                [self sendSEIWithKey:@"test_sei" value:model.text];
                NSString *tip = [NSString stringWithFormat:@"Key: %@\nValue:%@", @"test_sei", model.text];
                [VELUIToast showText:LocalizedStringFromBundle(@"medialive_sei_toast", @"MediaLive") detailText:tip];
            } else {
                [self stopSendSEIForKey:@"test_sei"];
            }
        }];
    }
    return _seiViewModel;
}

- (VELSettingsCollectionView *)streamingControl {
    if (!_streamingControl) {
        _streamingControl = [[VELSettingsCollectionView alloc] init];
        _streamingControl.backgroundColor = [UIColor clearColor];
        _streamingControl.scrollDirection = UICollectionViewScrollDirectionVertical;
        _streamingControl.itemMargin = 0;
        _streamingControl.allowSelection = YES;
        _streamingControl.layoutMode = VELCollectionViewLayoutModeLeft;
        _streamingControl.hidden = YES;
        _streamingControl.models = [self getStreamingControlModels];
        __weak __typeof__(self)weakSelf = self;
        [_streamingControl setSelectedItemBlock:^(__kindof VELSettingsBaseViewModel * _Nonnull model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (model != self.currentPopObj) {
                [self hideAllPopView];
            }
        }];
    }
    return _streamingControl;
}


- (NSArray <VELSettingsButtonViewModel *> *)getStreamingControlModels {
    NSMutableArray <VELSettingsButtonViewModel *> *models = [NSMutableArray arrayWithCapacity:6];
    [models addObject:self.micViewModel];
    if (self.config.captureType == VELSettingCaptureTypeInner) {
        [models addObject:self.cameraViewModel];
        [models addObject:self.torchViewModel];
    }
    
    if (self.isSupportEffect) {
        [models addObject:self.effectViewModel];
    }
    [models addObject:self.streamSettingViewModel];
    [models addObject:self.infoViewModel];
    return models;
}

@end
