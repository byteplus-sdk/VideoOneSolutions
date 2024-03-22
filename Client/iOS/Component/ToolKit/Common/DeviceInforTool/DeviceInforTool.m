// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "DeviceInforTool.h"

@implementation DeviceInforTool

#pragma mark - Publish Action

+ (BOOL)isIpad {
    NSString *deviceType = [UIDevice currentDevice].model;
    if ([deviceType isEqualToString:@"iPhone"]) {
        // iPhone
        return NO;
    } else if ([deviceType isEqualToString:@"iPod touch"]) {
        // iPod Touch
        return NO;
    } else if ([deviceType isEqualToString:@"iPad"]) {
        // iPad
        return YES;
    }
    return NO;
}

+ (CGFloat)getVirtualHomeHeight {
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    return keyWindow.safeAreaInsets.bottom;
}

+ (UIEdgeInsets)getSafeAreaInsets {
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    return keyWindow.safeAreaInsets;
}

+ (UIViewController *)rootViewController {
    if (@available(iOS 13.0, *)) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(UIScene *evaluatedObject, NSDictionary<NSString *, id> *_Nullable bindings) {
            return [evaluatedObject isKindOfClass:[UIWindowScene class]] && evaluatedObject.activationState == UISceneActivationStateForegroundActive;
        }];
        UIWindowScene *windowScene = (UIWindowScene *)[[[UIApplication sharedApplication].connectedScenes filteredSetUsingPredicate:predicate] anyObject];
        if (!windowScene) {
            return [UIApplication sharedApplication].delegate.window.rootViewController;
        }
        if (@available(iOS 15.0, *)) {
            return windowScene.keyWindow.rootViewController;
        } else {
            return windowScene.windows.firstObject.rootViewController;
        }
    } else {
        return [UIApplication sharedApplication].delegate.window.rootViewController;
    }
}

+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[self rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    if ([resultVC isKindOfClass:[UIAlertController class]]) {
        resultVC = [self _topViewController:[self rootViewController]];
    } else if ([resultVC isKindOfClass:[NSClassFromString(@"AlertActionViewController") class]]) {
        resultVC = [self _topViewController:[self rootViewController]];
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
}

+ (void)backToRootViewController {
    UIViewController *rootViewController = [self rootViewController];
    UIViewController *presentedViewController = nil;

    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        rootViewController = [(UITabBarController *)rootViewController selectedViewController];
    }

    presentedViewController = rootViewController;
    NSMutableArray<UIViewController *> *presentedViewControllers = [NSMutableArray array];
    while (presentedViewController.presentedViewController) {
        [presentedViewControllers addObject:presentedViewController.presentedViewController];
        presentedViewController = presentedViewController.presentedViewController;
    }

    if (presentedViewControllers.count > 0) {
        [self dismissViewControllers:presentedViewControllers topIndex:presentedViewControllers.count - 1 complete:^{
            [self popToRootViewController:rootViewController];
        }];
    } else {
        [self popToRootViewController:rootViewController];
    }
}

+ (void)dismissViewControllers:(NSArray<UIViewController *> *)array topIndex:(NSInteger)index complete:(void (^)(void))complete {
    if (index < 0) {
        if (complete) {
            complete();
        }
    } else {
        [array[index] dismissViewControllerAnimated:NO completion:^{
            [self dismissViewControllers:array topIndex:index - 1 complete:complete];
        }];
    }
}

+ (void)popToRootViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)viewController popToRootViewControllerAnimated:YES];
    } else if ([viewController isKindOfClass:[UIViewController class]]) {
        [viewController.navigationController popToRootViewControllerAnimated:YES];
    }
}

+ (void)share {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *textToShare = [infoDictionary objectForKey:@"CFBundleDisplayName"] ?: @"app";
    NSURL *urlToShare = [NSURL URLWithString:@"https://apps.apple.com/app/id6451967995"];

    NSArray *activityItems = @[textToShare, urlToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];

    UIViewController *vc = [DeviceInforTool topViewController];
    [vc presentViewController:activityVC animated:YES completion:nil];
    activityVC.completionWithItemsHandler = ^(UIActivityType _Nullable activityType, BOOL completed, NSArray *_Nullable returnedItems, NSError *_Nullable activityError) {

    };
}

@end
