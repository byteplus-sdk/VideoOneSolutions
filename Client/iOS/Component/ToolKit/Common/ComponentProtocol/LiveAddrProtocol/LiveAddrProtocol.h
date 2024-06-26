// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

@class LiveAddrProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol LiveAddrDelegate <NSObject>

- (void)protocol:(LiveAddrProtocol *)protocol
     getRTMPAddr:(NSString *)taskID
           block:(void (^)(NSString *addr))block;

@end

@interface LiveAddrProtocol : NSObject

- (void)getRTMPAddr:(NSString *)taskID
              block:(void (^)(NSString *addr))block;

@end

NS_ASSUME_NONNULL_END
