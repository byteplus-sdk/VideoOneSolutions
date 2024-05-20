// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsButtonViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELSettingsPickerViewModel : VELSettingsButtonViewModel
@property (nonatomic, strong) NSArray <NSString *> *menuStrings;
@property (nonatomic, strong) NSArray <VELSettingsButtonViewModel *> *menuModels;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong, readonly, nullable) VELSettingsBaseViewModel *selectModel;
@property (nonatomic, strong) NSMutableDictionary *menuHoldTitleAttributes;
@property (nonatomic, copy) void (^menuSelectedBlock)(NSInteger index);
@property (nonatomic, copy) void (^menuModelSelectedBlock)(__kindof VELSettingsBaseViewModel *model, NSInteger index);
@end

NS_ASSUME_NONNULL_END
