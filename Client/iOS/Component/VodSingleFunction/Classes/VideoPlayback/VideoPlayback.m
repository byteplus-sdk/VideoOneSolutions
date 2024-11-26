//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VideoPlayback.h"
#import "NetworkingManager+SingleFunction.h"
#import "VEBaseVideoDetailViewController.h"
#import <ToolKit/ToolKit.h>

@implementation VideoPlayback

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"function_title_video_playback", @"VodPlayer");
        self.iconName = @"function_icon_video_playback";
        self.bundleName = @"VodPlayer";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    [[ToastComponent shareToastComponent] showLoading];
    [NetworkingManager dataForScene:VESceneTypeFeedVideo
                       functionType:VESingleFunctionTypePlayback
                            success:^(VEVideoModel *_Nonnull videoModel) {
        [[ToastComponent shareToastComponent] dismiss];
        VEBaseVideoDetailViewController *vc = [[VEBaseVideoDetailViewController alloc] init];
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
