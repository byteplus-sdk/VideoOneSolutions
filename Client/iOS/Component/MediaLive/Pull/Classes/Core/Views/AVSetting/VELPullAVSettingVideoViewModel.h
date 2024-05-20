// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullSettingViewModel.h"
#import "VELPullAVSettingDelegate.h"
#import <MediaLive/VELSettings.h>
NS_ASSUME_NONNULL_BEGIN

@interface VELPullAVSettingVideoViewModel : VELPullSettingViewModel
@property (nonatomic, strong) VELSettingsButtonViewModel *snapShotViewModel;
@property(nonatomic, weak) id <VELPullAVSettingDelegate> delegate;
- (void)resetAVSettings;
@end

NS_ASSUME_NONNULL_END
