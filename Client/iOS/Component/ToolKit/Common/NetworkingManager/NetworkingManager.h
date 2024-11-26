// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "NetworkReachabilityManager.h"
#import "NetworkingResponse.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NetworkingManagerBlock)(NetworkingResponse *response);

@interface NetworkingManager : NSObject

#pragma mark - Base

+ (void)processResponse:(id _Nullable)responseObject
                  block:(void (^__nullable)(NetworkingResponse *response))block;

+ (void)callHttpEvent:(NSString *)eventName
              content:(NSDictionary *)content
                block:(void (^__nullable)(NetworkingResponse *response))block;

+ (void)postWithEventName:(NSString *)eventName
                    space:(NSString *)space
                  content:(NSDictionary *)content
                    block:(void (^__nullable)(NetworkingResponse *response))block;

+ (void)postWithPath:(NSString *)path
          parameters:(nullable id)parameters
               block:(void(^__nullable)(NetworkingResponse *response))block;

+ (void)postWithPath:(NSString *)path
          parameters:(nullable id)parameters
             headers:(nullable NSDictionary<NSString *, NSString *> *)headers
               block:(void(^__nullable)(NetworkingResponse *response))block;

+ (void)postWithPath:(NSString *)path
          parameters:(nullable id)parameters
             headers:(nullable NSDictionary<NSString *, NSString *> *)headers
            progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
               block:(void(^__nullable)(NetworkingResponse *response))block;

+ (void)getWithPath:(NSString *)path
         parameters:(nullable id)parameters
              block:(void (^__nullable)(NetworkingResponse *response))block;

@end

NS_ASSUME_NONNULL_END
