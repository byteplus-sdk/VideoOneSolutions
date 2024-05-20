// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VELDeviceRotateHelper : NSObject
+ (UIInterfaceOrientationMask)supportInterfaceMask;
+ (void)setSupportInterfaceMask:(UIInterfaceOrientationMask)interfaceMask;
+ (BOOL)rotateToDeviceOrientation:(UIDeviceOrientation)orientation;
+ (UIDeviceOrientation)currentDeviceOrientation;
+ (void)autoRotateWhenViewWillAppear;
@end

NS_ASSUME_NONNULL_END
