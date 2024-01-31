// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "InteractiveLive.h"
#import "LiveJoinRTSInputModel.h"
#import "LiveRoomListsViewController.h"
#import <AppConfig/BuildConfig.h>
#import <TTSDK/TTSDKManager.h>
#import <ToolKit/BaseRTCManager.h>
#import <ToolKit/JoinRTSParams.h>

@implementation InteractiveLive

- (instancetype)init {
    self = [super init];
    if (self) {
        self.bundleName = HomeBundleName;
        self.title = LocalizedString(@"interactive_live_scenes");
        self.des = LocalizedString(@"interactive_live_scenes_des");
        self.iconName = @"scene_interactive_live_bg";
        self.scenesName = @"live";
    }
    return self;
}

+ (void)prepareEnvironment {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupTTSDK];
    });
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];

    NSDictionary *inputInfo = [LiveJoinRTSInputModel getLiveJoinRTSInputInfo:self.scenesName];
    [[ToastComponent shareToastComponent] showLoading];
    __weak __typeof(self) wself = self;
    [JoinRTSParams getJoinRTSParams:inputInfo
                              block:^(JoinRTSParamsModel *_Nonnull model) {
                                  [wself joinRTS:model block:block];
                              }];
}
- (void)joinRTS:(JoinRTSParamsModel *_Nonnull)model
          block:(void (^)(BOOL result))block {
    if (!model) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"connection_failed")];
        if (block) {
            block(NO);
        }
        return;
    }
    [[LiveRTCManager shareRtc] connect:model.appId
                              RTSToken:model.RTSToken
                             serverUrl:model.serverUrl
                             serverSig:model.serverSignature
                                   bid:model.bid
                                 block:^(BOOL result) {
                                     if (result) {
                                         [[ToastComponent shareToastComponent] dismiss];
                                         [InteractiveLive prepareEnvironment];
                                         LiveRoomListsViewController *next = [[LiveRoomListsViewController alloc] init];
                                         UIViewController *topVC = [DeviceInforTool topViewController];
                                         [topVC.navigationController pushViewController:next animated:YES];
                                     } else {
                                         [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"connection_failed")];
                                     }
                                     if (block) {
                                         block(result);
                                     }
                                 }];
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

@end
