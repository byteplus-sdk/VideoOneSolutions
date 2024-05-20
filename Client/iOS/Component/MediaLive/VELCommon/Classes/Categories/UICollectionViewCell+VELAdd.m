// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "UICollectionViewCell+VELAdd.h"
#import "NSObject+VELAdd.h"

@implementation UICollectionViewCell (VELAdd)

+ (NSString *)vel_identifier {
    return [self vel_className];
}

@end
