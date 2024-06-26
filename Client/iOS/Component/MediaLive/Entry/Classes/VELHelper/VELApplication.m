// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELApplication.h"
#import <MediaLive/VELCore.h>
#import <AppConfig/BuildConfig.h>
#import <ToolKit/ToolKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <MediaLive/VELSettings.h>
#import <MediaLive/VELCommon.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#pragma clang diagnostic pop

@interface VELApplication ()
@end

@implementation VELApplication

+ (void)prepareEnvironment {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupTTSDK];
    });
}

+ (void)setupTTSDK {
    TTSDKConfiguration *cfg = [TTSDKConfiguration defaultConfigurationWithAppID:LiveAPPID licenseName:LiveLicenseName];
    cfg.channel = [NSBundle.mainBundle.infoDictionary objectForKey:@"CHANNEL_NAME"];
    cfg.appName = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleName"];
    cfg.bundleID = NSBundle.mainBundle.bundleIdentifier;
    cfg.appVersion = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    cfg.shouldInitAppLog = YES;
    cfg.serviceVendor = TTSDKServiceVendorSG;
    [TTSDKManager setCurrentUserUniqueID:[LocalUserComponent userModel].uid ?: @""];
    [TTSDKManager setShouldReportToAppLog:YES];
    [TTSDKManager startWithConfiguration:cfg];
}

+ (NSString *)getSDKVersionString {
    NSMutableString *versionString = @"".mutableCopy;
    [versionString appendFormat:@"TTSDK %@", TTSDKManager.SDKVersionString];
    return versionString.copy;
}

+ (NSString *)getDemoBuildInfo {
    return [NSBundle.mainBundle.infoDictionary objectForKey:@"BuildInfo"];;
}
@end
