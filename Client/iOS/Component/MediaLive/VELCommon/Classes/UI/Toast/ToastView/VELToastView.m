// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELToastView.h"
#import "VELCommonDefine.h"

static NSMutableArray <VELToastView *> *__VELGlobalViews__ = nil;

@interface VELToastView ()
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, weak) NSTimer *delayTimer;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, weak) UIView *containerView;
@property(nonatomic, strong, readwrite) VELToastContentView *contentView;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) UIEdgeInsets marginInsets;
@end

@implementation VELToastView
- (instancetype)initWithContainer:(UIView *)container {
    if (self = [super initWithFrame:container.bounds]) {
        _containerView = container;
        self.marginInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        [self setupUI];
    }
    return self;
}

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    UIView *v = [super hitTest:point withEvent:event];
    if (v == self) {
        return nil;
    }
    return v;
}

- (void)setupUI {
    if (!__VELGlobalViews__) {
        __VELGlobalViews__ = [[NSMutableArray alloc] init];
    }
    self.enableMaskControl = NO;
    self.opaque = NO;
    self.alpha = 0;
    self.backgroundColor = UIColor.clearColor;
    
    _position = VELToastPositionCenter;
    
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    self.backgroundView.alpha = 0.0;
    self.backgroundView.layer.cornerRadius = 6;
    self.backgroundView.clipsToBounds = YES;
    [self addSubview:self.backgroundView];
    
    self.contentView = [[VELToastContentView alloc] init];
    [self addSubview:self.contentView];
    _maskView = [[UIView alloc] init];
    self.maskView.hidden = !self.enableMaskControl;
    self.maskView.backgroundColor = UIColor.clearColor;
    [self addSubview:self.maskView];
    
    [self.containerView addSubview:self];
}

- (void)setLoadingView:(BOOL)loadingView {
    _loadingView = loadingView;
    [self setEnableMaskControl:loadingView];
}

- (void)setEnableMaskControl:(BOOL)enableMaskControl {
    _enableMaskControl = enableMaskControl;
    self.maskView.hidden = !enableMaskControl;
}

- (void)didMoveToSuperview {
    if (self.superview) {
        if (![__VELGlobalViews__ containsObject:self]) {
            [__VELGlobalViews__ addObject:self];
        }
    } else {
        if ([__VELGlobalViews__ containsObject:self]) {
            [__VELGlobalViews__ removeObject:self];
        }
    }
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    _containerView = nil;
    
    if (self.willHideBlock) {
        self.willHideBlock(self);
        self.willHideBlock = nil;
    }
    if (self.didHideBlock) {
        self.didHideBlock(self);
        self.didHideBlock = nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.frame = self.containerView.bounds;
    self.maskView.frame = self.bounds;
    
    CGFloat contentWidth = CGRectGetWidth(self.containerView.bounds);
    CGFloat contentHeight = CGRectGetHeight(self.containerView.bounds);
    UIEdgeInsets marginInsets = VEL_SAFE_INSERT;
    if (@available(iOS 11.0, *)) {
        marginInsets = self.containerView.safeAreaInsets;
    }
    marginInsets = VELUIEdgeInsetsConcat(self.marginInsets, marginInsets);
    CGFloat limitWidth = contentWidth - VELUIEdgeInsetsGetHorizontalValue(marginInsets);
    CGFloat limitHeight = contentHeight - VELUIEdgeInsetsGetVerticalValue(marginInsets);
    
    if (self.contentView) {
        CGSize contentViewSize = [self.contentView sizeThatFits:CGSizeMake(limitWidth, limitHeight)];
        contentViewSize.width = MIN(contentViewSize.width, limitWidth);
        contentViewSize.height = MIN(contentViewSize.height, limitHeight);
        CGFloat contentViewX = MAX(marginInsets.left, (contentWidth - contentViewSize.width) / 2);
        CGFloat contentViewY = MAX(marginInsets.top, (contentHeight - contentViewSize.height) / 2);
        
        if (self.position == VELToastPositionTop) {
            contentViewY = marginInsets.top;
        } else if (self.position == VELToastPositionBottom) {
            contentViewY = contentHeight - contentViewSize.height - marginInsets.bottom;
        }
        CGRect contentRect = CGRectMake(contentViewX, contentViewY, contentViewSize.width, contentViewSize.height);
        self.contentView.frame = contentRect;
        [self.contentView setNeedsLayout];
    }
    if (self.backgroundView) {
        self.backgroundView.frame = self.contentView.frame;
    }
}
- (void)animationForShow:(BOOL)show withCompletion:(void (^_Nullable)(BOOL))completion {
    CGFloat alpha = show ? 1.f : 0.f;
    CGAffineTransform small = CGAffineTransformMakeScale(0.5f, 0.5f);
    self.isAnimating = YES;
    if (show) {
        self.backgroundView.transform = small;
        self.contentView.transform = small;
    }
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.backgroundView.alpha = alpha;
        self.contentView.alpha = alpha;
        self.backgroundView.transform = CGAffineTransformIdentity;
        self.contentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)showWithAnimated:(BOOL)animated {
    [self setNeedsLayout];
    [self.delayTimer invalidate];
    self.alpha = 1.0;
    if (animated) {
        [self animationForShow:YES withCompletion:nil];
    } else {
        self.backgroundView.alpha = 1.0;
        self.contentView.alpha = 1.0;
    }
}

- (void)hideWithAnimated:(BOOL)animated {
    if (self.willHideBlock) {
        self.willHideBlock(self);
        self.willHideBlock = nil;
    }
    if (animated) {
        __weak __typeof__(self)weakSelf = self;
        [self animationForShow:NO withCompletion:^(BOOL fnished) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self didHideWithAnimated:animated];
        }];
    } else {
        self.backgroundView.alpha = 0.0;
        self.contentView.alpha = 0.0;
        [self didHideWithAnimated:animated];
    }
}

