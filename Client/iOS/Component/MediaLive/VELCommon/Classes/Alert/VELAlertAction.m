// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELAlertAction.h"

@implementation VELAlertAction
+ (instancetype)actionWithTitle:(NSString *)title block:(AlertModelClickBlock)block {
    VELAlertAction *action = [[VELAlertAction alloc] init];
    action.title = title;
    action.alertModelClickBlock = block;
    return action;
}
@end
