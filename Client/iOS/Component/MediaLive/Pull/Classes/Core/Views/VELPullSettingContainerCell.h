// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import <MediaLive/VELSettings.h>
#import <MediaLive/VELCore.h>
#import "VELPullSettingViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface VELPullSettingContainerCell : UICollectionViewCell
@property (nonatomic, strong) __kindof VELPullSettingViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
