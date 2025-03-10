// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef ColorListAdapter_h
#define ColorListAdapter_h

#import <UIKit/UIKit.h>
#import "EffectColorItem.h"

@class ColorListAdapter;
@protocol ColorListAdapterDelegate <NSObject>

- (void)colorListAdapter:(ColorListAdapter *)adapter didSelectedAt:(NSInteger)index;

@end

@interface ColorListAdapter : NSObject

- (instancetype)initWithColorset:(NSArray<EffectColorItem *> *)colorset;

- (void)refreshWith:(NSArray<EffectColorItem *> *)colorset;

- (void)selectItem:(NSInteger)index;

- (void)addToContainer:(UIView *)container placeholder:(UIView *)placeholder;

@property (nonatomic, weak) id<ColorListAdapterDelegate> delegate;
@property (nonatomic, readonly) UICollectionView *collectionView;

@end

#endif /* ColorListAdapter_h */
