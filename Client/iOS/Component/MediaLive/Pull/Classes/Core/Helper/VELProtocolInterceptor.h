// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VELProtocolInterceptor : NSObject
@property (nonatomic, weak) id receiver;
@property (nonatomic, weak) id interceptor;
- (instancetype)initWithdProtocol:(Protocol *)protocol;
@end

NS_ASSUME_NONNULL_END
