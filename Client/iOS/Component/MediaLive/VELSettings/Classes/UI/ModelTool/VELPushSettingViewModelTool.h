// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "VELPushSettingConfig.h"
#import "VELSettingsInputViewModel.h"
#import "VELSettingsPopChooseViewModel.h"
#import "VELSettingsSliderInputViewModel.h"
#import "VELSettingsSwitchViewModel.h"
#import "VELSettingsInputActionViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELPushSettingViewModelTool : NSObject
@property (nonatomic, strong) VELPushSettingConfig *config;
@property (nonatomic, strong) VELSettingsInputViewModel *inputViewModel;
@property (nonatomic, strong) VELSettingsPopChooseViewModel *captureResolutionViewModel;
@property (nonatomic, strong) VELSettingsPopChooseViewModel *captureFPSViewModel;
@property (nonatomic, strong) VELSettingsPopChooseViewModel *encodeResolutionAndScreenViewModel;
@property (nonatomic, strong) VELSettingsPopChooseViewModel *encodeResolutionViewModel;
@property (nonatomic, strong) VELSettingsPopChooseViewModel *encodeFPSViewModel;

@property (nonatomic, strong) VELSettingsSwitchViewModel *fixScreenCaptureVideoAudioDiffViewModel;
@property (nonatomic, strong) VELSettingsSliderInputViewModel *encodeBitrateViewModel;
@property (nonatomic, strong) VELSettingsSwitchViewModel *enableAutoBitrateViewModel;
@property (nonatomic, strong) VELSettingsPopChooseViewModel *audioCaptureSampleRateViewModel;
@property (nonatomic, strong) VELSettingsPopChooseViewModel *renderModeViewModel;
@end



NS_ASSUME_NONNULL_END
