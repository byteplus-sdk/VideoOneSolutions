// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDDelegateMultiplexer : NSObject

- (instancetype)initWithProtocol:(Protocol *)protocol NS_DESIGNATED_INITIALIZER;

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;
- (void)removeAllDelegates;

@end

NS_ASSUME_NONNULL_END
