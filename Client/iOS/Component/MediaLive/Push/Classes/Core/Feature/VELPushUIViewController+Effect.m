// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushUIViewController+Private.h"
#import <ToolKit/ToolKit.h>
#import <ToolKit/Localizator.h>

@implementation VELPushUIViewController (Effect)
- (BOOL)isSupportEffect {
    return self.config.captureType == VELSettingCaptureTypeInner;
}

- (void)setupEffectManager {}

- (void)showEffect {
    if (self.beautyComponent) {
        __weak __typeof__(self)weakSelf = self;
        [self.beautyComponent showWithView:self.view dismissBlock:^(BOOL result) {
            weakSelf.currentPopObj = nil;
        }];
        self.currentPopObj = self.effectViewModel;
    } else {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"not_support_beauty_error", @"ToolKit")];
    }
}

@end
