// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

@interface GCDTimer : NSObject

- (void)start:(float)interval block:(void(^)(BOOL result))block;

- (void)resume;

- (void)suspend;

- (void)stop;

@end
