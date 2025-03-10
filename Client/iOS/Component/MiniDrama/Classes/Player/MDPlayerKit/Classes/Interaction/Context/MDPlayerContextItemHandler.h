// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDPlayerContextMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDPlayerContextItemHandler : NSObject

@property(nonatomic, copy, readonly) NSArray<NSString *> *keys;
@property(nonatomic, copy, readonly) MDPlayerContextHandler handler;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithObserver:(id)observer keys:(NSArray<NSString *> *)keys handler:(MDPlayerContextHandler)handler NS_DESIGNATED_INITIALIZER;

- (void)executeHandlerWithKey:(NSString *)key andValue:(id)value;

@end

NS_ASSUME_NONNULL_END
