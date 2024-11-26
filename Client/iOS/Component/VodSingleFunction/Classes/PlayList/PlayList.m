// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "PlayList.h"
#import "PlayListViewController.h"
#import "NetworkingManager+PlayList.h"
#import <ToolKit/ToolKit.h>

@implementation PlayList

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"function_title_playlist", @"VodPlayer");
        self.iconName = @"function_icon_playlist";
        self.bundleName = @"VodPlayer";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL))block {
    [super enterWithCallback:block];
    [[ToastComponent shareToastComponent] showLoading];
    [NetworkingManager getPlayListDetail:^(NSArray<VEVideoModel *> * _Nonnull playList, PlayListMode playMode) {
        [[ToastComponent shareToastComponent] dismiss];
        VEVideoModel *videoModel = playList.firstObject;
        PlayListViewController *vc = [[PlayListViewController alloc] init];
        vc.videoModel = videoModel;
        vc.playList = playList;
        vc.playMode = playMode;
        UIViewController *topVC = [DeviceInforTool topViewController];
        [topVC.navigationController pushViewController:vc animated:NO];
        if (block) {
            block(YES);
        }
    } failure:^(NSString * _Nonnull errorMessage) {
        [[ToastComponent shareToastComponent] dismiss];
        [[ToastComponent shareToastComponent] showWithMessage:errorMessage];
        if (block) {
            block(NO);
        }
    }];
}

@end
