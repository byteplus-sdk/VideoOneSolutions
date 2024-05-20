// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "VELPullSettingConfig.h"
#import "VELPushSettingConfig.h"
NS_ASSUME_NONNULL_BEGIN
#define VEL_SHARE_SETTING_CONFG VELSettingConfig.sharedConfig
#define VEL_PUSH_CONFIG VELSettingConfig.sharedConfig.pushConfig
#define VEL_PULL_CONFIG VELSettingConfig.sharedConfig.pullConfig

@interface VELSettingConfig : NSObject
@property (nonatomic, assign, getter=isNewApi) BOOL newApi;
@property (nonatomic, assign) BOOL logDebug;
@property (nonatomic, copy, nullable) NSString *customLogData;
@property (nonatomic, strong, readonly) VELPullSettingConfig *pullConfig;
+ (instancetype)sharedConfig;
- (VELPushSettingConfig *)getPushSettingConfigWithCaptureType:(VELSettingCaptureType)captureType;
@end

NS_ASSUME_NONNULL_END
