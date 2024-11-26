// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveSendLikeComponent.h"
#import <ToolKit/ToolKit.h>
#import <Masonry/Masonry.h>

@interface LiveSendLikeComponent ()

@property (nonatomic, weak) UIView *superView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, copy) NSArray<NSString *> *iconList;

@end

@implementation LiveSendLikeComponent

- (instancetype)initWithView:(UIView *)superView {
    self = [super init];
    if (self) {
        _superView = superView;
        [_superView addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(200);
            make.width.mas_equalTo(100);
            make.bottom.equalTo(_superView).offset(-64.19);
            make.right.equalTo(_superView).offset(0);
        }];
        [_superView setNeedsLayout];
        [_superView layoutIfNeeded];
    }
    return self;
}

#pragma mark - Public Action

- (void)show {
    UIImageView *iconView = [[UIImageView alloc] init];
    NSString *randomIcon = [self getRandomIcon];
    iconView.image = [UIImage imageNamed:randomIcon bundleName:@"LiveRoomUI"];
    [self.contentView addSubview:iconView];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36, 36));
        make.right.mas_equalTo(self.contentView).offset(-16);
        make.bottom.mas_equalTo(self.contentView).offset(16);
    }];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    UIBezierPath *floatPath = [UIBezierPath bezierPath];
    [floatPath moveToPoint:CGPointMake(iconView.center.x, iconView.center.y)];
    CGFloat viewX = iconView.center.x;
    CGFloat viewY = iconView.center.y;
    CGFloat viewWidth = self.contentView.bounds.size.width;
    CGFloat viewHeight = self.contentView.bounds.size.height;
    NSInteger travelDirection = 1 - (2 * (int)arc4random_uniform(2));
    NSInteger m1 = travelDirection > 0 ? viewX + (int)arc4random_uniform(viewWidth - viewX) : viewX - (int)arc4random_uniform(viewX);
    NSInteger n1 = viewY - (viewHeight * 0.3) + travelDirection * (int)arc4random_uniform(10);
    NSInteger m2 = travelDirection > 0 ? viewX + (int)arc4random_uniform(viewWidth - viewX) : viewX - (int)arc4random_uniform(viewX);
    NSInteger n2 = viewY - (viewHeight * 0.6) + travelDirection * (int)arc4random_uniform(10);
    CGPoint controlPoint1 = CGPointMake(m1, n1);
    CGPoint controlPoint2 = CGPointMake(m2, n2);
    NSInteger randomEndX = (int)arc4random_uniform(viewWidth + 1);
    CGPoint endPoint = CGPointMake(randomEndX, 0);
    [floatPath addCurveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyFrameAnimation.path = floatPath.CGPath;
    [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.8 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        NSInteger randomTx = (int)arc4random_uniform(10);
        iconView.transform = CGAffineTransformMakeTranslation(travelDirection * randomTx, -20);
    } completion:nil];
    CABasicAnimation *rotate = [CABasicAnimation animation];
    rotate.keyPath = @"transform.rotation";
    NSInteger rotationDirection = 1 - (2 * (int)arc4random_uniform(2));
    NSInteger rotationFraction = (int)arc4random_uniform(10);
    rotate.toValue = @(rotationDirection * M_PI * rotationFraction * 0.1);
    CABasicAnimation *scale = [CABasicAnimation animation];
    scale.keyPath = @"transform.scale";
    scale.toValue = @(1.5);
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 3;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    group.animations = @[rotate, scale, keyFrameAnimation];
    [iconView.layer addAnimation:group forKey:@"like_animation"];

    [UIView animateWithDuration:3 animations:^{
        iconView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [iconView removeFromSuperview];
    }];
    //
    //    keyFrameAnimation.values = @[scale, rotate];
    //    keyFrameAnimation.duration = 3;
    //    keyFrameAnimation.keyTimes = @[@0, @1];
    //    [iconView.layer addAnimation:keyFrameAnimation forKey:@"like_animation"];
}

#pragma mark - Private Action

- (NSString *)getRandomIcon {
    if (self.iconList.count > 0) {
        NSInteger i = arc4random_uniform((int)self.iconList.count);
        NSString *icon = self.iconList[i];
        return icon;
    }
    return @"";
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.userInteractionEnabled = NO;
    }
    return _contentView;
}

- (NSArray<NSString *> *)iconList {
    if (!_iconList) {
        _iconList = @[@"like_celebrate", @"like_heart", @"like_love", @"like_star", @"like_like"];
    }
    return _iconList;
}

@end
