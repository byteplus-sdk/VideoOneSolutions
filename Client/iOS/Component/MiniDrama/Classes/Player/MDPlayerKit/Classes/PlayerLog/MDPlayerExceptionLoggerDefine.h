// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef MDPlayerExceptionLoggerDefine_h
#define MDPlayerExceptionLoggerDefine_h
#import "MDPlayerExceptionLogger.h"

#define MDPlayerAssertMainThreadException() \
        NSAssert([NSThread isMainThread], @"This method must be called on the main thread");\
        if(![NSThread isMainThread]) { \
            [MDPlayerExceptionLogger trackThreadExceptionLog:NSStringFromClass(self.class) currentParams:nil]; \
        } \

static inline void MDPlayerThreadExceptionTrack(NSString * _Nullable exceptionType, NSDictionary<NSString *, id> *_Nullable currentParams) {
    [MDPlayerExceptionLogger trackThreadExceptionLog:exceptionType currentParams:currentParams];
}

#endif /* MDPlayerExceptionLoggerDefine_h */
