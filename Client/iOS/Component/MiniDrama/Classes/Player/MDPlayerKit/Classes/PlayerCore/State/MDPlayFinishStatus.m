// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDPlayFinishStatus.h"

@implementation MDPlayFinishStatus

- (BOOL)playerFinishedSuccess {
    if (!self.error) {
        return YES;
    }
    return NO;
}

@end
