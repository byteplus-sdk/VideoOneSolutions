// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingConfig.h"
#import <MediaLive/VELCore.h>
#define VEL_NEW_API_CACHE_KEY @"vel_config_new_api"
#define VEL_PULL_NEW_API_CACHE_KEY @"vel_config_pull_new_api"
#define VEL_PUSH_NEW_API_CACHE_KEY @"vel_config_push_new_api"
#define VEL_LOG_DEBUG_CACHE_KEY @"vel_config_log_debug"
#define VEL_LOG_DEBUG_CUSTOM_DATA_KEY @"vel_config_log_custom_data"
#define VEL_EFFECT_ONLINE_LICENSE_KEY @"vel_online_effect_license"
@interface VELSettingConfig ()
@property (nonatomic, strong, readwrite) VELPushSettingConfig *pushConfig;
@property (nonatomic, strong, readwrite) VELPullSettingConfig *pullConfig;
@property (nonatomic, assign, getter=isPushNewApi) BOOL pushNewApi;
@property (nonatomic, assign, getter=isPullNewApi) BOOL pullNewApi;
@end
@implementation VELSettingConfig
+ (instancetype)sharedConfig {
    static dispatch_once_t onceToken;
    static VELSettingConfig *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self recoverSettingConfig];
    }
    return self;
}

- (void)recoverSettingConfig {
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:VEL_NEW_API_CACHE_KEY];
    if (obj) {
        _newApi = [obj boolValue];
    } else {
        _newApi = YES;
    }
    
    _logDebug = [[NSUserDefaults standardUserDefaults] boolForKey:VEL_LOG_DEBUG_CACHE_KEY];
    _customLogData = [[NSUserDefaults standardUserDefaults] objectForKey:VEL_LOG_DEBUG_CUSTOM_DATA_KEY];
    _pushNewApi = _newApi;
    _pullNewApi = _newApi;
    
    [self recoverPullConfig];
    [self recoverPushConfig];
}

- (void)recoverPullConfig {
    self.pullConfig = [VELPullSettingConfig loadFromLocalWithIdentifier:[NSString stringWithFormat:@"new_api_%d", self.isPullNewApi]];
    self.pullConfig.newApi = self.newApi || self.isPullNewApi;
}

- (void)recoverPushConfig {
    self.pushConfig = [VELPushSettingConfig loadFromLocalWithIdentifier:[NSString stringWithFormat:@"new_api_%d", self.isPushNewApi]];
    self.pushConfig.newApi = self.newApi || self.isPushNewApi;
}

- (void)setNewApi:(BOOL)newApi {
    _newApi = newApi;
    [[NSUserDefaults standardUserDefaults] setBool:newApi forKey:VEL_NEW_API_CACHE_KEY];
    [self setPullNewApi:newApi];
    [self setPushNewApi:newApi];
}

- (void)setLogDebug:(BOOL)logDebug {
    _logDebug = logDebug;
    [[NSUserDefaults standardUserDefaults] setBool:logDebug forKey:VEL_LOG_DEBUG_CACHE_KEY];
}


- (void)setCustomLogData:(NSString *)customLogData {
    _customLogData = customLogData.copy;
    [[NSUserDefaults standardUserDefaults] setObject:customLogData forKey:VEL_LOG_DEBUG_CUSTOM_DATA_KEY];
}
- (void)setPullNewApi:(BOOL)pullNewApi {
    [self.pullConfig save];
    _pullNewApi = pullNewApi;
    [[NSUserDefaults standardUserDefaults] setObject:@(pullNewApi) forKey:VEL_PULL_NEW_API_CACHE_KEY];
    [self recoverPullConfig];
}
- (void)setPushNewApi:(BOOL)pushNewApi {
    [self.pushConfig save];
    _pushNewApi = pushNewApi;
    [[NSUserDefaults standardUserDefaults] setObject:@(pushNewApi) forKey:VEL_PUSH_NEW_API_CACHE_KEY];
    [self recoverPushConfig];
}
- (VELPushSettingConfig *)getPushSettingConfigWithCaptureType:(VELSettingCaptureType)captureType {
    VELPushSettingConfig *cfg = [VELPushSettingConfig loadFromLocalWithIdentifier:[NSString stringWithFormat:@"new_api_%@_%@", @(captureType), @(self.isPushNewApi)]];
    cfg.newApi = self.isPushNewApi;
    if (!cfg.fromLocal && captureType == VELSettingCaptureTypeFile) {
        cfg.renderMode = VELSettingPreviewRenderModeFit;
    }
    return cfg;
}
@end
