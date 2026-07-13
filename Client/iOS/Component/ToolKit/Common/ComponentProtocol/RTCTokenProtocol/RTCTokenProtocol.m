// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "RTCTokenProtocol.h"

@protocol RTCTokenGenerator <NSObject>

+ (NSString *)rtcAppId;

+ (void)generateTokenWithRoomId:(NSString *_Nonnull)roomId
                         userId:(NSString *_Nonnull)userId
                     completion:(void (^_Nonnull)(NSString *_Nullable))completion;

@end

@implementation RTCTokenProtocol

+ (NSString *)rtcAppId {
    Class generatorClass = NSClassFromString(@"TokenGenerator");
    if ([generatorClass respondsToSelector:@selector(rtcAppId)]) {
        return [(Class<RTCTokenGenerator>)generatorClass rtcAppId];
    }
    return @"";
}

+ (void)generateTokenWithRoomId:(NSString *)roomId
                         userId:(NSString *)userId
                     completion:(void (^_Nonnull)(NSString * _Nullable token))completion {
    Class generatorClass = NSClassFromString(@"TokenGenerator");
    if ([generatorClass respondsToSelector:@selector(generateTokenWithRoomId:userId:completion:)]) {
        [(Class<RTCTokenGenerator>)generatorClass generateTokenWithRoomId:roomId
                                                                   userId:userId
                                                               completion:completion];
        return;
    }

    completion(@"");
}

@end
