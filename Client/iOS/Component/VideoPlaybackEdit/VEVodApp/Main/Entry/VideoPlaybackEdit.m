// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VideoPlaybackEdit.h"
#import "VEMainViewController.h"
#import <AppConfig/BuildConfig.h>
#import <TTSDK/TTSDKManager.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>
#import <TTSDK/TTVideoEngine.h>

@implementation VideoPlaybackEdit

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"vod_scenes", @"VEVodApp");
        self.des = LocalizedStringFromBundle(@"vod_scenes_des", @"VEVodApp");
        self.iconName = @"scene_vod_bg";
        self.scenesName = @"vod";
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
    VEMainViewController *vc = [[VEMainViewController alloc] init];
    __weak __typeof__(self) weakSelf = self;
    vc.clickTabCenterBolck = ^{
        __strong __typeof__(weakSelf) self = weakSelf;
        [self presentCKEditor];
    };
    UIViewController *topVC = [DeviceInforTool topViewController];
    [topVC.navigationController pushViewController:vc animated:YES];
    if (block) {
        block(YES);
    }
}

- (void)presentCKEditor {
    UIViewController *vc = [[NSClassFromString(@"CKHomeController") alloc] init];
    if (vc) {
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        nc.modalPresentationStyle = UIModalPresentationFullScreen;
        UIViewController *topVC = [DeviceInforTool topViewController];
        [topVC presentViewController:nc animated:YES completion:nil];
    } else {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"not_support_CK_error", @"ToolKit")];
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
