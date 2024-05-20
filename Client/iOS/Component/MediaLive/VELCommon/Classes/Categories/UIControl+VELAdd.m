// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "UIControl+VELAdd.h"
#import <objc/runtime.h>

static const char * kHitEdgeInsets = "hitEdgeInset";
static const char * kHitScale = "hitScale";
static const char * kHitWidthScale = "hitWidthScale";
static const char * kHitHeightScale = "hitWidthScale";


@implementation UIControl (VELAdd)

#pragma mark - set Method
-(void)setHitEdgeInsets:(UIEdgeInsets)hitEdgeInsets{
    NSValue *value = [NSValue value:&hitEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, kHitEdgeInsets, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setHitScale:(CGFloat)hitScale{
    objc_setAssociatedObject(self, kHitScale, @(hitScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setHitWidthScale:(CGFloat)hitScale{
    objc_setAssociatedObject(self, kHitScale, @(hitScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setHitHeightScale:(CGFloat)hitHeightScale{
    objc_setAssociatedObject(self, kHitHeightScale, @(kHitHeightScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - get method
-(UIEdgeInsets)hitEdgeInsets{
    NSValue *value = objc_getAssociatedObject(self, kHitEdgeInsets);
    UIEdgeInsets edgeInsets;
    [value getValue:&edgeInsets];
    return value ? edgeInsets:UIEdgeInsetsZero;
}

-(CGFloat)hitScale{
    return [objc_getAssociatedObject(self, kHitScale) floatValue];
}

-(CGFloat)hitWidthScale{
    return [objc_getAssociatedObject(self, kHitWidthScale) floatValue];
}

-(CGFloat)hitHeightScale{
    return [objc_getAssociatedObject(self, kHitHeightScale) floatValue];
}

#pragma mark - override super method
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    BOOL hitEdgeZero = UIEdgeInsetsEqualToEdgeInsets(self.hitEdgeInsets, UIEdgeInsetsZero);
    CGFloat scale = [self hitScale];
    CGFloat widthScale = [self hitWidthScale];
    CGFloat heightScale = [self hitHeightScale];
    
    if((hitEdgeZero && scale <= 0 && widthScale <= 0 && heightScale <= 0)
       || !self.enabled || self.hidden || self.alpha == 0 ) {
        return [super pointInside:point withEvent:event];
    }else{
        CGRect relativeFrame = self.bounds;
        
        if (!hitEdgeZero) {
            CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.hitEdgeInsets);
            return CGRectContainsPoint(hitFrame, point);
        } else {
            if (scale > 0) {
                CGFloat width = self.bounds.size.width * scale;
                CGFloat height = self.bounds.size.height * scale;
                CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, UIEdgeInsetsMake(-height, -width, -height, -width));
                return CGRectContainsPoint(hitFrame, point);
            } else if (widthScale > 0 || heightScale > 0) {
                CGFloat width = self.bounds.size.width * widthScale;
                CGFloat height = self.bounds.size.height * heightScale;
                CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, UIEdgeInsetsMake(-height, -width, -height, -width));
                return CGRectContainsPoint(hitFrame, point);
            }
        }
        return NO;
    }
}

static char kAssociatedObjectKey_preventsTouchEvent;
static BOOL isExchangePreventsMethod = NO;
- (void)setPreventsTouchEvent:(BOOL)preventsTouchEvent {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_preventsTouchEvent, @(preventsTouchEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (preventsTouchEvent && !isExchangePreventsMethod) {
        isExchangePreventsMethod = YES;
        Class class = [self class];
        SEL originSelector = @selector(sendAction:to:forEvent:);
        SEL newSelector = @selector(velSendAction:to:forEvent:);
        Method oriMethod = class_getInstanceMethod(class, originSelector);
        Method newMethod = class_getInstanceMethod(class, newSelector);
        if (newMethod) {
            BOOL isAddedMethod = class_addMethod(class, originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
            if (isAddedMethod) {
                IMP oriMethodIMP = method_getImplementation(oriMethod) ?: imp_implementationWithBlock(^(id selfObject) {});
                const char *oriMethodTypeEncoding = method_getTypeEncoding(oriMethod) ?: "v@:";
                class_replaceMethod(class, newSelector, oriMethodIMP, oriMethodTypeEncoding);
            } else {
                method_exchangeImplementations(oriMethod, newMethod);
            }
        }
    }
}
- (BOOL)preventsTouchEvent {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_preventsTouchEvent)) boolValue];
}

- (void)velSendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if (self.preventsTouchEvent) {
        NSArray<NSString *> *actions = [self actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
        if (!actions) {
            actions = [self actionsForTarget:target forControlEvent:UIControlEventPrimaryActionTriggered];
        }
        if ([actions containsObject:NSStringFromSelector(action)]) {
            UITouch *touch = event.allTouches.anyObject;
            if (touch.tapCount > 1) {
                return;
            }
        }
    }
    [self velSendAction:action to:target forEvent:event];
}
@end
