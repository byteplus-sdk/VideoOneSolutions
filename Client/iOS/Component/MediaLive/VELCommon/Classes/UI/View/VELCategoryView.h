// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "VELSwitchTabView.h"
@class VELCategoryView;
@protocol VELCategoryViewDelegate <NSObject>

- (void)categoryView:(VELCategoryView *)categoryView willSelectIndex:(NSInteger)index;

- (void)categoryView:(VELCategoryView *)categoryView didSelectIndex:(NSInteger)index;

- (void)categoryView:(VELCategoryView *)categoryView willDeSelectIndex:(NSInteger)index;

- (void)categoryView:(VELCategoryView *)categoryView didDeSelectIndex:(NSInteger)index;
@end

@interface VELCategoryView : UIView

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated;
- (VELSwitchTabView *)switchTabView;
@property (nonatomic, weak) id<VELCategoryViewDelegate> delegate;
@property (nonatomic, weak) id<VELSwitchTabViewDelegate> tabDelegate;
@property (nonatomic, strong) NSArray *indicators;
@property (nonatomic, strong) UICollectionView *contentView;
@property (nonatomic, assign) NSInteger  selectIndex;
@property (nonatomic, assign) CGFloat  tabHeight;
@property (nonatomic, assign) BOOL showTabBottomLine;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) UIEdgeInsets tabInset;
- (void)reloadData;
@end
