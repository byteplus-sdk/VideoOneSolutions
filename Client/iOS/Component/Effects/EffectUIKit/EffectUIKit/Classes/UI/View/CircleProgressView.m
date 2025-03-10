// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "CircleProgressView.h"

@interface CircleProgressView() {
    CALayer *_animationLayer;
    Boolean _animating;
}

@end

@implementation CircleProgressView


- (instancetype)initWithColor:(UIColor *)tintColor size:(CGFloat)size{
    if (self = [super init]) {
        _tintColor = tintColor;
        _size = size;
    }
    self.userInteractionEnabled = NO;
    self.hidden = YES;
    
    _animationLayer = [[CALayer alloc] init];
    [self.layer addSublayer:_animationLayer];

    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    return self;
}


- (void)setupAnimation {
    _animationLayer.sublayers = nil;
    [self setupAnimationInLayer:_animationLayer withSize:CGSizeMake(_size, _size) tintColor:_tintColor];
}

- (void)startAnimating {
    if (!_animationLayer.sublayers) {
        [self setupAnimation];
    }
    self.hidden = NO;
    _animationLayer.speed = 1.0f;
    _animating = YES;
}

- (void)stopAnimating {
    _animationLayer.speed = 0.0f;
    _animating = NO;
    self.hidden = YES;
}


- (void)setupAnimationInLayer:(CALayer *)layer withSize:(CGSize)size tintColor:(UIColor *)tintColor {
    CGFloat duration = 0.75f;
    
    //    Scale animation
    CAKeyframeAnimation *scaleAnimation = [self createKeyframeAnimationWithKeyPath:@"transform.scale"];
    
    scaleAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.6f, 0.6f, 1.0f)],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)]];
    scaleAnimation.keyTimes = @[@0.0f, @0.5f, @1.0f];
    
    // Rotate animation
    CAKeyframeAnimation *rotateAnimation = [self createKeyframeAnimationWithKeyPath:@"transform.rotation.z"];
    
    rotateAnimation.values = @[@0, @M_PI, @(2 * M_PI)];
    rotateAnimation.keyTimes = scaleAnimation.keyTimes;
    
    // Animation
    CAAnimationGroup *animation = [self createAnimationGroup];;
    
    animation.animations = @[rotateAnimation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = duration;
    animation.repeatCount = HUGE_VALF;
    
    // Draw ball clip
    CAShapeLayer *circle = [CAShapeLayer layer];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(size.width / 2, size.height / 2) radius:size.width / 2 startAngle:1.5 * M_PI endAngle:M_PI clockwise:true];
    
    circle.path = circlePath.CGPath;
    circle.lineWidth = 2;
    circle.fillColor = nil;
    circle.strokeColor = tintColor.CGColor;
    
    circle.frame = CGRectMake((layer.bounds.size.width - size.width) / 2, (layer.bounds.size.height - size.height) / 2, size.width, size.height);
    [circle addAnimation:animation forKey:@"animation"];
    [layer addSublayer:circle];
}

- (CABasicAnimation *)createBasicAnimationWithKeyPath:(NSString *)keyPath {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.removedOnCompletion = NO;
    return animation;
}

- (CAKeyframeAnimation *)createKeyframeAnimationWithKeyPath:(NSString *)keyPath {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    animation.removedOnCompletion = NO;
    return animation;
}

- (CAAnimationGroup *)createAnimationGroup {
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.removedOnCompletion = NO;
    return animationGroup;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _animationLayer.frame = self.bounds;

    BOOL animating = _animating;

    if (animating)
        [self stopAnimating];

    [self setupAnimation];

    if (animating)
        [self startAnimating];
}

@end
