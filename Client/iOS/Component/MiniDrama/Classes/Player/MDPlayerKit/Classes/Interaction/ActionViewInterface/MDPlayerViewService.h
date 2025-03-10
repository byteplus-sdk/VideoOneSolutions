// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDPlayerActionViewInterface.h"

NS_ASSUME_NONNULL_BEGIN

@class MDPlayerModuleManager;

@interface MDPlayerViewService : NSObject <MDPlayerActionViewInterface>

// weak reference module manager 
@property (nonatomic, weak, nullable) MDPlayerModuleManager *moduleManager;

@end

NS_ASSUME_NONNULL_END
