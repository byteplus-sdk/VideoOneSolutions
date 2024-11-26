//
//  TTAvatarView.m
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/20.
//

#import "TTAvatarView.h"
#import "UIImage+Bundle.h"
#import "UIColor+String.h"
#import <ToolKit/ToolKit.h>
#import <Masonry/Masonry.h>

@interface TTAvatarView ()

@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) UIImageView *livingTag;

@property (nonatomic, strong) CAShapeLayer *outterCircle;

@property (nonatomic, strong) CAShapeLayer *innerCircle;

@property (nonatomic, strong) CABasicAnimation *transformAnimation;

@end

@implementation TTAvatarView

- (void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
    self.outterCircle.path = [UIBezierPath
                              bezierPathWithArcCenter:center
                              radius:30
                              startAngle:0
                              endAngle:2.0 * M_PI
                              clockwise:YES].CGPath;
    self.innerCircle.path = [UIBezierPath
                             bezierPathWithArcCenter:center
                             radius:25
                             startAngle:0
                             endAngle:2.0 * M_PI
                             clockwise:YES].CGPath;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]
                               initWithTarget:self
                                    action:@selector(didClick)]];
        [self initialUI];
        
    }
    return self;
}

- (void)initialUI {
    [self addSubview:self.avatar];
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(48);
        make.center.equalTo(self);
    }];
    
    [self.avatar addSubview:self.livingTag];
    [self.livingTag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatar);
        make.centerX.equalTo(self.avatar);
    }];

    [self.layer addSublayer:self.innerCircle];
    [self.layer addSublayer:self.outterCircle];
}

- (void)didClick {
    self.userInteractionEnabled = NO;
    if (self.didClickBlock) {
        self.didClickBlock();
    }
}

- (void)updateUI:(BOOL)active {
    if (active) {
        self.avatar.layer.cornerRadius = 21;
        self.avatar.layer.borderWidth = 0;
        [self.avatar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(42);
        }];
        [self.avatar.layer addAnimation:self.transformAnimation forKey:@"zoom"];
    } else {
        self.avatar.layer.cornerRadius = 24;
        self.avatar.layer.borderWidth = 2;
        [self.avatar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(48);
        }];
        [self.avatar.layer removeAllAnimations];
    }
    self.userInteractionEnabled = active;
    self.outterCircle.hidden = !active;
    self.innerCircle.hidden = !active;
    self.livingTag.hidden = !active;
}


- (void)setAvatarImage:(UIImage *)avatarImage {
    self.avatar.image = avatarImage;
}

- (void)setActive:(BOOL)active {
    _active = active;
    [self updateUI:active];
}

#pragma mark -- getter

- (CABasicAnimation *)transformAnimation {
    if (!_transformAnimation) {
        _transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        _transformAnimation.repeatCount = HUGE_VALF;
        _transformAnimation.duration = 0.4;
        _transformAnimation.autoreverses = YES;
        _transformAnimation.removedOnCompletion = NO;
        _transformAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        _transformAnimation.toValue = [NSNumber numberWithFloat:0.9];
    }
    return _transformAnimation;
}


- (UIImageView *)livingTag {
    if (!_livingTag) {
        _livingTag = [UIImageView new];
        _livingTag.image = [UIImage imageNamed:@"tt_avatar_living_mark" bundleName:@"TTProto"];
        _livingTag.hidden = YES;
    }
    return _livingTag;
}

- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [UIImageView new];
        _avatar.clipsToBounds = YES;
        _avatar.layer.borderColor = [UIColor whiteColor].CGColor;
        _avatar.layer.cornerRadius = 24;
        _avatar.layer.borderWidth = 2;
    }
    return _avatar;
}

- (CAShapeLayer *)outterCircle {
    if (!_outterCircle) {
        _outterCircle = [CAShapeLayer layer];
        _outterCircle.fillColor = [UIColor clearColor].CGColor;
        _outterCircle.strokeColor =  [UIColor colorFromHexString:@"#FF578E"].CGColor;
        _outterCircle.lineWidth = 1;
        _outterCircle.hidden = YES;
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        opacityAnimation.toValue = [NSNumber numberWithFloat:0.4];
        
        CABasicAnimation *thinerAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
        thinerAnimation.fromValue = [NSNumber numberWithFloat:1];
        thinerAnimation.toValue = [NSNumber numberWithFloat:0];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[opacityAnimation, thinerAnimation];
        group.duration = 0.4;
        group.autoreverses = YES;
        group.removedOnCompletion = NO;
        group.repeatCount = HUGE_VALF;
        
        [_outterCircle addAnimation:group forKey:@"groupAnimation"];
    }
    return _outterCircle;
}

- (CAShapeLayer *)innerCircle {
    if (!_innerCircle) {
        _innerCircle = [CAShapeLayer layer];
        _innerCircle.fillColor = [UIColor clearColor].CGColor;
        _innerCircle.strokeColor =  [UIColor colorFromHexString:@"#FF578E"].CGColor;
        _innerCircle.lineWidth = 2;
        _innerCircle.hidden = YES;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue = [NSNumber numberWithFloat:0.8];
        animation.toValue = [NSNumber numberWithFloat:1];
        animation.duration = 0.4;
        animation.autoreverses = YES;
        animation.removedOnCompletion = NO;
        animation.repeatCount = HUGE_VALF;
        [_innerCircle addAnimation:animation forKey:@"opacity"];
    }
    return _innerCircle;
}

@end
