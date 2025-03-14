// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDPlayerBaseModuleProtocol.h"
#import "MDPlayerContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDPlayerBaseModule : NSObject <MDPlayerBaseModuleProtocol>

@property (nonatomic, weak) MDPlayerContext *context;

@property (nonatomic, strong) id data;

@property (nonatomic, assign, readonly) BOOL isLoaded;

@property (nonatomic, assign, readonly) BOOL isViewLoaded;

@end

NS_ASSUME_NONNULL_END
