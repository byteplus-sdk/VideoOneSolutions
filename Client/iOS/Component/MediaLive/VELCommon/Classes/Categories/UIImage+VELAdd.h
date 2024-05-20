// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (VELAdd)
- (UIImage *)vel_imageByTintColor:(UIColor *)color;
+ (UIImage *)vel_imageNamed:(NSString *)imageName;
+ (UIImage *)vel_imageWithColor:(UIColor *)color;
+ (UIImage *)vel_imageWithColor:(UIColor *)color size:(CGSize)size;
- (UIImage *)vel_imageByRoundCornerRadius:(CGFloat)radius;
- (UIImage *)vel_imageByRoundCornerRadius:(CGFloat)radius
                              borderWidth:(CGFloat)borderWidth
                              borderColor:(nullable UIColor *)borderColor;

@end

NS_ASSUME_NONNULL_END
