// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELSettingsSwitchViewModel : VELSettingsBaseViewModel
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSMutableDictionary *titleAttribute;
@property (nonatomic, copy) NSString *des;
@property (nonatomic, assign, getter=isOn) BOOL on;
@property (nonatomic, copy) void (^switchBlock)(BOOL isOn);

@property (nonatomic, copy) void (^switchModelBlock)(VELSettingsSwitchViewModel *model, BOOL isOn);
@property (nonatomic, assign) BOOL convertToBtn;

@property (nonatomic, assign) CGSize switchSize;
@property (nonatomic, copy) NSString *btnTitle;
@property (nonatomic, strong) UIColor *onTintColor;
/// UIColor.whiteColor
@property (nonatomic, strong) UIColor *onBorderColor;
/// UIColor.whiteColor
@property (nonatomic, strong) UIColor *onThumbColor;
/// [[UIColor blackColor] colorWithAlphaComponent:0.7]
@property (nonatomic, strong) UIColor *offTintColor;
/// VELColorWithHexString(@"#636363")
@property (nonatomic, strong) UIColor *offBorderColor;
/// VELColorWithHexString(@"#636363")
@property (nonatomic, strong) UIColor *offThumbColor;
@property (nonatomic, assign) BOOL lightStyle;
@end



NS_ASSUME_NONNULL_END
