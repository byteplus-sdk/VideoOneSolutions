// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "EffectSwitchTabView.h"
@class EffectCategoryView;
@protocol EffectUIKitCategoryViewDelegate <NSObject>

- (void)categoryView:(EffectCategoryView *)categoryView willSelectIndex:(NSInteger)index;

- (void)categoryView:(EffectCategoryView *)categoryView didSelectIndex:(NSInteger)index;

- (void)categoryView:(EffectCategoryView *)categoryView willDeSelectIndex:(NSInteger)index;

- (void)categoryView:(EffectCategoryView *)categoryView didDeSelectIndex:(NSInteger)index;
@end

@interface EffectCategoryView : UIView

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated;
- (EffectSwitchTabView *)switchTabView;
@property (nonatomic, weak) id<EffectUIKitCategoryViewDelegate> delegate;
@property (nonatomic, weak) id<EffectUIKitSwitchTabViewDelegate> tabDelegate;
@property (nonatomic, strong) NSArray *indicators;
@property (nonatomic, strong) UICollectionView *contentView;
@property (nonatomic, assign) NSInteger  selectIndex;
@property (nonatomic, assign) CGFloat  tabHeight;

@property (nonatomic, assign) BOOL showTabBottomLine;

@property (nonatomic, assign) UIEdgeInsets contentInset;

@property (nonatomic, assign) UIEdgeInsets tabInset;
- (void)reloadData;
@end
