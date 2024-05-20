// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <MediaLive/VELCommon.h>
#import "VELSettingsBaseViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface VELSettingsPopupMenuView : VELPopupContainerView
@property (nonatomic, strong) NSArray <__kindof VELSettingsBaseViewModel *> *menuModels;
@property (nonatomic, assign) NSInteger selectIndex;
@property(nonatomic, copy) void (^didSelectedModelBlock)(VELSettingsPopupMenuView *menuView, __kindof VELSettingsBaseViewModel * model, NSInteger index);
@end

NS_ASSUME_NONNULL_END
