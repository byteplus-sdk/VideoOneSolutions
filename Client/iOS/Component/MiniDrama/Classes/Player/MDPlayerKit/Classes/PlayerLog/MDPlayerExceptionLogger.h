// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ThreadExceptionLogBlock)(NSString *type, NSDictionary<NSString *, id> *_Nullable currentParams);

@interface MDPlayerExceptionLogger : NSObject

+ (void)setThreadExceptionLogBlock:(ThreadExceptionLogBlock)threadExceptionLogBlock;
+ (void)trackThreadExceptionLog:(NSString *)exceptionType currentParams:(NSDictionary<NSString *, id> *_Nullable)currentParams;


@end

NS_ASSUME_NONNULL_END
