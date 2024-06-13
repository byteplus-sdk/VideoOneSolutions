//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "APIExample.h"
#import <ToolKit/ToolKit.h>
#import <ToolKit/JoinRTSParams.h>

@implementation APIExample

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"developers_rtc_api_title", @"App");
        self.des = LocalizedStringFromBundle(@"developers_rtc_api_des", @"App");
        self.iconName = @"rtc_api_example";
        self.bundleName = @"App";
        id homeClass = [[NSClassFromString(@"APIViewController") alloc] init];
        self.isNeedShow = homeClass ? YES : NO;
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    NSDictionary *inputInfo = @{@"scenes_name" : @"rtc_api_example",
                                @"login_token" : [LocalUserComponent userModel].loginToken ?: @""};
    [[ToastComponent shareToastComponent] showLoading];
    [JoinRTSParams getJoinRTSParams:inputInfo
                              block:^(JoinRTSParamsModel *_Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        UIViewController *vc = [[NSClassFromString(@"APIViewController") alloc] init];
        UIViewController *topVC = [DeviceInforTool topViewController];
        [topVC.navigationController pushViewController:vc animated:YES];
        
        if (block) {
            block(YES);
        }
        
    }];
}

@end
