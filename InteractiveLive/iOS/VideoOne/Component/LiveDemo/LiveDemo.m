// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveDemo.h"
#import "LiveRoomListsViewController.h"
#import "LiveJoinRTSInputModel.h"

@implementation LiveDemo

- (void)pushDemoViewControllerBlock:(void (^)(BOOL result))block {
    [super pushDemoViewControllerBlock:block];
    NSDictionary *inputInfo = [LiveJoinRTSInputModel getLiveJoinRTSInputInfo:self.scenesName];
    __weak __typeof(self) wself = self;
    [JoinRTSParams getJoinRTSParams:inputInfo
                             block:^(JoinRTSParamsModel * _Nonnull model) {
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
    [[LiveRTCManager shareRtc] connect:model.appId
                              RTSToken:model.RTSToken
                             serverUrl:model.serverUrl
                             serverSig:model.serverSignature
                                   bid:model.bid
                                 block:^(BOOL result) {
        if (result) {
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

@end
