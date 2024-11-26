//
//  TokenGenerator.m
//  TokenGenerator
//
//  Created by bytedance on 2024/3/15.
//

#import <ToolKit/ToolKit.h>
#import "NetworkingManager+RTCToken.h"
#import "TokenGenerator.h"

@import RTCAPIExample;

@interface TokenGenerator () <RTCTokenProtocol>

@end

@implementation TokenGenerator

#pragma mark - RTCTokenProtocol
+ (NSString * _Nonnull)rtcAppId {
    return [PublicParameterComponent share].appId ?: RTCAPPID;
}

+ (void)generateTokenWithRoomId:(NSString *_Nonnull)roomId
                         userId:(NSString *_Nonnull)userId
                     completion:(void (^_Nonnull)(NSString *_Nullable))completion {
    NSString *appId = [TokenGenerator rtcAppId];
    NSString *appKey = RTCAPPKey;

    [[ToastComponent shareToastComponent] showLoading];
    [NetworkingManager tokenWithAppID:appId
                               appKey:appKey
                               roomId:roomId
                                  uid:userId
                                block:^(NSString *_Nullable errorDescription, NSString *_Nullable RTCToken) {
        [[ToastComponent shareToastComponent] dismiss];

        if (RTCToken && RTCToken.length > 0) {
            if (completion) {
                completion(RTCToken);
            }
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:errorDescription];
        }
    }];
}

@end
