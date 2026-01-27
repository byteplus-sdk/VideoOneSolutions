// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VodSingleFunction.h"
#import "VESettingModel.h"
#import "VESettingManager.h"
#import <AppConfig/BuildConfig.h>
#import <TTSDKFramework/TTSDKFramework.h>

@implementation VodSingleFunction

+ (void)prepareEnvironment {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupTTSDK];
    });
}

+ (void)setupTTSDK {
    #ifdef DEBUG
    [TTVideoEngine setLogFlag:TTVideoEngineLogFlagAll];
    #endif
    
    VESettingModel *abr = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalABRConfig];
    if (abr.open) {
        VOLogI(VOVideoPlayback, @"init abr function before init TTSDK");
        [TTVideoEngine setGlobalForKey:VEGSKeyAlgoOptionEnableModuleBandwidth value:@(YES)];
        [TTVideoEngineStrategyABRAlgoConfig shareInstance].defaultResolution = TTVideoEngineResolutionTypeFullHD;
        
        NSDictionary *defaultAbrAlgoParams = [[TTVideoEngineStrategyABRAlgoConfig shareInstance] getSDKDefaultAbrAlgoParams];
        NSMutableDictionary *retAbrAlgoParams = [NSMutableDictionary dictionaryWithDictionary:defaultAbrAlgoParams];
        retAbrAlgoParams[@"limit_enable_video_duration"] = @(5000);
        [[TTVideoEngineStrategyABRAlgoConfig shareInstance] setCustomAbrAlgoorithmParam:[retAbrAlgoParams copy]];
    }
    
    TTSDKConfiguration *cfg = [TTSDKConfiguration defaultConfigurationWithAppID:VODAPPID licenseName:VODLicenseName];
    cfg.channel = [NSBundle.mainBundle.infoDictionary objectForKey:@"CHANNEL_NAME"];
    cfg.appName = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleName"];
    cfg.bundleID = NSBundle.mainBundle.bundleIdentifier;
    cfg.appVersion = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    cfg.shouldInitAppLog = YES;
    cfg.appRegion = TTSDKServiceVendorSG;
    cfg.bizType = TTSDKServiceBizType_Vod;
    TTSDKVodConfiguration *vodConfig = [[TTSDKVodConfiguration alloc] init];
    vodConfig.cacheMaxSize = 300 * 1024 * 1024;
    cfg.vodConfiguration = vodConfig;
    [TTSDKManager setCurrentUserUniqueID:[LocalUserComponent userModel].uid ?: @""];
    [TTSDKManager startWithConfiguration:cfg];
}
@end
