// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

@class RTCTokenProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol RTCTokenDelegate <NSObject>

- (void)protocol:(RTCTokenProtocol *)protocol
  tokenWithAppID:(NSString *)appId
          appKey:(NSString *)appKey
          roomId:(NSString *)roomId
             uid:(NSString *)userId
           block:(void (^)(NSString *RTCToken))block;

- (void)protocol:(RTCTokenProtocol *)protocol
     getRTMPAddr:(NSString *)taskID
           block:(void (^)(NSString *addr))block;

@end

@interface RTCTokenProtocol : NSObject

- (void)tokenWithAppID:(NSString *)appId
                appKey:(NSString *)appKey
                roomId:(NSString *)roomId
                   uid:(NSString *)userId
                 block:(nonnull void (^)(NSString * _Nonnull))block;

- (void)getRTMPAddr:(NSString *)taskID
              block:(void (^)(NSString *addr))block;

@end

NS_ASSUME_NONNULL_END
