// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDPlayerContextMacros.h"
#import "MDPlayerContextItemHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDPlayerContextItem : NSObject

@property (nonatomic, copy, readwrite, nonnull) NSString *key;

@property (nonatomic, strong, readwrite, nullable) id object;

- (void)addHandler:(MDPlayerContextItemHandler *)handler;

- (void)removeHandler:(MDPlayerContextItemHandler *)handler;
- (void)removeAllHandler;

- (void)notify:(id)value;

@end

NS_ASSUME_NONNULL_END
