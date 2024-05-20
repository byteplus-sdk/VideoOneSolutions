// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushUIViewController+Private.h"
static CGFloat cameraCurrentScale = 0;
static CGFloat cameraMaxScale = 0;
static CGFloat cameraMinScale = 0;

static CGFloat cameraCurrentWBValue = 0;
static CGFloat cameraMaxWBValue = 0;
static CGFloat cameraMinWBValue = 0;

static CGFloat cameraCurreExpValue = 0;
static CGFloat cameraMaxExpValue = 0;
static CGFloat cameraMinExpValue = 0;


@implementation VELPushUIViewController (Device)
- (void)showFocusViewAt:(CGPoint)center {
    if (![self shouldShowFocusView]) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideFocusView) object:nil];
    [self.focusView.layer removeAllAnimations];
    
    __weak __typeof__(self)weakSelf = self;
    if (self.focusView == nil) {
        self.focusView = [[VELFocusView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        self.focusView.showSunView = [self isSupportExposure];
        self.focusView.showWBView = [self isSupportWhiteBalance];
        
    }
    if (self.isSupportExposure) {
        cameraMaxExpValue = self.getSupportedMaxExposure;
        cameraMinExpValue = self.getSupportedMinExposure;
        cameraCurreExpValue = self.getCurrentExposure;
        
        CGFloat sunValue = [self getFocusViewSunValue];
        [self.focusView updateSunValue:sunValue];
        [self.focusView setSunValueChanged:^(CGFloat sunValue) {
            __strong __typeof__(weakSelf)self = weakSelf;
            CGFloat exposure = cameraMinExpValue + (cameraMaxExpValue - cameraMinExpValue) * sunValue;
            [self setExposure:exposure];
        }];
    }
    if (self.isSupportWhiteBalance) {
        cameraMaxWBValue = self.getSupportedMaxWhiteBalance;
        cameraMinWBValue = self.getSupportedMinWhiteBalance;
        cameraCurrentWBValue = [self getCurrentWhiteBalance];
        
//        CGFloat currentWB = self.getCurrentWhiteBalance;
        CGFloat wbValue = [self getFocusViewWBValue];
        [self.focusView updateWBValue:wbValue];
        [self.focusView setWbValueChanged:^(CGFloat wbValue) {
            __strong __typeof__(weakSelf)self = weakSelf;
            CGFloat whiteBalance = cameraMinWBValue + (cameraMaxWBValue - cameraMinWBValue) * wbValue;
            [self setWhiteBalance:whiteBalance];
        }];
    }
    
    self.focusView.alpha = 1;
    self.focusView.center = center;
    if (self.focusView.superview != self.controlContainerView) {
        [self.focusView removeFromSuperview];
        [self.controlContainerView addSubview:self.focusView];
    }
}

- (CGFloat)getFocusViewSunValue {
    return (cameraCurreExpValue - cameraMinExpValue) / (cameraMaxExpValue - cameraMinExpValue);
}

- (CGFloat)getFocusViewWBValue {
    return (cameraCurrentWBValue - cameraMinWBValue) / (cameraMaxWBValue - cameraMinWBValue);
}

- (BOOL)shouldShowFocusView {
    return (self.isAutoFocusSupported || self.isSupportExposure || self.isSupportWhiteBalance) && self.currentPopObj == nil;
}

- (void)hideFocusView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideFocusView) object:nil];
    [self performSelector:@selector(_hideFocusView) withObject:nil afterDelay:1.5];
}

- (void)_hideFocusView {
    [UIView animateWithDuration:0.3 animations:^{
        self.focusView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.focusView removeFromSuperview];
        }
        self.focusView.alpha = 1;
    }];
}

- (void)showScaleLabel:(CGFloat)scale {
    [self.scaleLabel.layer removeAllAnimations];
    if (self.scaleLabel == nil) {
        self.scaleLabel = [[VELUILabel alloc] init];
        self.scaleLabel.backgroundColor = UIColor.clearColor;
        self.scaleLabel.textColor = VELColorWithHexString(@"0xFFC721");
        self.scaleLabel.font = [UIFont systemFontOfSize:25];
    }
    if (self.scaleLabel.superview != self.controlContainerView) {
        [self.scaleLabel removeFromSuperview];
        [self.controlContainerView addSubview:self.scaleLabel];
        [self.scaleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.controlContainerView);
        }];
    }
    self.scaleLabel.text = [NSString stringWithFormat:@"%.1fx", scale];
    self.scaleLabel.alpha = 1;
}

- (void)hideScaleLabel {
    [UIView animateWithDuration:0.3 animations:^{
        self.scaleLabel.alpha = 0;
    } completion:^(BOOL finished) {
        self.scaleLabel.alpha = 1;
        if (finished) {
            [self.scaleLabel removeFromSuperview];
        }
    }];
}
- (void)gestureManagerDidBegin:(VELGestureManager *)manager onGesture:(VELGestureType)gesture {
    if (gesture == VELGestureTypeScale) {
        if (self.isSupportCameraZoomRatio) {
            cameraMaxScale = [self getCameraZoomMaxRatio];
            cameraMinScale = [self getCameraZoomMinRatio];
            cameraCurrentScale = [self getCurrentCameraZoomRatio];
        }
        [self hideFocusView];
    } else if (gesture == VELGestureTypePan) {
        if (self.focusView.superview == nil) {
            return;
        }
        if (!self.isSupportExposure && !self.isSupportWhiteBalance) {
            return;
        }
        [self showFocusViewAt:self.focusView.center];
    }
}
- (void)gestureManagerDidEnd:(VELGestureManager *)manager onGesture:(VELGestureType)gesture {
    if (gesture == VELGestureTypeScale) {
        [self hideScaleLabel];
    } else if (gesture == VELGestureTypeTap) {
        [self hideFocusView];
    } else if (gesture == VELGestureTypePan) {
        [self hideFocusView];
    } else if (gesture == VELGestureTypeScale) {
        [self hideScaleLabel];
    }
}

