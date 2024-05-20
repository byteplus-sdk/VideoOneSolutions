// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPopupContainerView.h"
#import "VELPopupMenuButtonItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface VELPopupMenuView : VELPopupContainerView
@property(nonatomic, assign) BOOL shouldShowItemSeparator;
@property(nonatomic, strong, nullable) UIColor *itemSeparatorColor;
@property(nonatomic, assign) UIEdgeInsets itemSeparatorInset;
@property(nonatomic, assign) BOOL shouldShowSectionSeparator;
@property(nonatomic, strong, nullable) UIColor *sectionSeparatorColor;
@property(nonatomic, assign) UIEdgeInsets sectionSeparatorInset;
@property(nonatomic, strong, nullable) UIFont *itemTitleFont;
@property(nonatomic, strong, nullable) UIColor *itemTitleColor;
@property(nonatomic, assign) UIEdgeInsets padding;
@property(nonatomic, assign) CGFloat itemHeight;
@property(nonatomic, copy, nullable) void (^itemConfigurationHandler)(VELPopupMenuView *aMenuView, __kindof VELPopupMenuBaseItem *aItem, NSInteger section, NSInteger index);
@property(nonatomic, copy, nullable) void (^willHandleButtonItemEventBlock)(VELPopupMenuView *aMenuView, __kindof VELPopupMenuButtonItem *aItem, NSInteger section, NSInteger index);
@property(nonatomic, copy, nullable) NSArray<__kindof VELPopupMenuBaseItem *> *items;
@property(nonatomic, copy, nullable) NSArray<NSArray<__kindof VELPopupMenuBaseItem *> *> *itemSections;
@end

NS_ASSUME_NONNULL_END
