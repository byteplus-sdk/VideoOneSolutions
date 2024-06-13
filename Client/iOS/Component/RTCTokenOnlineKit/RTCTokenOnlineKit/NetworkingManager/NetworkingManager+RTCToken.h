// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <ToolKit/NetworkingManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkingManager (RTCToken)

#pragma mark - Login

+ (void)tokenWithAppID:(NSString *)appId
                appKey:(NSString *)appKey
                roomId:(NSString *)roomId
                   uid:(NSString *)userId
                 block:(void (^__nullable)(NSString *_Nullable errorDescription,
                                           NSString *_Nullable RTCToken))block;

@end

NS_ASSUME_NONNULL_END
