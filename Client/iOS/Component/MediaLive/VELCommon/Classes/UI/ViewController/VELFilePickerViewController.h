// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELUIViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELFilePickerViewController : VELUIViewController
+ (VELFilePickerViewController *)showFromVC:(nullable UIViewController *)vc
                                  fileTypes:(NSArray <NSString *>*)fileTypes
                                  completion:(void (^)(VELFilePickerViewController *vc, NSArray <NSString *>* files))completion;
- (void)hide;
@end

NS_ASSUME_NONNULL_END
