// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsRecordViewModel.h"

@implementation VELSettingsRecordViewModel
- (instancetype)init {
    if (self = [super init]) {
        _showSanpShot = YES;
        self.size = CGSizeMake(VELAutomaticDimension, 130);
    }
    return self;
}
@end
