// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "UIView+VELAdd.h"
#import "NSObject+VELAdd.h"
#import "VELCommonDefine.h"
#import <objc/runtime.h>

@implementation UIView (AWELayout)

- (void)setVel_top:(CGFloat)vel_top {
    self.frame = CGRectMake(self.vel_left, vel_top, self.vel_width, self.vel_height);
}

- (CGFloat)vel_top {
    return self.frame.origin.y;
}

- (void)setVel_bottom:(CGFloat)vel_bottom {
    self.frame = CGRectMake(self.vel_left, vel_bottom - self.vel_height, self.vel_width, self.vel_height);
}

- (CGFloat)vel_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setVel_left:(CGFloat)vel_left {
    self.frame = CGRectMake(vel_left, self.vel_top, self.vel_width, self.vel_height);
}

- (CGFloat)vel_left {
    return self.frame.origin.x;
}

- (void)setVel_right:(CGFloat)vel_right {
    self.frame = CGRectMake(vel_right - self.vel_width, self.vel_top, self.vel_width, self.vel_height);
}

- (CGFloat)vel_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setVel_width:(CGFloat)vel_width {
    self.frame = CGRectMake(self.vel_left, self.vel_top, vel_width, self.vel_height);
}

- (CGFloat)vel_width {
    return self.frame.size.width;
}

- (void)setVel_height:(CGFloat)vel_height {
    self.frame = CGRectMake(self.vel_left, self.vel_top, self.vel_width, vel_height);
}

- (CGFloat)vel_height {
    return self.frame.size.height;
}

- (CGFloat)vel_centerX {
    return self.center.x;
}

- (void)setVel_centerX:(CGFloat)vel_centerX {
    self.center = CGPointMake(vel_centerX, self.center.y);
}

- (CGFloat)vel_centerY {
    return self.center.y;
}

- (void)setVel_centerY:(CGFloat)vel_centerY {
    self.center = CGPointMake(self.center.x, vel_centerY);
}

- (CGSize)vel_size {
    return self.frame.size;
}

- (void)setVel_size:(CGSize)vel_size {
    self.frame = CGRectMake(self.vel_left, self.vel_top, vel_size.width, vel_size.height);
}

- (CGPoint)vel_origin {
    return self.frame.origin;
}

- (void)setVel_origin:(CGPoint)vel_origin {
    self.frame = CGRectMake(vel_origin.x, vel_origin.y, self.vel_width, self.vel_height);
}

- (void)vel_roundRect:(UIRectCorner)corners withSize:(CGSize)size {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:size];
    CAShapeLayer *layer = [[CAShapeLayer alloc]init];
    layer.frame = self.bounds;
    layer.path = path.CGPath;
    self.layer.mask = layer;
}

- (CGRect)vel_convertRect:(CGRect)rect toView:(nullable UIView *)view {
    if (view) {
        return [view vel_convertRect:rect fromView:self];
    }
    return [self convertRect:rect toView:view];
}

- (CGRect)vel_convertRect:(CGRect)rect fromView:(nullable UIView *)view {
    UIWindow *selfWindow = [self isKindOfClass:[UIWindow class]] ? (UIWindow *)self : self.window;
    UIWindow *fromWindow = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : view.window;
    if (selfWindow && fromWindow && selfWindow != fromWindow) {
        CGRect rectInFromWindow = fromWindow == view ? rect : [view convertRect:rect toView:nil];
        CGRect rectInSelfWindow = [selfWindow convertRect:rectInFromWindow fromWindow:fromWindow];
        CGRect rectInSelf = selfWindow == self ? rectInSelfWindow : [self convertRect:rectInSelfWindow fromView:nil];
        return rectInSelf;
    }
    return [self convertRect:rect fromView:view];
}

- (BOOL)vel_visible {
    if (self.hidden || self.alpha <= 0.01) {
        return NO;
    }
    if (self.window) {
        return YES;
    }
    if ([self isKindOfClass:UIWindow.class]) {
        if (@available(iOS 13.0, *)) {
            return !!((UIWindow *)self).windowScene;
        } else {
            return YES;
        }
    }
    return NO;
}

- (void)vel_removeAllSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}


