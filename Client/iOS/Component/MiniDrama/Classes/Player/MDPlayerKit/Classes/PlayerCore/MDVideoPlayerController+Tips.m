// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDVideoPlayerController+Tips.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation MDVideoPlayerController (ShowTips)

- (void)showTips:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.playerView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    [hud hideAnimated:YES afterDelay:2.0];
}

@end
