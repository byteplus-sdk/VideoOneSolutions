// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "VELSettingsBaseViewModel.h"
#import <MediaLive/VELCommon.h>
NS_ASSUME_NONNULL_BEGIN

@interface VELSettingsCollectionView : UIView
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat itemMargin;
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic, assign) VELCollectionViewLayoutMode layoutMode;
@property (nonatomic, strong) NSArray <__kindof VELSettingsBaseViewModel *> *models;
@property (nonatomic, assign) BOOL allowSelection;
@property (nonatomic, assign) NSInteger numberOfColumns;
@property(nonatomic, copy) void (^selectedItemBlock)(__kindof VELSettingsBaseViewModel *model, NSInteger index);
- (void)selecteIndex:(NSInteger)index animation:(BOOL)animation;
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
