// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDPlayerExceptionLogger.h"
#import "BTDMacros.h"
static NSString *const ExceptionLogPrefix = @"MDPlayer_";

@interface MDPlayerExceptionLogger ()

@property(nonatomic, copy, class) ThreadExceptionLogBlock threadExceptionLogBlock;

@end

@implementation MDPlayerExceptionLogger
#pragma mark - Public Mehtod
+ (void)trackThreadExceptionLog:(NSString *)exceptionType currentParams:(NSDictionary<NSString *, id> *_Nullable)currentParams {
    NSAssert(!BTD_isEmptyString(exceptionType), @"异常类型不能为空");
    NSAssert(nil != self.threadExceptionLogBlock, @"未配置异常上报block");
    NSString *logString = [NSString stringWithFormat:@"%@%@", ExceptionLogPrefix, exceptionType];
    BTD_BLOCK_INVOKE(self.threadExceptionLogBlock, logString, currentParams);
}
#pragma mark - Setter & Getter
static ThreadExceptionLogBlock __threadExceptionLogBlock = nil;
+ (void)setThreadExceptionLogBlock:(ThreadExceptionLogBlock)threadExceptionLogBlock {
    __threadExceptionLogBlock = [threadExceptionLogBlock copy];
}

+ (ThreadExceptionLogBlock)threadExceptionLogBlock {
    return __threadExceptionLogBlock;
}

@end
