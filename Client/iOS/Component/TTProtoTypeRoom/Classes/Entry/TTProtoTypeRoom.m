// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "TTProtoTypeRoom.h"
#import "MixFeedViewController.h"
#import <AppConfig/BuildConfig.h>
#import <TTSDK/TTSDKManager.h>
#import <TTSDK/TTVideoEngine.h>
#import <TTSDK/TVLManager.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>

@implementation TTProtoTypeRoom

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"tt_scene_name", @"TTProto");
        self.des = LocalizedStringFromBundle(@"tt_scene_des", @"TTProto");
        self.bundleName = @"TTProto";
        self.iconName = @"vod_live_bg_entry";
        self.scenesName = @"tt_proto";
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
    MixFeedViewController *vc = [[MixFeedViewController alloc] init];
    UIViewController *topVC = [DeviceInforTool topViewController];
    [topVC.navigationController pushViewController:vc animated:YES];
    if (block) {
        block(YES);
    }
}


+ (void)setupTTSDK {
    #ifdef DEBUG
    [TTVideoEngine setLogFlag:TTVideoEngineLogFlagAll];
    [TVLManager setLogLevel:VeLivePlayerLogLevelDebug];
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
