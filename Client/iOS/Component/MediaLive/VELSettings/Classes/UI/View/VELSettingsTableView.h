// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "VELSettingsBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELSettingsTableView : UIView
@property (nonatomic, strong) NSArray <__kindof VELSettingsBaseViewModel *> *models;
@property(nonatomic, copy) void (^selectedItemBlock)(__kindof VELSettingsBaseViewModel *model, NSInteger index);
@property(nonatomic, copy) void (^deleteItemBlock)(__kindof VELSettingsBaseViewModel *model, NSInteger index);
@property (nonatomic, assign) BOOL allowSelection;
@property (nonatomic, assign) BOOL allowDelete;

@property(nonatomic, assign) BOOL showsVerticalScrollIndicator;

@property(nonatomic, assign) BOOL showsHorizontalScrollIndicator;

/// first session header
@property (nonatomic, strong) UIView *header;

@property (nonatomic, assign) CGFloat headerHeight;
- (void)selecteIndex:(NSInteger)index animation:(BOOL)animation;
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
