// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "DuetSinging.h"
#import "JoinRTSParams.h"
#import "ChorusRTCManager.h"
#import "ChorusRoomListsViewController.h"

@implementation DuetSinging

- (instancetype)init {
    self = [super init];
    if (self) {
        self.bundleName = HomeBundleName;
        self.title = LocalizedString(@"duet_singing_title");
        self.desList = @[LocalizedString(@"duet_singing_des_1"),
                         LocalizedString(@"duet_singing_des_2")];
        self.iconName = @"duet_singing_scene";
        self.scenesName = @"owc";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.scenesName forKey:@"scenes_name"];
    [dic setValue:[LocalUserComponent userModel].loginToken forKey:@"login_token"];
    
    [[ToastComponent shareToastComponent] showLoading];
    __weak __typeof(self) wself = self;
    [JoinRTSParams getJoinRTSParams:[dic copy]
                              block:^(JoinRTSParamsModel *_Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        [wself joinRTS:model block:block];
    }];
}
- (void)joinRTS:(JoinRTSParamsModel * _Nonnull)model
          block:(void (^)(BOOL result))block{
    if (!model) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"connection_failed")];
        if (block) {
            block(NO);
        }
        return;
    }
    // Connect RTS
    [[ChorusRTCManager shareRtc] connect:model.appId
                                RTSToken:model.RTSToken
                               serverUrl:model.serverUrl
                               serverSig:model.serverSignature
                                     bid:model.bid
                                   block:^(BOOL result) {
        if (result) {
            ChorusRoomListsViewController *next = [[ChorusRoomListsViewController alloc] init];
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

@end
