// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "MenuLoginHome.h"
#import "MenuLoginViewController.h"
#import "NetworkingManager.h"

@implementation MenuLoginHome

#pragma mark - Publish Action

+ (BOOL)showLoginVCIfNeed:(BOOL)isAnimation {
    [[NetworkReachabilityManager sharedManager] startMonitoring];
    if (IsEmptyStr([LocalUserComponent userModel].loginToken)) {
        [MenuLoginHome showLoginVCAnimated:isAnimation];
        return YES;
    }
    return NO;
}

+ (void)showLoginVCAnimated:(BOOL)isAnimation {
    UIViewController *topVC = [DeviceInforTool topViewController];
    MenuLoginViewController *loginVC = [[MenuLoginViewController alloc] init];
    loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [topVC presentViewController:loginVC animated:isAnimation completion:^{

    }];
}

+ (void)closeAccount:(void (^)(BOOL result))block {
    if (block) {
        block(YES);
    }
}

@end
