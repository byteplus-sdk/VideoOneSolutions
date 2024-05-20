// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VELSwitchTabPosition) {
    VELSwitchTabPositionCenter,
    VELSwitchTabPositionExpand,
    VELSwitchTabPositionLeft, /// default
};

@interface VELSwitchIndicatorLineStyle : NSObject

@property (nonatomic, assign) NSInteger bottomMargin;
@property (nonatomic, assign) CGFloat widthRatio;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong) UIColor *backgroundColor;

@end

@protocol VELSwitchTabViewDelegate <NSObject>

- (void)switchTabDidSelectedAtIndex:(NSInteger)index;

@end
@interface VELSwitchTabView: UIView <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, weak) id<VELSwitchTabViewDelegate> delegate;
@property (nonatomic, readonly) NSInteger selectedIndex;
@property (nonatomic, assign) float proportion;
@property (nonatomic, copy) NSArray *categories;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSDictionary *categoryNameDict;
@property (nonatomic, strong) UIView *indicatorLine;
@property (nonatomic, strong) VELSwitchIndicatorLineStyle *indicatorLineStyle;
@property (nonatomic, assign) VELSwitchTabPosition position;
@property (nonatomic, strong) UIColor *hightlightTextColor;
@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, assign) CGFloat itemMargin;
- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated;


- (instancetype)initWithTitles:(NSArray *)categories;
- (void)refreshWithTitles:(NSArray *)categories;

- (void)reloadData;

@end
