// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "RTCTokenProtocol.h"

@implementation RTCTokenProtocol

- (void)tokenWithAppID:(NSString *)appId
                appKey:(NSString *)appKey
                roomId:(NSString *)roomId
                   uid:(NSString *)userId
                 block:(nonnull void (^)(NSString * _Nonnull))block {
    NSObject<RTCTokenDelegate> *delegate = [[NSClassFromString(@"TokenGenerator") alloc] init];

    if ([delegate respondsToSelector:@selector(protocol:tokenWithAppID:appKey:roomId:uid:block:)]) {
        [delegate protocol:self
            tokenWithAppID:appId
                    appKey:appKey
                    roomId:roomId
                       uid:userId
                     block:block];
    }
}

- (void)getRTMPAddr:(NSString *)taskID
              block:(void (^)(NSString *addr))block {
    NSObject<RTCTokenDelegate> *delegate = [[NSClassFromString(@"TokenGenerator") alloc] init];

    if ([delegate respondsToSelector:@selector(protocol:getRTMPAddr:block:)]) {
        [delegate protocol:self getRTMPAddr:taskID block:block];
    }
}



@end
