// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTCTokenProtocol : NSObject

+ (NSString *)rtcAppId;

+ (void)generateTokenWithRoomId:(NSString *)roomId
                         userId:(NSString *)userId
                     completion:(void (^_Nonnull)(NSString * _Nullable token))completion;

@end

NS_ASSUME_NONNULL_END
