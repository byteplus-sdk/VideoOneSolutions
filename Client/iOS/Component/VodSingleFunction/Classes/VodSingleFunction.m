// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VodSingleFunction.h"
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
    TTSDKConfiguration *cfg = [TTSDKConfiguration defaultConfigurationWithAppID:VODAPPID licenseName:VODLicenseName];
    cfg.channel = [NSBundle.mainBundle.infoDictionary objectForKey:@"CHANNEL_NAME"];
    cfg.appName = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleName"];
    cfg.bundleID = NSBundle.mainBundle.bundleIdentifier;
    cfg.appVersion = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    cfg.shouldInitAppLog = YES;
    cfg.serviceVendor = TTSDKServiceVendorSG;
    TTSDKVodConfiguration *vodConfig = [[TTSDKVodConfiguration alloc] init];
    vodConfig.cacheMaxSize = 300 * 1024 * 1024;
    cfg.vodConfiguration = vodConfig;
    [TTSDKManager setCurrentUserUniqueID:[LocalUserComponent userModel].uid ?: @""];
    [TTSDKManager setShouldReportToAppLog:YES];
    [TTSDKManager startWithConfiguration:cfg];
}
@end
