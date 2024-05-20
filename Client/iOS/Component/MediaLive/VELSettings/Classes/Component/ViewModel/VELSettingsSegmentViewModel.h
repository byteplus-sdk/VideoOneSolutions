// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsButtonViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface VELSettingsSegmentViewModel : VELSettingsButtonViewModel
@property (nonatomic, assign) CGFloat spacingBetweenTitleAndSegments;
@property (nonatomic, assign) CGFloat itemMargin;
@property (nonatomic, strong) NSArray <NSString *> *segmentStrings;
@property (nonatomic, strong) NSArray <VELSettingsButtonViewModel *> *segmentModels;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong, readonly, nullable) VELSettingsBaseViewModel *selectModel;
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic, copy) void (^segmentSelectedBlock)(NSInteger index);

@property (nonatomic, copy) void (^segmentModelSelectedBlock)(__kindof VELSettingsBaseViewModel *model, NSInteger index);
@property (nonatomic, assign) BOOL disableSelectd;
@end

NS_ASSUME_NONNULL_END
