// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "NetworkingManager+Report.h"

@implementation NetworkingManager (Report)

+ (void)reportWithKey:(NSString *)key
              message:(NSString *)message
                block:(void (^)(NetworkingResponse *_Nonnull))block {
    NSDictionary *content = @{
        @"key": key ?: @"",
        @"message": message ?: @"",
    };
    [self postWithEventName:@"report" space:@"report" content:content block:block];
}

+ (void)blockWithKey:(NSString *)key
               block:(void (^)(NetworkingResponse *_Nonnull))block {
    NSDictionary *content = @{
        @"key": key ?: @"",
    };
    [self postWithEventName:@"block" space:@"report" content:content block:block];
}

@end
