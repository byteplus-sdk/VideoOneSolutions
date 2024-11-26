// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "SoloSinging.h"
#import "JoinRTSParams.h"
#import "KTVRTCManager.h"
#import "KTVRoomListsViewController.h"

@implementation SoloSinging

- (instancetype)init {
    self = [super init];
    if (self) {
        self.bundleName = HomeBundleName;
        self.title = LocalizedString(@"solo_singing_title");
        self.desList = @[LocalizedString(@"solo_singing_des_1"),
                         LocalizedString(@"solo_singing_des_2")];
        self.iconName = @"solo_singing_scene";
        self.scenesName = @"ktv";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
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
- (void)joinRTS:(JoinRTSParamsModel *_Nonnull)model
          block:(void (^)(BOOL result))block {
    if (!model) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"connection_failed")];
        if (block) {
            block(NO);
        }
        return;
    }
    // Connect RTS
    [[KTVRTCManager shareRtc] connect:model.appId
                                  bid:model.bid
                                block:^(BOOL result) {
        if (result) {
            KTVRoomListsViewController *next = [[KTVRoomListsViewController alloc] init];
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
