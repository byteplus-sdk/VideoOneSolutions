// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsInputViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELSettingsInputActionViewModel : VELSettingsInputViewModel


@property (nonatomic, strong) NSMutableDictionary <NSAttributedStringKey, id> *btnTitleAttributes;

@property (nonatomic, strong) NSMutableDictionary <NSAttributedStringKey, id> *selectBtnTitleAttributes;
@property (nonatomic, copy) NSString *leftTitle;
@property (nonatomic, strong) NSMutableDictionary *leftTitleAttribute;
@property (nonatomic, copy, nullable) NSString *btnTitle;
@property (nonatomic, copy, nullable) NSString *selectBtnTitle;
@property (nonatomic, assign) CGFloat textFieldHeight;
@property (nonatomic, assign) CGSize btnSize;
@property (nonatomic, assign) UIKeyboardType keyboardType;
@property (nonatomic, strong) UIColor *textFiledContainerBgColor;
@property (nonatomic, strong) UIColor *actionBtnBgColor;
@property (nonatomic, assign) BOOL showActionBtn;
@property (nonatomic, copy) void (^sendBtnActionBlock)(VELSettingsInputActionViewModel *model, BOOL send);
@end

NS_ASSUME_NONNULL_END
