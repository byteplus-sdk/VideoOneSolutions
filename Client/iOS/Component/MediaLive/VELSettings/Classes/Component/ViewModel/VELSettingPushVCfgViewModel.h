// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsBaseViewModel.h"
#import "VELPushSettingConfig.h"
NS_ASSUME_NONNULL_BEGIN
@interface VELSettingPushVCfgViewModel : VELSettingsBaseViewModel
@property (nonatomic, assign) int fps;
@property (nonatomic, assign) VELSettingResolutionType resolutionType;
@property (nonatomic, copy) void (^videoResolutionChanged)(VELSettingResolutionType resolutionType);
@property (nonatomic, copy) void (^videoFpsChanged)(int fps);
@end

NS_ASSUME_NONNULL_END
