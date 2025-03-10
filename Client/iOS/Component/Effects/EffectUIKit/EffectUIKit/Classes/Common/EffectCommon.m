// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "EffectCommon.h"
#import <sys/utsname.h>
NSString *const EffectUIKitFeature_ar_lipstick = @"feature_ar_lipstick";
NSString *const EffectUIKitFeature_ar_hair_dye = @"feature_ar_hair_dye";
NSString *const EffectUIKit_Filter = @"effect_Filter";
@implementation EffectCommon
+ (BOOL)isNotchScreen {
    BOOL isNotch = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return isNotch;
    }
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    if (mainWindow.safeAreaInsets.bottom > 0.0) {
        isNotch = YES;
    }
    return isNotch;
}

+ (UIEdgeInsets)safeAreaInsets {
    if (![self isNotchScreen]) {
        return UIEdgeInsetsZero;
    }

    NSDictionary<NSNumber *, NSValue *> *value = [self deviceNotchSizeForKey:[self deviceModel]];

    NSNumber *orientationKey = nil;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            orientationKey = @(UIInterfaceOrientationLandscapeLeft);
            break;
        default:
            orientationKey = @(UIInterfaceOrientationPortrait);
            break;
    }

    UIEdgeInsets insets = value[orientationKey].UIEdgeInsetsValue;
    if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        insets = UIEdgeInsetsMake(insets.bottom, insets.left, insets.top, insets.right);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        insets = UIEdgeInsetsMake(insets.top, insets.right, insets.bottom, insets.left);
    }
    return insets;
}

+ (NSString *)deviceModel {
    static NSString *deviceModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct utsname systemInfo;
        uname(&systemInfo);
        deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    });
    return deviceModel;
}

+ (NSDictionary<NSNumber *, NSValue *> *)deviceNotchSizeForKey:(NSString *)key {
    return [[self deviceNotchSize] objectForKey:key] ?: [self defaultDeviceNotchSize];
}

+ (NSDictionary<NSNumber *, NSValue *> *)defaultDeviceNotchSize {
    return [[self deviceNotchSize] objectForKey:@"iPhone14,3"];
}

+ (NSDictionary<NSString *, NSDictionary<NSNumber *, NSValue *> *> *)deviceNotchSize {
    static NSDictionary<NSString *, NSDictionary<NSNumber *, NSValue *> *> *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = @{
            // iPhone 13 mini
            @"iPhone14,4": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(50, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 50, 21, 50)],
            },
            // iPhone 13
            @"iPhone14,5": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            // iPhone 13 Pro
            @"iPhone14,2": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            // iPhone 13 Pro Max
            @"iPhone14,3": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            // iPhone 12 mini
            @"iPhone13,1": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(50, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 50, 21, 50)],
            },
            // iPhone 12
            @"iPhone13,2": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            // iPhone 12 Pro
            @"iPhone13,3": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            // iPhone 12 Pro Max
            @"iPhone13,4": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            // iPhone 11
            @"iPhone12,1": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(48, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 48, 21, 48)],
            },
            // iPhone 11 Pro Max
            @"iPhone12,5": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(44, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 44, 21, 44)],
            }
        };
    });
    return dict;
}

#define EffectUIKitUIBundlePath [NSBundle.mainBundle pathForResource:@"EffectUIKit" ofType:@"bundle"]
#define EffectUIKitUIBundle [NSBundle bundleWithPath:EffectUIKitUIBundlePath]

+ (UIImage *)imageNamed:(NSString *)imageName {
    UIImage *image = nil;
    if (@available(iOS 13.0, *)) {
        image = [UIImage imageNamed:imageName inBundle:EffectUIKitUIBundle withConfiguration:nil];
    }
    image = [UIImage imageNamed:imageName inBundle:EffectUIKitUIBundle compatibleWithTraitCollection:nil];
    if (image == nil) {
        image = [UIImage imageNamed:imageName];
    }
    return image;
}

+ (UIViewController *)topViewController {
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
+ (UIViewController *)topViewControllerForResponder:(UIResponder *)view {
    UIViewController *topVC;
    UIResponder *responder = view;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            topVC = (UIViewController *)responder;
            break;
        }
        responder = [responder nextResponder];
    }
    return topVC ?: [self topViewController];
}
@end
