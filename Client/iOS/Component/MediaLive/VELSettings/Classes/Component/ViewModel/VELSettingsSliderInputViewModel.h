// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELSettingsSliderInputViewModel : VELSettingsBaseViewModel
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSMutableDictionary *titleAttribute;
@property (nonatomic, copy) NSString *leftText;
@property (nonatomic, copy) NSString *rightText;
@property (nonatomic, strong) NSMutableDictionary *textAttribute;
@property (nonatomic, assign) BOOL showInput;
@property (nonatomic, assign) BOOL hideSlider;
@property (nonatomic, strong) UIColor *inputBgColor;
@property (nonatomic, assign) UIEdgeInsets inputOutset;
@property (nonatomic, assign) CGSize inputSize;
@property (nonatomic, strong) NSMutableDictionary *inputTextAttribute;
@property (nonatomic, strong) UIColor *minimumTrackColor;
@property (nonatomic, strong) UIColor *maximumTrackColor;
@property (nonatomic, strong) UIColor *thumbColor;

@property (nonatomic, strong) UIColor *disableThumbColor;
@property (nonatomic, assign) CGFloat spaceBetweenTitleAndField;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGFloat minimumValue;
@property (nonatomic, assign) CGFloat maximumValue;
@property(nonatomic, copy) void (^valueChangedBlock)(VELSettingsSliderInputViewModel *model);
@property (nonatomic, copy) NSString *valueFormat;
@end

NS_ASSUME_NONNULL_END
