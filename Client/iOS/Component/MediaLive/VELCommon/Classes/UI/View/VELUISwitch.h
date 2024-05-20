// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VELUISwitch : UIControl
/// VELColorWithHexString(@"#35C75A")
@property (nonatomic, strong) UIColor *onTintColor;
/// VELColorWithHexString(@"#35C75A")
@property (nonatomic, strong) UIColor *onThumbTintColor;
/// VELColorWithHexString(@"#35C75A")
@property (nonatomic, strong) UIColor *onBorderColor;

/// VELColorWithHexString(@"#E0DEDE")
@property (nonatomic, strong) UIColor *offTintColor;
/// VELColorWithHexString(@"#E0DEDE")
@property (nonatomic, strong) UIColor *offThumbTintColor;
/// VELColorWithHexString(@"#E0DEDE")
@property (nonatomic, strong) UIColor *offBorderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, getter=isOn) BOOL on;

@end


NS_ASSUME_NONNULL_END
