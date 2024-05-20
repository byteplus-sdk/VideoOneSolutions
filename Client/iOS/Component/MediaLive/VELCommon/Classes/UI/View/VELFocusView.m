// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELFocusView.h"
#import "UIView+VELAdd.h"
#import "UIColor+VELAdd.h"
#import "VELCommonDefine.h"
@interface VELFocusView ()
@property(nonatomic, strong) UIImageView *focusRect;
@property(nonatomic, strong) UISlider *focusSun;
@property(nonatomic, strong) UISlider *focusWb;
@end
@implementation VELFocusView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}
- (CGFloat)sunValue {
    return self.focusSun.value;
}
- (CGFloat)wbValue {
    return self.focusWb.value;
}
- (void)updateSunValue:(CGFloat)value {
    self.focusSun.value = value;
    [self focusSunValueChanged:self.focusSun];
}

- (void)updateWBValue:(CGFloat)value {
    self.focusWb.value = value;
    [self focusWbValueChanged:self.focusWb];
}
- (void)focusSunValueChanged:(UISlider *)slider {
    if (self.sunValueChanged) {
        self.sunValueChanged(slider.value);
    }
}
- (void)focusWbValueChanged:(UISlider *)slider {
    if (self.wbValueChanged) {
        self.wbValueChanged(slider.value);
    }
}
- (void)setupView {
    [self addSubview:self.focusRect];
    [self addSubview:self.focusWb];
    [self addSubview:self.focusSun];
}

- (void)setShowWBView:(BOOL)showWBView {
    _showWBView = showWBView;
    self.focusWb.hidden = !showWBView;
}

- (void)setShowSunView:(BOOL)showSunView {
    _showSunView = showSunView;
    self.focusSun.hidden = !showSunView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat left = 20;
    CGFloat top = 20;
    CGFloat rectWith = (self.vel_width - left * 2);
    CGFloat rectHeight = (self.vel_height - top * 2);
    self.focusRect.frame = CGRectMake(left, top, rectWith, rectHeight);
    self.focusWb.frame = CGRectMake(10, top + rectHeight + 10, self.vel_width - 20, 10);
    self.focusSun.frame = CGRectMake(0, 0, self.vel_width - 20, 10);
    self.focusSun.center = CGPointMake(self.vel_width - 5, self.vel_height * 0.5);
    [self.focusSun setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
}

- (UIImageView *)focusRect {
    if (!_focusRect) {
        _focusRect = [[UIImageView alloc] initWithImage:VELUIImageMake(@"ic_focus_rect")];
    }
    return _focusRect;
}

- (UISlider *)focusSun {
    if (!_focusSun) {
        _focusSun = [[UISlider alloc] initWithFrame:CGRectZero];
        _focusSun.maximumValue = 1;
        _focusSun.minimumValue = 0;
        _focusSun.value = 0.5;
        UIImage *image = [UIImage vel_imageWithColor:VELColorWithHexString(@"0xFFC721") size:CGSizeMake(20, 2)];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsZero];
        [_focusSun setMaximumTrackImage:image forState:(UIControlStateNormal)];
        [_focusSun setMinimumTrackImage:image forState:(UIControlStateNormal)];
        [_focusSun setThumbImage:VELUIImageMake(@"ic_focus_sun") forState:(UIControlStateNormal)];
        [_focusSun addTarget:self action:@selector(focusSunValueChanged:) forControlEvents:(UIControlEventValueChanged)];
    }
    return _focusSun;
}
- (UISlider *)focusWb {
    if (!_focusWb) {
        _focusWb = [[UISlider alloc] initWithFrame:CGRectZero];
        _focusWb.maximumValue = 1;
        _focusWb.minimumValue = 0;
        _focusWb.value = 0.5;
        UIImage *image = [UIImage vel_imageWithColor:VELColorWithHexString(@"0xFFC721") size:CGSizeMake(20, 2)];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsZero];
        [_focusWb setMaximumTrackImage:image forState:(UIControlStateNormal)];
        [_focusWb setMinimumTrackImage:image forState:(UIControlStateNormal)];
        [_focusWb setThumbImage:VELUIImageMake(@"ic_focus_wb") forState:(UIControlStateNormal)];
        [_focusWb addTarget:self action:@selector(focusWbValueChanged:) forControlEvents:(UIControlEventValueChanged)];
    }
    return _focusWb;
}
@end
