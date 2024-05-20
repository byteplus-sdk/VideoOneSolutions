// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushUIViewController+Private.h"
#import <ToolKit/Localizator.h>

@implementation VELPushUIViewController (Private)

- (void)hideAllPopView {
    [self hideInfoView];
    [self hideStreamSettings];
    [self hidePreviewSettings];
}

- (void)checkAndRotation {
    if (UIDeviceOrientationIsLandscape([VELDeviceRotateHelper currentDeviceOrientation])) {
        [VELDeviceRotateHelper rotateToDeviceOrientation:(UIDeviceOrientationPortrait)];
        [self rotatedTo:(UIInterfaceOrientationPortrait)];
    } else {
        [VELDeviceRotateHelper rotateToDeviceOrientation:(UIDeviceOrientationLandscapeLeft)];
        [self rotatedTo:(UIInterfaceOrientationLandscapeRight)];
    }
    [self showRotateVisualView];
}

- (void)attemptToCurrentDeviceOrientation {
    if (UIDeviceOrientationIsLandscape([VELDeviceRotateHelper currentDeviceOrientation])) {
        [VELDeviceRotateHelper rotateToDeviceOrientation:((UIDeviceOrientation)UIInterfaceOrientationLandscapeRight)];
        [self rotatedTo:(UIInterfaceOrientationLandscapeRight)];
    } else {
        [VELDeviceRotateHelper rotateToDeviceOrientation:(UIDeviceOrientationPortrait)];
        [self rotatedTo:(UIInterfaceOrientation)(UIDeviceOrientationPortrait)];
    }
    [self showRotateVisualView];
}

- (void)showRotateVisualView {
    if (self.rotateVisualView.isHidden) {
        self.rotateVisualView.hidden = NO;
        self.rotateVisualView.alpha = 1;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideRotateVisualView) withObject:nil afterDelay:0.8];
}

- (void)hideRotateVisualView {
    [UIView animateWithDuration:0.5 animations:^{
        self.rotateVisualView.alpha = 0;
    } completion:^(BOOL finished) {
        self.rotateVisualView.hidden = YES;
    }];
}

- (VELSettingsButtonViewModel *)buttonModelWithTitle:(NSString *)title
                                               image:(UIImage *)image
                                         actionBlock:(void (^)(VELSettingsButtonViewModel *model, NSInteger index))actionBlock {
    return [self buttonModelWithTitle:title image:image selectImg:image actionBlock:actionBlock];
}

- (VELSettingsButtonViewModel *)buttonModelWithTitle:(NSString *)title
                                               image:(UIImage *)image
                                           selectImg:(UIImage *)selectImg
                                         actionBlock:(void (^)(VELSettingsButtonViewModel *model, NSInteger index))actionBlock {
    VELSettingsButtonViewModel *model = [VELSettingsButtonViewModel modelWithTitle:title];
    model.image = image;
    model.selectImage = selectImg ?: image;
    model.imagePosition = VELImagePositionTop;
    model.imageSize = CGSizeMake(40, 40);
    model.useCellSelect = NO;
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
    NSStringDrawingUsesFontLeading;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:12]};
    CGSize textSize = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 55)
                                          options:opts
                                       attributes:attributes
                                          context:nil].size;
    model.size = CGSizeMake(textSize.width < 56 ? 56 : textSize.width + 5, 55);
    model.spacingBetweenImageAndTitle = 0;
    model.titleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor;
    model.titleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    model.selectTitleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor;
    model.selectTitleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    model.backgroundColor = UIColor.clearColor;
    model.selectedBlock = actionBlock;
    model.containerBackgroundColor = UIColor.clearColor;
    model.containerSelectBackgroundColor = UIColor.clearColor;
    return model;
}

- (VELSettingsButtonViewModel *)cameraViewModel {
    if (!_cameraViewModel) {
        __weak __typeof__(self)weakSelf = self;
        _cameraViewModel = [self buttonModelWithTitle:LocalizedStringFromBundle(@"medialive_camera_flip", @"MediaLive")
                                                image:VELUIImageMake(@"ic_push_switch_camera")
                                          actionBlock:^(VELSettingsButtonViewModel *model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self switchCamera];
            if (self.torchViewModel.isSelected) {
                self.torchViewModel.isSelected = NO;
                [self.torchViewModel updateUI];
            }
        }];
    }
    return _cameraViewModel;
}

