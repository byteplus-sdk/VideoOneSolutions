// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "TTProtoTypeRoom.h"
#import "MixFeedViewController.h"
#import <AppConfig/BuildConfig.h>
#import <TTSDKFramework/TTSDKFramework.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>
#import <ToolKit/JoinRTSParams.h>

@implementation TTProtoTypeRoom

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"tt_scene_name", @"TTProto");
        self.des = LocalizedStringFromBundle(@"tt_scene_des", @"TTProto");
        self.bundleName = @"TTProto";
        self.iconName = @"vod_live_bg_entry";
        self.scenesName = @"livefeed";
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
    NSDictionary *inputInfo = @{
            @"scenes_name": @"livefeed"
    };
    [[ToastComponent shareToastComponent] showLoading];
    __weak __typeof(self) wself = self;
    [JoinRTSParams getJoinRTSParams:inputInfo
                              block:^(JoinRTSParamsModel *_Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        MixFeedViewController *vc = [[MixFeedViewController alloc] init];
        UIViewController *topVC = [DeviceInforTool topViewController];
        [topVC.navigationController pushViewController:vc animated:YES];
        if (block) {
            block(YES);
        }
    }];
}


+ (void)setupTTSDK {
    #ifdef DEBUG
    [TTVideoEngine setLogFlag:TTVideoEngineLogFlagAll];
    [TVLManager setLogLevel:VeLivePlayerLogLevelDebug];
    #endif
    TTSDKConfiguration *cfgVod = [TTSDKConfiguration defaultConfigurationWithAppID:VODAPPID licenseName:VODLicenseName];
    cfgVod.channel = [NSBundle.mainBundle.infoDictionary objectForKey:@"CHANNEL_NAME"];
    cfgVod.appName = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleName"];
    cfgVod.bundleID = NSBundle.mainBundle.bundleIdentifier;
    cfgVod.appVersion = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    cfgVod.shouldInitAppLog = YES;
    cfgVod.appRegion = TTSDKServiceVendorSG;
    cfgVod.bizType = TTSDKServiceBizType_Vod;
    TTSDKVodConfiguration *vodConfig = [[TTSDKVodConfiguration alloc] init];
    vodConfig.cacheMaxSize = 300 * 1024 * 1024;
    cfgVod.vodConfiguration = vodConfig;
    [TTSDKManager startWithConfiguration:cfgVod];
    
    TTSDKConfiguration *cfgLive = [TTSDKConfiguration defaultConfigurationWithAppID:LiveAPPID licenseName:LiveLicenseName];
    cfgLive.channel = [NSBundle.mainBundle.infoDictionary objectForKey:@"CHANNEL_NAME"];
    cfgLive.appName = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleName"];
    cfgLive.bundleID = NSBundle.mainBundle.bundleIdentifier;
    cfgLive.appVersion = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // has inited before
    cfgLive.shouldInitAppLog = NO;
    cfgLive.appRegion = TTSDKServiceVendorSG;
    cfgLive.bizType = TTSDKServiceBizType_Live;
    [TTSDKManager startWithConfiguration:cfgLive];
    
    [TTSDKManager setCurrentUserUniqueID:[LocalUserComponent userModel].uid ?: @""];
    [VeLiveCommon enableReportApplog:YES];
}

@end
