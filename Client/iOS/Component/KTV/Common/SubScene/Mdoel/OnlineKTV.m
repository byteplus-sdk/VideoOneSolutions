// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "OnlineKTV.h"
#import "SubSceneViewController.h"
#import "KTVRTCManager.h"
#import "JoinRTSParams.h"

@implementation OnlineKTV

- (instancetype)init {
    self = [super init];
    BOOL isNeed = NO;
    if (self) {
        self.bundleName = HomeBundleName;
        self.title = LocalizedString(@"ktv_scenes");
        self.des = LocalizedString(@"ktv_scenes_des");
        self.iconName = @"scene_ktv_bg";
        self.scenesName = @"ktv";
        
        
        id chorusClass = [[NSClassFromString(@"SoloSinging") alloc] init];
        id KTVClass = [[NSClassFromString(@"DuetSinging") alloc] init];
        if (chorusClass || KTVClass) {
            isNeed = YES;
        }
    }
    return isNeed ? self : nil;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    SubSceneViewController *next = [[SubSceneViewController alloc] init];
    UIViewController *topVC = [DeviceInforTool topViewController];
    [topVC.navigationController pushViewController:next animated:YES];
    
    if (block){
        block(YES);
    }
}

@end
