// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "LiveRoomViewController+Report.h"
#import "LiveSettingVideoConfig.h"
#import <ToolKit/NetworkingManager+Report.h>
#import <ToolKit/ReportComponent.h>

@implementation LiveRoomViewController (Report)

#pragma mark - Publish Action

- (void)showBlockAndReportUser:(NSString *)userID {
    [ReportComponent blockAndReportUser:userID];
}

- (void)showBlockAndReportLiveRoom:(NSString *)roomID {
    __weak __typeof(self) wself = self;
    [ReportComponent showBlockAndReportSheet:roomID
                                       title:LocalizedString(@"liveroom_sheet_title")
                               cancelHandler:nil
                                blockHandler:^{
                                    [wself showBlockLiveRoomAlert:roomID];
                                }
                            reportCompletion:nil];
}

#pragma mark - Private Action

- (void)showBlockLiveRoomAlert:(NSString *)roomID {
    __weak __typeof(self) wself = self;
    AlertActionModel *cancel = [[AlertActionModel alloc] init];
    cancel.title = LocalizedString(@"alert_cancel_button");

    AlertActionModel *confirm = [[AlertActionModel alloc] init];
    confirm.title = LocalizedString(@"alert_confirm_button");
    confirm.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {
        [[ToastComponent shareToastComponent] showLoading];
        [NetworkingManager blockWithKey:roomID block:^(NetworkingResponse *_Nonnull response) {
            [[ToastComponent shareToastComponent] dismiss];
            [ReportComponent setBlockedKey:roomID];
            [wself hangUp];
            NSString *message = LocalizedString(@"block_liveroom_toast_message");
            [[ToastComponent shareToastComponent] showWithMessage:message delay:0.8];
        }];
    };
    [[AlertActionManager shareAlertActionManager] showWithTitle:LocalizedString(@"block_liveroom_title")
                                                        message:@""
                                                        actions:@[cancel, confirm]
                                                 alertUserModel:nil];
}

@end
