// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (VELAdd)
/// - Parameter hexString: 0xffffff, #ffffff
+ (instancetype)vel_colorWithHexString:(NSString *)hexString;


+ (UIColor *)vel_colorFromRGBHexString:(NSString *)hexString;

+ (UIColor *)vel_colorFromRGBHexString:(NSString *)hexString andAlpha:(NSInteger)alpha;

+ (UIColor *)vel_colorFromRGBAHexString:(NSString *)hexString;

+ (UIColor *)vel_colorFromHexString:(NSString *)hexString;

+ (UIColor *)vel_randomColor;

+ (NSString *)vel_randomHexColor;
@end

NS_ASSUME_NONNULL_END
