// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "NetworkingManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkingManager (Report)

+ (void)reportWithKey:(NSString *)key
              message:(NSString *)message
                block:(void (^__nullable)(NetworkingResponse *response))block;

+ (void)blockWithKey:(NSString *)key
               block:(void (^__nullable)(NetworkingResponse *response))block;

@end

NS_ASSUME_NONNULL_END
