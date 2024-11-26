//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEInterfaceDiggButton.h"
#import "VEInterfaceSocialButton+Extension.h"
#import <Lottie/LOTAnimationView.h>
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>

@interface VEInterfaceDiggButton ()

@property (nonatomic, strong) LOTAnimationView *animationView;

@end

@implementation VEInterfaceDiggButton

- (void)setLiked:(BOOL)liked {
    _liked = liked;
    if (self.axis == UILayoutConstraintAxisVertical) {
        [self.animationView setAnimation:liked ? @"like_cancel.json" : @"like_icondata.json"];
    } else {
        UIImageView *imageView = [super imageView];
        imageView.image = [UIImage imageNamed:liked ? @"vod_liked_deformity" : @"vod_like_deformity" bundleName:@"VodPlayer"];
    }
}

- (void)play {
    if (self.axis == UILayoutConstraintAxisVertical) {
        self.userInteractionEnabled = NO;
        __weak typeof(self) weak_self = self;
        [self.animationView playWithCompletion:^(BOOL animationFinished) {
            weak_self.liked = !weak_self.liked;
            weak_self.userInteractionEnabled = YES;
        }];
    } else {
        self.liked = !self.liked;
    }
}

- (LOTAnimationView *)animationView {
    if (!_animationView) {
        _animationView = [[LOTAnimationView alloc] init];
        _animationView.userInteractionEnabled = NO;
        _animationView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    }
    return _animationView;
}

+ (void)playDiggAnimationInView:(UIView *)containerView location:(CGPoint)location {
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vod_heart" bundleName:@"VodPlayer"]];
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.frame = CGRectMake(0, 0, view.image.size.width, view.image.size.height);
    if (view.image.size.width > 100 || view.image.size.height > 100) {
        view.frame = CGRectMake(0, 0, 130, 130);
    }
    view.center = location;
    [containerView addSubview:view];

    CGRect originRect = view.frame;
    view.frame = [self _scaleRect:originRect scale:1.8];
    CGFloat randomRotation = (NSInteger)(arc4random() % 61) - 30;
    view.layer.transform = CATransform3DMakeRotation(randomRotation / 180.0 * M_PI, 0.0, 0.0, 1.0);
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        view.frame = originRect;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            const CGFloat scaleValue = ((CGFloat)(arc4random() % 100)) / 100 + 2;
            view.frame = [self _scaleRect:originRect scale:scaleValue];
            view.center = CGPointMake(view.center.x, view.center.y - 50);
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }];
}

+ (CGRect)_scaleRect:(CGRect)originRect scale:(CGFloat)scale {
    CGFloat width = ceil(originRect.size.width * scale);
    CGFloat height = ceil(originRect.size.height * scale);
    CGFloat originX = originRect.origin.x + (originRect.size.width - width) * 0.5;
    CGFloat originY = originRect.origin.y + (originRect.size.height - height) * 0.5;
    return CGRectMake(originX, originY, width, height);
}

#pragma mark - Override
- (void)setImage:(UIImage *)image {
}

- (UIImage *)image {
    return nil;
}

- (UIView *)imageView {
    if (self.axis == UILayoutConstraintAxisVertical) {
        return self.animationView;
    } else {
        return [super imageView];
    }
}

@end
