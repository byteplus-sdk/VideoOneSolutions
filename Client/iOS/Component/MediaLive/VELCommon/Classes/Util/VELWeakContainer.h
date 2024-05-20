// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VELWeakContainer : NSObject
@property (nonatomic, readonly, weak) id object;
- (instancetype)initWithObject:(id)object;
+ (instancetype)containerWithObject:(id)object;
@end

NS_ASSUME_NONNULL_END
