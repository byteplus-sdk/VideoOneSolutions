// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginControlComponent : NSObject

+ (void)passwordFreeLogin:(NSString *)userName
                    block:(void (^__nullable)(BOOL result, NSString *_Nullable errorStr))block;

@end

NS_ASSUME_NONNULL_END
