// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef BeautyEffectView_h
#define BeautyEffectView_h

#import <UIKit/UIKit.h>
#import "EffectItem.h"
#import "EffectDataManager.h"
#import "EffectUISlider.h"
#import "BoardBottomView.h"
#import "FaceBeautyViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class BeautyEffectView;
@protocol BeautyEffectDelegate <NSObject>

@optional
- (void)beautyEffect:(BeautyEffectView *)view didSelectedCategory:(EffectUIKitCategoryModel *)category;

- (void)beautyEffect:(BeautyEffectView *)view didSelectedItem:(EffectItem *)item;

- (void)beautyEffect:(BeautyEffectView *)view didUnSelectedItem:(EffectItem *)item;

- (void)beautyEffect:(BeautyEffectView *)view intensityIndexChanged:(NSUInteger)index;


- (nullable FaceBeautyViewController *)beautyEffect:(BeautyEffectView *)view optionVCForItem:(EffectItem *)item;


- (void)beautyEffectOnReset:(BeautyEffectView *)view;

- (void)beautyEffectProgressDidChange:(BeautyEffectView *)sender
                             progress:(CGFloat)progress
                       intensityIndex:(NSInteger)intensityIndex;

- (void)beautyEffectProgressEndChange:(BeautyEffectView *)sender
                             progress:(CGFloat)progress
                       intensityIndex:(NSInteger)intensityIndex;
@end

@protocol BeautyEffectDataSource <NSObject>


@property (nonatomic, strong, readonly, nullable) NSMutableSet<EffectItem *> *selectNodes;


@property (nonatomic, strong, readonly) EffectDataManager *dataManager;
@end


@interface BeautyEffectView : UIView

@property (nonatomic, strong) NSArray <EffectUIKitCategoryModel *> *categories;

@property (nonatomic, weak) id <BeautyEffectDelegate> delegate;

@property (nonatomic, weak) id <BeautyEffectDataSource> dataSource;

@property (nonatomic, strong) NSMutableArray *faceBeautyViewArray;

@property (nonatomic, strong, readonly) EffectUIKitCategoryModel *selectedCategory;

@property (nonatomic, assign, readonly) NSInteger selectIndex;

@property (nonatomic, assign) BOOL showResetButton;

@property (nonatomic, assign) CGFloat bottomMargin;

@property (nonatomic, assign) CGFloat sliderHeight;

@property (nonatomic, assign) CGFloat topTabHeight;

@property (nonatomic, assign) CGFloat boardContentHeight;

@property (nonatomic, assign) CGFloat sliderBottomMargin;

@property (nonatomic, assign) BOOL showVisulEffect;

@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, assign, readonly) NSInteger selectIntensityIndex;


- (void)refreshUI;

- (void)reloadData;

- (void)updateProgressWithItem:(nullable EffectItem *)item;

@end
NS_ASSUME_NONNULL_END

#endif /* BeautyEffectView_h */

