// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <MediaLive/VELCommon.h>
#import "VELPullSettingViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface VELPullSettingCategoryView : UIView <UICollectionViewDataSource>
@property (nonatomic, strong) NSArray <VELPullSettingViewModel *> *settingViewModels;
@end

NS_ASSUME_NONNULL_END
