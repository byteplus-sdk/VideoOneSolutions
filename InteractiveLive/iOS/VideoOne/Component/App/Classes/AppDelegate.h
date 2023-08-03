// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, ScreenOrientation) {
    ScreenOrientationLandscapeAndPortrait = 1,
    ScreenOrientationLandscape,
    ScreenOrientationPortrait,
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, assign) ScreenOrientation screenOrientation;

@end

NS_ASSUME_NONNULL_END
