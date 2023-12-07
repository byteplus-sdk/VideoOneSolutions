//
//  BaseLoadingView.m
//  ToolKit
//
//  Created by bytedance on 2023/10/25.
//

#import "BaseLoadingView.h"
#import "UIImage+Bundle.h"
#import <Masonry/Masonry.h>

@interface BaseLoadingView ()

@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation BaseLoadingView

+ (instancetype)sharedInstance
{
    static BaseLoadingView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        CGSize size = CGSizeMake(32, 32);
        CGRect frame = keyWindow.frame;
        sharedInstance = [[BaseLoadingView alloc] initWithFrame:CGRectMake((frame.size.width - size.width)/2, (frame.size.height - size.height)/2, size.width, size.height)];
        
    });
    return sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.iconView = [UIImageView new];
        self.iconView.image = [UIImage imageNamed:@"toolKit_loading" bundleName:ToolKitBundleName];
        self.iconView.frame = self.bounds;
        [self addSubview:self.iconView];
    }
    return self;
}



- (void)startLoadingIn:(UIView *)view {
    [self removeFromSuperview];
    UIView *superview = view ?: [UIApplication sharedApplication].keyWindow;
    [superview addSubview:self];

    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(view);
        make.size.equalTo(@(CGSizeMake(32, 32)));
    }];
    [self layoutIfNeeded];
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotate.fromValue = @(0);
    rotate.toValue = @(M_PI*2.0);
    rotate.duration = 1;
    rotate.repeatCount = 10000;
    [self.iconView.layer addAnimation:rotate forKey:@""];
}

- (void)stopLoading {
    [self.iconView.layer removeAllAnimations];
    [self removeFromSuperview];
}



@end
