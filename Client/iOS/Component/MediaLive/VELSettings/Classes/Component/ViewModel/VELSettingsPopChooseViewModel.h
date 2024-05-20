// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsButtonViewModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef BOOL (^VELMenuSelectedBlock)(NSInteger index);
typedef BOOL (^VELMenuModelSelectedBlock)(__kindof VELSettingsBaseViewModel *model, NSInteger index);
@interface VELSettingsPopChooseViewModel : VELSettingsButtonViewModel
@property (nonatomic, strong) NSArray <NSString *> *menuStrings;
@property (nonatomic, strong) NSArray <VELSettingsButtonViewModel *> *menuModels;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong, readonly, nullable) VELSettingsBaseViewModel *selectModel;
@property (nonatomic, strong, readonly, nullable) NSArray <NSNumber *> *menuValues;

@property (nonatomic, strong) NSMutableDictionary *menuHoldTitleAttributes;
@property (nonatomic, strong) UIColor *menuHoldBorderColor;
@property (nonatomic, copy) VELMenuSelectedBlock menuSelectedBlock;
@property (nonatomic, copy) VELMenuModelSelectedBlock menuModelSelectedBlock;
+ (VELSettingsPopChooseViewModel *)createCommonMenuModelWithTitle:(NSString *)title
                                                       menuTitles:(NSArray <NSString *>*)menuTitles
                                                       menuValues:(NSArray <NSNumber *> *)menuValues
                                                      selectBlock:(BOOL (^)(NSInteger index, NSNumber *value))selectBlock;

+ (VELSettingsPopChooseViewModel *)createWhiteCommonMenuModelWithTitle:(NSString *)title
                                                       menuTitles:(NSArray <NSString *>*)menuTitles
                                                       menuValues:(NSArray <NSNumber *> *)menuValues
                                                      selectBlock:(BOOL(^)(NSInteger index, NSNumber *value))selectBlock;
@end

NS_ASSUME_NONNULL_END
