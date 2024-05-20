// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsPullInputViewModel.h"
#import <ToolKit/Localizator.h>

@implementation VELSettingsPullInputViewModel
- (BOOL)enableABRConfig {
    return self.currentUrlConfig.enableABR;
}

- (VELPullUrlConfig *)currentUrlConfig {
    return self.mainUrlConfig;
}

- (NSString *)placeHolder {
    return LocalizedStringFromBundle(@"medialive_pull_address_placeholder", @"MediaLive");
}
- (void)setCurrentUrlConfig:(VELPullUrlConfig *)currentUrlConfig {
    self.mainUrlConfig = currentUrlConfig;
}
@end
