// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDScatterPerformProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDLoopScatterPerform : NSObject <MDScatterPerformProtocol>

@property (nonatomic, assign) NSInteger loadCountPerTime;
@property (nonatomic, copy, nullable) void(^performBlock)(NSArray *objects, BOOL load);
@property (nonatomic, assign) BOOL enable;

- (void)loadObjects:(NSArray *)objects;

- (void)unloadObjects:(NSArray *)objects;

- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
