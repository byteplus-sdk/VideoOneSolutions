// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface VELSettingPushACfgViewModel : VELSettingsBaseViewModel
@property (nonatomic, assign) BOOL enableAudioEcho;
@property (nonatomic, assign) BOOL isSupportAudioEcho;
@property (nonatomic, assign) float audioLoudness;
@property(nonatomic, copy) void (^enableAudioFrameListenerBlock)(VELSettingPushACfgViewModel *m, BOOL enable);
@property(nonatomic, copy) void (^enableAudioFilterBlock)(VELSettingPushACfgViewModel *m, BOOL enable);
@property(nonatomic, copy) void (^enableMuteAudioFrameBlock)(VELSettingPushACfgViewModel *m, BOOL enable);
@property(nonatomic, copy) void (^enableAudioEchoBlock)(VELSettingPushACfgViewModel *m, BOOL enable);
@property(nonatomic, copy) void (^audioLoudnessValueChangedBlock)(VELSettingPushACfgViewModel *m, float value);
@end

NS_ASSUME_NONNULL_END
