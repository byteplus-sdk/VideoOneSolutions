// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UINavigationController (VEL_Gesture)
@property (nonatomic, strong, nullable) id vel_interactiveDelegator;
- (void)vel_setupNavGesture;
- (void)vel_destroyNavGesture;
@end

@interface VELUINavigationController : UINavigationController

@end

NS_ASSUME_NONNULL_END
