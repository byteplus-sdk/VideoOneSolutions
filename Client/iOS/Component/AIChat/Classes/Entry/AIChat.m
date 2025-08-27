// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "AIChat.h"
#import <ToolKit/JoinRTSParams.h>
#import <ToolKit/ToolKit.h>
#import "AIHomeViewController.h"
@implementation AIChat

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"ai_scene_name", @"AIChat");
        self.des = LocalizedStringFromBundle(@"ai_scene_des", @"AIChat");
        self.bundleName = @"AIChat";
        self.iconName = @"scene_aichat";
        self.scenesName = @"live";
        self.fontStyle = EntranceFontStyleDark;
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL))block {
    [super enterWithCallback:block];
    NSDictionary *params = @{
            @"scenes_name": self.scenesName
    };
    [[ToastComponent shareToastComponent] showLoading];
    __weak __typeof(self) wself = self;
    [JoinRTSParams getJoinRTSParams:params
                              block:^(JoinRTSParamsModel *_Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        [wself joinRTS:model block:block];
    }];

}

// appid + bid
- (void)joinRTS:(JoinRTSParamsModel *_Nonnull)model
          block:(void (^)(BOOL result))block {
    if (!model) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"connection_failed", @"Toolkit")];
        if (block) {
            block(NO);
        }
        return;
    } else {
        AIHomeViewController *nextVC = [[AIHomeViewController alloc]
                                        initWithAppId:model.appId
                                        bid:model.bid];
        UIViewController *topVC = [DeviceInforTool topViewController];
        [topVC.navigationController pushViewController:nextVC animated:YES];
        if (block) {
            block(YES);
        }
    }
    
}
@end
