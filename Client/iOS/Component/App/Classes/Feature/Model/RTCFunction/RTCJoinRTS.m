//
//  RTCJoinRTS.m
//  App
//
//  Created by ByteDance on 2024/6/7.
//

#import "RTCJoinRTS.h"
#import <ToolKit/ToolKit.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/JoinRTSParams.h>

@implementation RTCJoinRTS

+ (void)joinRTS:(UIViewController *)vc block:(void (^)(BOOL))block {
    UIViewController *topVC = [DeviceInforTool topViewController];
    if (NOEmptyStr([PublicParameterComponent share].appId)) {
        [topVC.navigationController pushViewController:vc animated:YES];
        if (block) {
            block(YES);
        }
    } else {
        NSDictionary *inputInfo = @{@"scenes_name" : @"rtc_api_example",
                                    @"login_token" : [LocalUserComponent userModel].loginToken ?: @""};
        [[ToastComponent shareToastComponent] showLoading];
        [JoinRTSParams getJoinRTSParams:inputInfo
                                  block:^(JoinRTSParamsModel *_Nonnull model) {
            [[ToastComponent shareToastComponent] dismiss];
            if (!model) {
                [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"unknown_error", @"App")];
                [PublicParameterComponent share].appId = @"";
                if (block) {
                    block(NO);
                }
                return;
            } else {
                [topVC.navigationController pushViewController:vc animated:YES];
                if (block) {
                    block(YES);
                }
            }
        }];
    }
}

@end
