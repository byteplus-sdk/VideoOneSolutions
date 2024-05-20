// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELUINavigationController.h"
#import "VELCommonDefine.h"
#import <objc/runtime.h>

@interface UIViewController ()
- (BOOL)shouldPopViewController:(BOOL)isGesture;
@end
@protocol VELUIGestureRecognizerDelegate <UIGestureRecognizerDelegate>
- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveEvent:(UIEvent *)event;
@end

@interface VELUIInteractiveDelegator : NSObject <VELUIGestureRecognizerDelegate>
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, weak) id<VELUIGestureRecognizerDelegate> originalDelegate;
@end
@implementation VELUIInteractiveDelegator
+ (instancetype)delegatorWithNav:(UINavigationController *)navController {
    VELUIInteractiveDelegator *delegator = [[VELUIInteractiveDelegator alloc] init];
    delegator.navigationController = navController;
    delegator.originalDelegate = (id<VELUIGestureRecognizerDelegate>)navController.interactivePopGestureRecognizer.delegate;
    navController.interactivePopGestureRecognizer.delegate = delegator;
    return delegator;
}

- (void)dealloc {
    [self destroy];
}

- (void)destroy {
    if (self.navigationController.interactivePopGestureRecognizer.delegate == self) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self.originalDelegate;
        self.navigationController = nil;
        self.originalDelegate = nil;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldResponse = NO;
    BOOL hasLeftItem = self.navigationController.navigationItem.leftBarButtonItem != nil || self.navigationController.navigationItem.leftBarButtonItems != nil;
    if ((self.navigationController.navigationBarHidden || hasLeftItem) && self.navigationController.viewControllers.count > 1) {
        shouldResponse = YES;
    } else {
        shouldResponse = [self.originalDelegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
    return [self checkLastVCShouldPop:shouldResponse];
}

- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveEvent:(UIEvent *)event {
    BOOL shouldResponse = NO;
    BOOL hasLeftItem = self.navigationController.navigationItem.leftBarButtonItem != nil || self.navigationController.navigationItem.leftBarButtonItems != nil;
    if ((self.navigationController.navigationBarHidden || hasLeftItem) && self.navigationController.viewControllers.count > 1) {
        shouldResponse = YES;
    } else {
        shouldResponse = [self.originalDelegate _gestureRecognizer:gestureRecognizer shouldReceiveEvent:event];
    }
    return [self checkLastVCShouldPop:shouldResponse];
}
- (BOOL)checkLastVCShouldPop:(BOOL)shouldResponse {
    if (shouldResponse == YES) {
        UIViewController *lastVC = self.navigationController.viewControllers.lastObject;
        if ([lastVC respondsToSelector:@selector(shouldPopViewController:)]) {
            shouldResponse = [lastVC shouldPopViewController:YES];
        }
    }
    return shouldResponse;
}
- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(gestureRecognizer:shouldReceiveTouch:)) {
        return YES;
    } else if (aSelector == @selector(_gestureRecognizer:shouldReceiveEvent:)) {
        return YES;
    } else {
        return [self.originalDelegate respondsToSelector:aSelector];
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.originalDelegate;
}
@end

@implementation UINavigationController (VEL_Gesture)
static char kAssociatedObjectKey_vel_interactiveDelegator;
- (void)setVel_interactiveDelegator:(VELUIInteractiveDelegator *)vel_interactiveDelegator {
    @synchronized (self) {
        objc_setAssociatedObject(self, &kAssociatedObjectKey_vel_interactiveDelegator, vel_interactiveDelegator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (VELUIInteractiveDelegator *)vel_interactiveDelegator {
    @synchronized (self) {
        return (VELUIInteractiveDelegator *)objc_getAssociatedObject(self, &kAssociatedObjectKey_vel_interactiveDelegator);
    }
}

- (void)vel_setupNavGesture {
    self.vel_interactiveDelegator = [VELUIInteractiveDelegator delegatorWithNav:self];
}

- (void)vel_destroyNavGesture {
    [self.vel_interactiveDelegator destroy];
    self.vel_interactiveDelegator = nil;
}
@end


@interface VELUINavigationController ()
@end

@implementation VELUINavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = VELViewBackgroundColor;
    [self vel_setupNavGesture];
}
@end
