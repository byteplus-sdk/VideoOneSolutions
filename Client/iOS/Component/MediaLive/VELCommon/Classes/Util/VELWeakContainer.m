// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELWeakContainer.h"

@implementation VELWeakContainer
- (instancetype)initWithObject:(id)object {
    if (self = [super init]) {
        _object = object;
    }
    return self;
}
+ (instancetype)containerWithObject:(id)object {
    return [[self alloc] initWithObject:object];
}
@end
