// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "UIViewController+VELAdd.h"
#import "UIView+VELAdd.h"
#import "VELDeviceRotateHelper.h"
@implementation UIViewController (VELAdd)
- (UIViewController *)vel_visibleViewController {
    if (self.presentedViewController) {
        return [self.presentedViewController vel_visibleViewController];
    }
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).visibleViewController vel_visibleViewController];
    }
    
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController vel_visibleViewController];
    }
    
    if ([self vel_isViewLoadedAndVisible]) {
        return self;
    } else {
        return nil;
    }
}

- (BOOL)vel_isViewLoadedAndVisible {
    return self.isViewLoaded && self.view.vel_visible;
}

+ (UIViewController *)vel_topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    if ([resultVC isKindOfClass:[UIAlertController class]]) {
        resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}
@end

