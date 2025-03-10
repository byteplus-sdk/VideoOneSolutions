// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDPlayerViewLifeCycleProtocol.h"
#import "MDPlayerModuleManagerInterface.h"

NS_ASSUME_NONNULL_BEGIN

@class MDPlayerContext;

@interface MDPlayerModuleManager : NSObject<
MDPlayerViewLifeCycleProtocol,
MDPlayerModuleManagerInterface
>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPlayerContext:(MDPlayerContext *)playerContext NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
