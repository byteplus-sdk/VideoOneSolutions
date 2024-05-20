// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "VELSettingsPullInputViewModel.h"
#import "VELPullSettingConfig.h"
#import "VELSettingsSliderInputViewModel.h"
#import "VELSettingsSwitchViewModel.h"
#import "VELSettingsPopChooseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELPullSettingViewModelTool : NSObject
@property (nonatomic, strong) VELPullSettingConfig *config;
@property (nonatomic, strong) VELSettingsPullInputViewModel *inputViewModel;

/// ABRdnsViewModel
@property (nonatomic, strong) VELSettingsSwitchViewModel *abrViewModel;
@property (nonatomic, strong) VELSettingsSwitchViewModel *resolutionDegradeViewModel;
@property (nonatomic, strong) VELSettingsPopChooseViewModel *protocolViewModel;
@property (nonatomic, strong) VELSettingsPopChooseViewModel *formatViewModel;
@property (nonatomic, strong) VELSettingsSwitchViewModel *seiViewModel;
@property (nonatomic, strong) VELSettingsSwitchViewModel *rtmAutoDowngradeViewModel;

- (void)refreshUIWithModelConfigChanged;
@end

NS_ASSUME_NONNULL_END
