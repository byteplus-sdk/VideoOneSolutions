// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, VELScreenOrientation) {
    VELScreenOrientationLandscapeAndPortrait = 1,
    VELScreenOrientationLandscape,
    VELScreenOrientationPortrait,
};

@interface UIViewController (VELAdd)
- (UIViewController *)vel_visibleViewController;
- (BOOL)vel_isViewLoadedAndVisible;
+ (UIViewController *)vel_topViewController;
@end

NS_ASSUME_NONNULL_END
