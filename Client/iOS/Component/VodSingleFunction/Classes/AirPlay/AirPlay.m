//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "AirPlay.h"
#import "AirPlayViewController.h"
#import "NetworkingManager+SingleFunction.h"
#import <ToolKit/ToolKit.h>

@implementation AirPlay

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"function_title_airplay", @"VodPlayer");
        self.iconName = @"function_title_airplay";
        self.bundleName = @"VodPlayer";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    [[ToastComponent shareToastComponent] showLoading];
    [NetworkingManager dataForScene:VESceneTypeFeedVideo
                       functionType:VESingleFunctionTypeAirPlay
                            success:^(VEVideoModel *_Nonnull videoModel) {
        [[ToastComponent shareToastComponent] dismiss];
        AirPlayViewController *vc = [[AirPlayViewController alloc] init];
        vc.videoModel = videoModel;
        vc.closeCallback = ^(BOOL landscapeMode, VEVideoPlayerController *playerController) {
            [playerController stop];
            [playerController close];
        };
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
