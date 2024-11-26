//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "PreventRecording.h"
#import "NetworkingManager+SingleFunction.h"
#import "PreventRecordingViewController.h"
#import <ToolKit/ToolKit.h>

@implementation PreventRecording

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"function_title_prevent_recoding", @"VodPlayer");
        self.iconName = @"function_icon_prevent_recoding";
        self.bundleName = @"VodPlayer";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    [[ToastComponent shareToastComponent] showLoading];
    [NetworkingManager dataForScene:VESceneTypeFeedVideo
                       functionType:VESingleFunctionTypePreventRecording
                            success:^(VEVideoModel *_Nonnull videoModel) {
        [[ToastComponent shareToastComponent] dismiss];
        PreventRecordingViewController *vc = [[PreventRecordingViewController alloc] init];
        vc.videoModel = videoModel;
        UIViewController *topVC = [DeviceInforTool topViewController];
        [topVC.navigationController pushViewController:vc animated:YES];
        if (block) {
            block(YES);
        }
    } failure:^(NSString *_Nonnull errorMessage) {
        [[ToastComponent shareToastComponent] dismiss];
        [[ToastComponent shareToastComponent] showWithMessage:errorMessage];
        if (block) {
            block(NO);
        }
    }];
}

@end
