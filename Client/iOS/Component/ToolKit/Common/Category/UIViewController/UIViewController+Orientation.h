// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Orientation)

@property (nonatomic, assign, readonly) BOOL isLandscape;

- (void)setDeviceInterfaceOrientation:(UIInterfaceOrientation)orientation;

- (void)addOrientationNotice;

- (void)orientationDidChang:(BOOL)isLandscape;

@end

NS_ASSUME_NONNULL_END