- (void)didHideWithAnimated:(BOOL)animated {
    [self.delayTimer invalidate];
    self.alpha = 0.0;
    [self removeFromSuperview];
    if (self.didHideBlock) {
        self.didHideBlock(self);
        self.didHideBlock = nil;
    }
}

- (void)hideWithAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    NSTimer *timer = [NSTimer timerWithTimeInterval:delay
                                             target:self
                                           selector:@selector(handleHideDelayTimer:)
                                           userInfo:@(animated)
                                            repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.delayTimer = timer;
}

- (void)handleHideDelayTimer:(NSTimer *)timer {
    [self hideWithAnimated:[timer.userInfo boolValue]];
}

- (void)dealloc {
    if ([__VELGlobalViews__ containsObject:self]) {
        [__VELGlobalViews__ removeObject:self];
    }
    if (self.willHideBlock) {
        self.willHideBlock(self);
        self.willHideBlock = nil;
    }
    if (self.didHideBlock) {
        self.didHideBlock(self);
        self.didHideBlock = nil;
    }
}
+ (BOOL)hideAllToastInView:(UIView *)view filter:(BOOL (^)(VELToastView * _Nonnull))filter animated:(BOOL)animated {
    NSArray *toastViews = [self allToastInView:view];
    for (VELToastView *toastView in toastViews) {
        if (filter && filter(toastView)) {
            [toastView hideWithAnimated:animated];
        }
    }
    return YES;
}
+ (BOOL)hideAllToastInView:(UIView *)view animated:(BOOL)animated {
    return [self hideAllToastInView:view filter:^BOOL(VELToastView * _Nonnull view) {
        return YES;
    } animated:animated];
}

+ (void)hideAllLoadingInView:(UIView *)view animated:(BOOL)animated {
    [self hideAllToastInView:nil filter:^BOOL(VELToastView * _Nonnull view) {
        return view.isLoadingView;
    } animated:NO];
}

+ (nullable NSArray <VELToastView *> *)allToastInView:(UIView *)view {
    if (!view) {
        return __VELGlobalViews__.count > 0 ? [__VELGlobalViews__ mutableCopy] : nil;
    }
    NSMutableArray *toastViews = [[NSMutableArray alloc] init];
    for (UIView *toastView in __VELGlobalViews__) {
        if (toastView.superview == view && [toastView isKindOfClass:self]) {
            [toastViews addObject:toastView];
        }
    }
    return toastViews.count > 0 ? [toastViews mutableCopy] : nil;
}

@end
