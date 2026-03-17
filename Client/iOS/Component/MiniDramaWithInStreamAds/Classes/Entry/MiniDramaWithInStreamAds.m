// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaWithInStreamAds.h"
#import <AppConfig/BuildConfig.h>
#import <TTSDKFramework/TTSDKFramework.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>
#import "MiniDramaWithInStreamAdsMainViewController.h"

@implementation MiniDramaWithInStreamAds

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"mini_drama_ads_title", @"MiniDramaWithInStreamAds");
        self.des = LocalizedStringFromBundle(@"mini_drama_ads_des", @"MiniDramaWithInStreamAds");
        self.iconName = @"scene_mini_drama_ads";
        self.scenesName = @"miniDramaWithInStreamAds";
        self.bundleName = @"MiniDramaWithInStreamAds";
    }
    return self;
}

+ (void)prepareEnvironment {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupTTSDK];
    });
}

- (void)enterWithCallback:(void (^)(BOOL))block {
    [super enterWithCallback:block];
    MiniDramaWithInStreamAdsMainViewController *vc = [[MiniDramaWithInStreamAdsMainViewController alloc] init];
    UIViewController *topVC = [DeviceInforTool topViewController];
    [topVC.navigationController pushViewController:vc animated:YES];
    if (block) {
        block(YES);
    }
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
