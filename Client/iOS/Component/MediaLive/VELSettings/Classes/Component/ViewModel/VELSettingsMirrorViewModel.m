// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsMirrorViewModel.h"

@implementation VELSettingsMirrorViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.size = CGSizeMake(VELAutomaticDimension, 170);
    }
    return self;
}
@end