- (UIImage *)imageRepresentation {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


//***********************frame***********************//
-(CGFloat)frameX{
    return self.frame.origin.x;
}
-(void)setFrameX:(CGFloat)frameX{
    CGRect frame = self.frame;
    frame.origin.x = frameX;
    self.frame = frame;
}

-(CGFloat)frameY{
    return self.frame.origin.y;
}
-(void)setFrameY:(CGFloat)frameY{
    CGRect frame = self.frame;
    frame.origin.y = frameY;
    self.frame = frame;
}

-(CGFloat)frameW{
    return self.frame.size.width;
}
-(void)setFrameW:(CGFloat)frameW{
    CGRect frame = self.frame;
    frame.size.width = frameW;
    self.frame = frame;
}

-(CGFloat)frameH{
    return self.frame.size.height;
}
-(void)setFrameH:(CGFloat)frameH{
    CGRect frame = self.frame;
    frame.size.height = frameH;
    self.frame = frame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)left {
    return self.frame.origin.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = floor(x);
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)top {
    return self.frame.origin.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = floor(y);
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = floor(right - frame.size.width);
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = floor(bottom - frame.size.height);
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerX {
    return self.center.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(floor(centerX), floor(self.center.y));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerY {
    return self.center.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)width {
    return self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = floor(width);
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)height {
    return self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = floor(height);
    self.frame = frame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)ttScreenX {
    CGFloat x = 0;
    for (UIView* view = self; view; view = view.superview) {
        x += view.left;
    }
    return x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)ttScreenY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.top;
    }
    return y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)screenViewX {
    CGFloat x = 0;
    for (UIView* view = self; view; view = view.superview) {
        x += view.left;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            x -= scrollView.contentOffset.x;
        }
    }
    
    return x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)screenViewY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.top;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)screenFrame {
    return CGRectMake(self.screenViewX, self.screenViewY, self.width, self.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)origin {
    return self.frame.origin;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)size {
    return self.frame.size;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllSubviews {
    while (self.subviews.count) {
        UIView* child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

@end
@implementation UIView (VELLayoutBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleOriginal:@selector(setFrame:) replace:@selector(vel_setFrame:) onInstance:YES];
        [self swizzleOriginal:@selector(setBounds:) replace:@selector(vel_setBounds:) onInstance:YES];
    });
}

- (void)vel_setFrame:(CGRect)frame {
    CGRect preFrame = self.frame;
    BOOL valueChange = !CGRectEqualToRect(frame, preFrame);
    if (self.vel_frameWillChangeBlock && valueChange) {
        frame = self.vel_frameWillChangeBlock(self, preFrame);
    }
    [self vel_setFrame:frame];
    if (self.vel_frameDidChangeBlock && valueChange) {
        self.vel_frameDidChangeBlock(self, frame);
    }
}

- (void)vel_setBounds:(CGRect)bounds {
    CGRect preFrame = self.frame;
    CGRect preBounds = self.bounds;
    BOOL valueChange = !CGSizeEqualToSize(bounds.size, preBounds.size);
    if (self.vel_frameWillChangeBlock && valueChange) {
        CGRect followingFrame = CGRectMake(CGRectGetMinX(preFrame) + VELCGFloatGetCenter(CGRectGetWidth(bounds), CGRectGetWidth(preFrame)), CGRectGetMinY(preFrame) + VELCGFloatGetCenter(CGRectGetHeight(bounds), CGRectGetHeight(preFrame)), bounds.size.width, bounds.size.height);
        followingFrame = self.vel_frameWillChangeBlock(self, followingFrame);
        bounds = VELCGRectSetSize(bounds, followingFrame.size);
    }
    [self vel_setBounds:bounds];
    if (self.vel_frameDidChangeBlock && valueChange) {
        self.vel_frameDidChangeBlock(self, self.frame);
    }
}

- (void)vel_setCenter:(CGPoint)center {
    CGRect precedingFrame = self.frame;
    CGPoint precedingCenter = self.center;
    BOOL valueChange = !CGPointEqualToPoint(center, precedingCenter);
    if (self.vel_frameWillChangeBlock && valueChange) {
        CGRect followingFrame = VELCGRectSetXY(precedingFrame, center.x - CGRectGetWidth(self.frame) / 2, center.y - CGRectGetHeight(self.frame) / 2);
        followingFrame = self.vel_frameWillChangeBlock(self, followingFrame);
        center = CGPointMake(CGRectGetMidX(followingFrame), CGRectGetMidY(followingFrame));
    }
    [self vel_setCenter:center];
    
    if (self.vel_frameDidChangeBlock && valueChange) {
        self.vel_frameDidChangeBlock(self, precedingFrame);
    }
}

static char kAssociatedObjectKey_frameWillChangeBlock;
- (void)setVel_frameWillChangeBlock:(CGRect (^)(__kindof UIView *, CGRect))vel_frameWillChangeBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_frameWillChangeBlock, vel_frameWillChangeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGRect (^)(__kindof UIView *, CGRect))vel_frameWillChangeBlock {
    return (CGRect (^)(__kindof UIView *, CGRect))objc_getAssociatedObject(self, &kAssociatedObjectKey_frameWillChangeBlock);
}


static char kAssociatedObjectKey_frameDidChangeBlock;
- (void)setVel_frameDidChangeBlock:(void (^)(__kindof UIView *, CGRect))vel_frameDidChangeBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_frameDidChangeBlock, vel_frameDidChangeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof UIView *, CGRect))vel_frameDidChangeBlock {
    return (void (^)(__kindof UIView *, CGRect))objc_getAssociatedObject(self, &kAssociatedObjectKey_frameDidChangeBlock);
}

static char kAssociatedObjectKey_layoutSubViewsBlock;
- (void)setVel_layoutSubviewsBlock:(void (^)(__kindof UIView *))vel_layoutSubviewsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_layoutSubViewsBlock, vel_layoutSubviewsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof UIView *))vel_layoutSubviewsBlock {
    return (void (^)(__kindof UIView *))objc_getAssociatedObject(self, &kAssociatedObjectKey_layoutSubViewsBlock);
}

static char kAssociatedObjectKey_sizeThatFitsBlock;
- (void)setVel_sizeThatFitsBlock:(CGSize (^)(__kindof UIView *, CGSize, CGSize))vel_sizeThatFitsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_sizeThatFitsBlock, vel_sizeThatFitsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGSize (^)(__kindof UIView *, CGSize, CGSize))vel_sizeThatFitsBlock {
    return (CGSize (^)(__kindof UIView *, CGSize, CGSize))objc_getAssociatedObject(self, &kAssociatedObjectKey_sizeThatFitsBlock);
}

static char kAssociatedObjectKey_hitTestBlock;
- (void)setVel_hitTestBlock:(__kindof UIView *(^)(CGPoint, UIEvent *, __kindof UIView *))vel_hitTestBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_hitTestBlock, vel_hitTestBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (__kindof UIView *(^)(CGPoint, UIEvent *, __kindof UIView *))vel_hitTestBlock {
    return (__kindof UIView *(^)(CGPoint, UIEvent *, __kindof UIView *))objc_getAssociatedObject(self, &kAssociatedObjectKey_hitTestBlock);
}

@end
