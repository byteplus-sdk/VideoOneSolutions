//
//  TokenGenerator.m
//  TokenGenerator
//
//  Created by bytedance on 2024/3/15.
//

#import "TokenGenerator.h"
#import <ToolKit/RTCTokenProtocol.h>
#import <ToolKit/ToolKit.h>
#import "NetworkingManager+RTCToken.h"

@interface TokenGenerator () <RTCTokenDelegate>

@end

@implementation TokenGenerator

#pragma mark - RTCTokenProtocol

- (void)protocol:(RTCTokenProtocol *)protocol
  tokenWithAppID:(NSString *)appId
          appKey:(NSString *)appKey
          roomId:(NSString *)roomId
             uid:(NSString *)userId
           block:(void (^)(NSString *RTCToken))block {
    
    [[ToastComponent shareToastComponent] showLoading];
    [NetworkingManager tokenWithAppID:appId appKey:appKey roomId:roomId uid:userId block:^(NSString * _Nullable errorDescription, NSString * _Nullable RTCToken) {
        
        [[ToastComponent shareToastComponent] dismiss];
        if (RTCToken && RTCToken.length > 0) {
            if (block) {
                block(RTCToken);
            }
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:errorDescription];
        }
    }];
}

@end
