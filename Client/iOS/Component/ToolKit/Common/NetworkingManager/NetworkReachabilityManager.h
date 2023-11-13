// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkReachabilityManager : NSObject

@property (nonatomic, assign, readonly) BOOL isReachable;

+ (instancetype)sharedManager;

- (void)startMonitoring;

- (void)stopMonitoring;

- (NSString *)getNetType;

@end

NS_ASSUME_NONNULL_END