- (VELSettingsButtonViewModel *)torchViewModel {
    if (!_torchViewModel) {
        __weak __typeof__(self)weakSelf = self;
        VELSettingsButtonViewModel *torchModel = [self buttonModelWithTitle:LocalizedStringFromBundle(@"medialive_flash_light", @"MediaLive")
                                                                      image:VELUIImageMake(@"ic_push_torch_off")
                                                                  selectImg:VELUIImageMake(@"ic_push_torch")
                                                                actionBlock:^(VELSettingsButtonViewModel *model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (![self isSupportTorch]) {
                [VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_flashlight", @"MediaLive")];
            } else {
                model.isSelected = !model.isSelected;
                [self torch:model.isSelected];
                [model updateUI];
            }
        }];
        _torchViewModel = torchModel;
    }
    return _torchViewModel;
}

- (VELSettingsButtonViewModel *)effectViewModel {
    if (!_effectViewModel) {
        __weak __typeof__(self)weakSelf = self;
        _effectViewModel = [self buttonModelWithTitle:LocalizedStringFromBundle(@"medialive_effect", @"MediaLive")
                                                image:VELUIImageMake(@"ic_push_beauty")
                                          actionBlock:^(VELSettingsButtonViewModel *model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self showEffect];
        }];
    }
    return _effectViewModel;
}

- (VELSettingsButtonViewModel *)rotateViewModel {
    if (!_rotateViewModel) {
        __weak __typeof__(self)weakSelf = self;
        _rotateViewModel = [self buttonModelWithTitle:LocalizedStringFromBundle(@"medialive_landscape", @"MediaLive")
                                                image:VELUIImageMake(@"ic_push_rotate")
                                          actionBlock:^(VELSettingsButtonViewModel *model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self checkAndRotation];
        }];
    }
    return _rotateViewModel;
}

- (VELSettingsButtonViewModel *)micViewModel {
    if (!_micViewModel) {
        __weak __typeof__(self)weakSelf = self;
        _micViewModel = [self buttonModelWithTitle:LocalizedStringFromBundle(@"medialive_microphone", @"MediaLive")
                                             image:VELUIImageMake(@"ic_push_mic") selectImg:VELUIImageMake(@"ic_push_mic_off")
                                       actionBlock:^(VELSettingsButtonViewModel *model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            model.isSelected = !model.isSelected;
            if (!model.isSelected) {
                [self unMuteAudio];
            } else {
                [self muteAudio];
            }
            [model updateUI];
        }];
    }
    return _micViewModel;
}

- (VELSettingsButtonViewModel *)previewSettingViewModel {
    if (!_previewSettingViewModel) {
        __weak __typeof__(self)weakSelf = self;
        _previewSettingViewModel = [self buttonModelWithTitle:LocalizedStringFromBundle(@"medialive_setting", @"MediaLive")
                                                        image:VELUIImageMake(@"ic_push_settings")
                                                  actionBlock:^(VELSettingsButtonViewModel *model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (self.isPreviewSettingsShowing) {
                [self hidePreviewSettings];
            } else {
                [self showPreviewSettings];
            }
        }];
    }
    return _previewSettingViewModel;
}

- (VELSettingsButtonViewModel *)streamSettingViewModel {
    if (!_streamSettingViewModel) {
        __weak __typeof__(self)weakSelf = self;
        _streamSettingViewModel = [self buttonModelWithTitle:LocalizedStringFromBundle(@"medialive_setting", @"MediaLive")
                                                       image:VELUIImageMake(@"ic_push_settings")
                                                 actionBlock:^(VELSettingsButtonViewModel *model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (self.isStreamSettingsShowing) {
                [self hideStreamSettings];
            } else {
                [self showStreamSettings];
            }
        }];
    }
    return _streamSettingViewModel;
}

- (VELSettingsButtonViewModel *)infoViewModel {
    if (!_infoViewModel) {
        __weak __typeof__(self)weakSelf = self;
        _infoViewModel = [self buttonModelWithTitle:LocalizedStringFromBundle(@"medialive_information", @"MediaLive")
                                              image:VELUIImageMake(@"ic_push_info")
                                        actionBlock:^(VELSettingsButtonViewModel *model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (self.isInfoViewShowing) {
                [self hideInfoView];
            } else {
                [self showInfoView];
            }
        }];
    }
    return _infoViewModel;
}
@end

@implementation _VELPushUIPopControlView
- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    UIView *v = [super hitTest:point withEvent:event];
    if (v == self) {
        return nil;
    }
    return v;
}
@end

@implementation _VELPushInfoUIScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *v = [super hitTest:point withEvent:event];
    if (v == self) {
        return nil;
    }
    return v;
}

@end
