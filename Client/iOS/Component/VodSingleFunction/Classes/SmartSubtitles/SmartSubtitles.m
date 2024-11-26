//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "SmartSubtitles.h"
#import "NetworkingManager+SingleFunction.h"
#import "SmartSubtitleViewController.h"
#import <ToolKit/ToolKit.h>

@implementation SmartSubtitles

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"function_title_smart_subtitles", @"VodPlayer");
        self.iconName = @"function_icon_smart_subtitles";
        self.bundleName = @"VodPlayer";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    [[ToastComponent shareToastComponent] showLoading];
    [NetworkingManager dataForScene:VESceneTypeFeedVideo
                       functionType:VESingleFunctionTypeSmartSubtitles
                            success:^(VEVideoModel *_Nonnull videoModel) {
        [[ToastComponent shareToastComponent] dismiss];
        SmartSubtitleViewController *vc = [[SmartSubtitleViewController alloc] initWithType:VEVideoPlayerTypeFeed];
        vc.videoModel = videoModel;
        UIViewController *topVC = [DeviceInforTool topViewController];
        [topVC.navigationController pushViewController:vc animated:YES];
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
