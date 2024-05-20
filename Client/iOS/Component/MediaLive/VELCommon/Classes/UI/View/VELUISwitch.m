// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELUISwitch.h"
#import "VELCommonDefine.h"
#import "UIControl+VELAdd.h"
#import <AVFoundation/AVFoundation.h>
@interface VELUISwitch () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIImpactFeedbackGenerator *feedbackGenerator API_AVAILABLE(ios(10.0));
@end

@implementation VELUISwitch
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        _offTintColor = [UIColor whiteColor];
        _offThumbTintColor = VELColorWithHexString(@"#E0DEDE");
        _offBorderColor = VELColorWithHexString(@"#E0DEDE");
        _onTintColor = [UIColor whiteColor];
        _onThumbTintColor = VELColorWithHexString(@"#35C75A");
        _onBorderColor = VELColorWithHexString(@"#35C75A");
        _borderWidth = 2;
        if (@available(iOS 13.0, *)) {
            [[AVAudioSession sharedInstance] setAllowHapticsAndSystemSoundsDuringRecording:YES error:nil];
        }
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        if (@available(iOS 10.0, *)) {
            if (!self.feedbackGenerator) {
                self.feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleLight];
                [self.feedbackGenerator prepare];
            }
        }
        self.preventsTouchEvent = YES;
    }
    return self;
}

- (void)setOn:(BOOL)on {
    [self setOn:on animated:YES];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    _on = on;
    [self setNeedsDisplay];
}

- (void)setOnTintColor:(UIColor *)onTintColor {
    _onTintColor = onTintColor;
    [self setNeedsDisplay];
}

- (void)setOnThumbTintColor:(UIColor *)onThumbTintColor {
    _onThumbTintColor = onThumbTintColor;
    [self setNeedsDisplay];
}

- (void)setOnBorderColor:(UIColor *)onBorderColor {
    _onBorderColor = onBorderColor;
    [self setNeedsDisplay];
}

- (void)setOffTintColor:(UIColor *)offTintColor {
    _offTintColor = offTintColor;
    [self setNeedsDisplay];
}

- (void)setOffThumbTintColor:(UIColor *)offThumbTintColor {
    _offThumbTintColor = offThumbTintColor;
    [self setNeedsDisplay];
}

- (void)setOffBorderColor:(UIColor *)offBorderColor {
    _offBorderColor = offBorderColor;
    [self setNeedsDisplay];
}

- (void)sendFeedBack {
    if (@available(iOS 10.0, *)) {
        [self.feedbackGenerator impactOccurred];
    }
}

- (void)tapGestureAction:(UIGestureRecognizer *)tapGesture {
    if (tapGesture.view == self) {
        [self sendFeedBack];
        [self setOn:!self.isOn animated:YES];
        [self sendActionsForControlEvents:(UIControlEventValueChanged)];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint postion = [touch locationInView:self.superview];
    CGRect outSetRect = CGRectInset(self.frame, -3, -3);
    return CGRectContainsPoint(outSetRect, postion);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(27, 16);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [[UIColor clearColor] setFill];
    [[UIBezierPath bezierPathWithRect:rect] fill];
    
    
    CGFloat height = CGRectGetHeight(rect);
    CGFloat width = CGRectGetWidth(rect);
    CGFloat radius = height * 0.5;
    
    UIColor *borderColor = self.isOn ? self.onBorderColor : self.offBorderColor;
    UIColor *tintColor = self.isOn ? self.onTintColor : self.offTintColor;
    UIColor *thumbColor = self.isOn ? self.onThumbTintColor : self.offThumbTintColor;
    
    CGFloat thumbMargin = 2;
    CGFloat thumbWidth = height - thumbMargin * 2 - self.borderWidth * 2;
//    CGSize thumbSize = CGSizeMake(thumbWidth, thumbWidth);
    CGFloat thumbRadius = thumbWidth * 0.5;
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    [tintColor setFill];
    [bgPath fill];
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, self.borderWidth * 0.5, self.borderWidth * 0.5)
                                                          cornerRadius:radius];
    [borderPath setLineWidth:self.borderWidth];
    [borderColor setStroke];
    [borderPath stroke];
    CGFloat thumbCenterX = self.isOn ? (width - self.borderWidth - thumbMargin - thumbRadius) : thumbMargin + self.borderWidth + thumbRadius;
    CGFloat thumbCenterY = thumbMargin + self.borderWidth + thumbRadius;
    
    UIBezierPath *thumbPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(thumbCenterX, thumbCenterY)
                                                             radius:thumbRadius
                                                         startAngle:0
                                                           endAngle:M_PI * 2
                                                          clockwise:YES];
    [thumbPath closePath];
    [thumbColor setFill];
    [thumbPath fill];
}
@end

