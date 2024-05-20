// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELUIViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELImagePickerViewController : VELUIViewController
+ (VELImagePickerViewController *)showFromVC:(nullable UIViewController *)vc
                                  completion:(void (^)(VELImagePickerViewController *vc, NSArray <UIImage *>* images))completion;
- (void)hide;
@end

NS_ASSUME_NONNULL_END
