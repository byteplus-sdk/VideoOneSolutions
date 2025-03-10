// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

#import "EffectItem.h"
#import "EffectDataManager.h"
#import "FaceBeautyView.h"

@class FaceBeautyViewController;
@protocol FaceBeautyViewControllerDelegate <NSObject>

- (void)faceBeautyViewController:(FaceBeautyViewController *)vc didClickBack:(UIView *)sender;

- (void)faceBeautyViewController:(FaceBeautyViewController *)vc didClickItem:(EffectItem *)item;
@end

@interface FaceBeautyViewController : UIViewController <FaceBeautyViewDelegate>

@property (nonatomic, weak) id<FaceBeautyViewControllerDelegate> delegate;
@property (nonatomic, weak) UIView *placeholderView;
@property (nonatomic, weak) UIView *removeTitlePlaceholderView;
@property (nonatomic, strong) FaceBeautyView *beautyView;
// protected
@property (nonatomic, assign) EffectItem *item;

@property (nonatomic, strong) EffectUIKitCategoryModel *categoryModel;

@property (nonatomic, strong) UILabel *lTitle;
@property (nonatomic, strong) UIButton *btnBack;
@property (nonatomic, strong) NSString *titleType;

- (void)addToView:(UIView *)view;
- (void)removeFromView;

- (void)showPlaceholder:(BOOL)show;

- (void)showTitlePlaceholder:(BOOL)show;

- (void)faceBeautyViewArray:(NSMutableArray *)viewArray;

- (void)setItem:(EffectItem *)item;

- (void)setSelectNodes:(NSMutableSet<EffectItem *> *)selectNodes dataManager:(EffectDataManager *)dataManager;

// protected
- (void)refreshWithNewItem:(EffectItem *)item;
- (void)reloadData;
@end
