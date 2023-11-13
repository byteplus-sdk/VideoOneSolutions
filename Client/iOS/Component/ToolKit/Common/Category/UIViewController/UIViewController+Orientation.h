// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Orientation)

- (void)setDeviceInterfaceOrientation:(UIDeviceOrientation)orientation;

- (void)addOrientationNotice;

- (void)orientationDidChang:(BOOL)isLandscape;

@end

NS_ASSUME_NONNULL_END
