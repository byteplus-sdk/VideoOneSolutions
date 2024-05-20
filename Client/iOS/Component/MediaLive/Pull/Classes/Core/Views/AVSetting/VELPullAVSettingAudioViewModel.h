// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullSettingViewModel.h"
#import "VELPullAVSettingDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface VELPullAVSettingAudioViewModel : VELPullSettingViewModel
@property (nonatomic, strong) VELSettingsButtonViewModel *muteViewModel;
@property (nonatomic, strong) VELSettingsSliderInputViewModel *volumeViewModel;
@property(nonatomic, weak) id <VELPullAVSettingDelegate> delegate;
@property (nonatomic, assign) float currentVolume;
@end

NS_ASSUME_NONNULL_END
