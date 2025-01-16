//
//  MiniDrama.m
//  AFNetworking
//
//  Created by ByteDance on 2024/11/12.
//

#import "MiniDrama.h"
#import <AppConfig/BuildConfig.h>
#import <TTSDK/TTSDKManager.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>
#import <TTSDK/TTVideoEngine.h>
#import "MiniDramaMainViewController.h"


@implementation MiniDrama

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"mini_drama_title", @"MiniDrama");
        self.des = LocalizedStringFromBundle(@"mini_drama_des", @"MiniDrama");
        self.iconName = @"scene_mini_drama";
        self.scenesName = @"miniDrama";
        self.bundleName = @"MiniDrama";
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
    MiniDramaMainViewController *vc = [[MiniDramaMainViewController alloc] init];
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