- (void)gestureManager:(VELGestureManager *)manager onTouchEvent:(VELTouchEvent)event x:(CGFloat)x y:(CGFloat)y force:(CGFloat)force majorRadius:(CGFloat)majorRadius pointerId:(NSInteger)pointerId pointerCount:(NSInteger)pointerCount {
    [self onTouchEvent:event x:x y:y force:force majorRadius:majorRadius pointerId:pointerId pointerCount:pointerCount];
}

- (void)gestureManager:(VELGestureManager *)manager onGesture:(VELGestureType)gesture x:(CGFloat)x y:(CGFloat)y dx:(CGFloat)dx dy:(CGFloat)dy factor:(CGFloat)factor {
    [self onGesture:gesture x:x y:y dx:dx dy:dy factor:factor];
    if (gesture == VELGestureTypeScale) {
        if (self.isSupportCameraZoomRatio) {
            cameraCurrentScale *= x;
            cameraCurrentScale = MAX(MIN(cameraMaxScale, cameraCurrentScale), cameraMinScale);
            [self showScaleLabel:cameraCurrentScale];
            [self setCameraZoomRatio:cameraCurrentScale];
        }
    } else if (gesture == VELGestureTypeTap) {
        if (self.shouldShowFocusView) {
            CGPoint location = CGPointMake(x, y);
            self.focusView.center = location;
            CGPoint cameraLocation = CGPointMake(location.x / self.controlContainerView.vel_width, location.y / self.controlContainerView.vel_height);
            [self showFocusViewAt:location];
            [self setCameraFocusPosition:cameraLocation];
        }
    } else if (gesture == VELGestureTypePan) {
        if (self.focusView.superview == nil) {
            return;
        }
        
        if (ABS(dx) > 0 && self.isSupportWhiteBalance) {
            cameraCurrentWBValue = MAX(MIN(cameraMaxWBValue, cameraCurrentWBValue + dx * 10), cameraMinWBValue);
            [self.focusView updateWBValue:[self getFocusViewWBValue]];
        }
        
        if (ABS(dy) > 0 && self.isSupportExposure) {
            cameraCurreExpValue = MAX(MIN(cameraMaxExpValue, cameraCurreExpValue - dy * 0.01), cameraMinExpValue);
            [self.focusView updateSunValue:[self getFocusViewSunValue]];
        }
    }
}

- (void)setupDeviceGesture {
    BOOL shouldEnableGesture = self.config.captureType == VELSettingCaptureTypeInner;
    if (self.controlGesture == nil && shouldEnableGesture) {
        self.controlGesture = [[VELGestureManager alloc] init];
        [self.controlGesture attachView:self.controlContainerView];
        self.controlGesture.delegate = self;
    }
}

- (BOOL)gestureManager:(VELGestureManager *)manager shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == self.controlContainerView) {
        if (self.currentPopObj != nil) {
            [self hideAllPopView];
            return NO;
        }
        return YES;
    }
    return NO;
}
- (void)setScaleLabel:(VELUILabel *)scaleLabel {
    _scaleLabel = scaleLabel;
}
- (VELUILabel *)scaleLabel {
    return _scaleLabel;
}
- (void)setFocusView:(VELFocusView *)focusView {
    _focusView = focusView;
}
- (VELFocusView *)focusView {
    return _focusView;
}
@end

@implementation VELPushUIViewController (Exposure)
- (CGFloat)getSupportedMaxExposure { return 0; };
- (CGFloat)getSupportedMinExposure { return 0; };
- (BOOL)isSupportExposure {return NO;};
- (CGFloat)getCurrentExposure { return 0; };
- (void)setExposure:(CGFloat)exposure {};
@end

@implementation VELPushUIViewController (WhiteBalance)
- (CGFloat)getSupportedMaxWhiteBalance {return 0;};
- (CGFloat)getSupportedMinWhiteBalance {return 0;};
- (CGFloat)getCurrentWhiteBalance {return 0;};
- (BOOL)isSupportWhiteBalance {return NO;};
- (void)setWhiteBalance:(CGFloat)exposure {};
@end

@implementation VELPushUIViewController (Ratio)
- (CGFloat)getCurrentCameraZoomRatio {return 0;};
- (CGFloat)getCameraZoomMaxRatio {return 0;};
- (CGFloat)getCameraZoomMinRatio {return 0;};
- (void)setCameraZoomRatio:(CGFloat)ratio {};
- (BOOL)isSupportCameraZoomRatio {return NO;};
@end

@implementation VELPushUIViewController (Focus)
- (BOOL)isAutoFocusSupported {return NO;};
- (void)enableCameraAutoFocus:(BOOL)enable{};
- (void)setCameraFocusPosition:(CGPoint)position{};
@end

@implementation VELPushUIViewController (Gesture)
- (void)onTouchEvent:(VELTouchEvent)event x:(CGFloat)x y:(CGFloat)y force:(CGFloat)force majorRadius:(CGFloat)majorRadius pointerId:(NSInteger)pointerId pointerCount:(NSInteger)pointerCount {}
- (void)onGesture:(VELGestureType)gesture x:(CGFloat)x y:(CGFloat)y dx:(CGFloat)dx dy:(CGFloat)dy factor:(CGFloat)factor {}
@end
