// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#define  GLOBISSAVE  1
FOUNDATION_EXTERN NSString *const EffectUIKitFeature_ar_lipstick;
FOUNDATION_EXTERN NSString *const EffectUIKitFeature_ar_hair_dye;

FOUNDATION_EXTERN NSString *const EffectUIKit_Filter;

@interface EffectCommon : NSObject
+ (UIEdgeInsets)safeAreaInsets;
+ (UIImage *)imageNamed:(NSString *)imageName;
+ (UIViewController *)topViewController;
+ (UIViewController *)topViewControllerForResponder:(UIResponder *)view;
@end
