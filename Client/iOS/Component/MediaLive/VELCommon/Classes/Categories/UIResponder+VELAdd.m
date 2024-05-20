// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "UIResponder+VELAdd.h"
#import "UIViewController+VELAdd.h"
@implementation UIResponder (VELAdd)

- (UIViewController *)vel_topViewController {
    UIViewController *topVC;
    UIResponder *responder = self;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            topVC = (UIViewController *)responder;
            break;
        }
        responder = [responder nextResponder];
    }
    return topVC ?: UIViewController.vel_topViewController;
}

@end
