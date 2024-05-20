// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "VELToastView.h"
NS_ASSUME_NONNULL_BEGIN
@interface VELUIToast : VELToastView
+ (void)setTemporaryShowView:(nullable UIView *)view;
+ (void)setTemporaryLoadingShowView:(nullable UIView *)view;

+ (VELUIToast *)showLoading:(nullable NSString *)text;

+ (VELUIToast *)showLoading:(nullable NSString *)text inView:(UIView *)view;

+ (VELUIToast *)showLoading:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (VELUIToast *)showLoading:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;

+ (VELUIToast *)showLoading:(nullable NSString *)text
                 detailText:(nullable NSString *)detailText
                     inView:(nullable UIView *)view
             hideAfterDelay:(NSTimeInterval)delay;

+ (VELUIToast *)showText:(nullable NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

+ (VELUIToast *)showText:(nullable NSString *)text
                  inView:(nullable UIView *)view;

+ (VELUIToast *)showText:(nullable NSString *)text
              detailText:(nullable NSString *)detailText;

+ (VELUIToast *)showText:(NSString *)text
              detailText:(NSString *)detailText
                  inView:(nullable UIView *)view
          hideAfterDelay:(NSTimeInterval)delay;

+ (void)hideAllToastInView:(nullable UIView *)view;
+ (void)hideAllToast;
+ (void)hideAllLoadingView;

@end
NS_ASSUME_NONNULL_END
