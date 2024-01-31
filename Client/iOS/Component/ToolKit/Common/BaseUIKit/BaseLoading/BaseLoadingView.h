// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>



@interface BaseLoadingView : UIView

+ (instancetype)sharedInstance;

- (void)startLoadingIn:(UIView *)view;
- (void)stopLoading;

@end

