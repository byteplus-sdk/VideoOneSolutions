// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELUIViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELQRScanViewController : VELUIViewController
+ (VELQRScanViewController *)showFromVC:(nullable UIViewController *)vc completion:(void (^)(VELQRScanViewController *vc, NSString *result))completion;

- (void)hide;
@end

NS_ASSUME_NONNULL_END
