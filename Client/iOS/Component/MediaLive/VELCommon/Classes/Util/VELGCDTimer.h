// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VELGCDTimer : NSObject
- (void)start:(float)interval block:(void(^)(BOOL result))block;

- (void)resume;

- (void)suspend;

- (void)stop;
@end

NS_ASSUME_NONNULL_END
