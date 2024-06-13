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
#import <CommonCrypto/CommonDigest.h>

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

#if ENV_ONLINE
- (void)protocol:(RTCTokenProtocol *)protocol getRTMPAddr:(NSString *)taskID block:(void (^)(NSString * _Nonnull))block {
    if (block) {
        block(@"");
    }
}
#else
- (void)protocol:(RTCTokenProtocol *)protocol getRTMPAddr:(NSString *)taskID block:(void (^)(NSString * _Nonnull))block {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    NSTimeInterval expire = timeStamp + 7200;
    NSString *path = [NSString stringWithFormat:@"/rtc_test/%@", taskID];
    NSString *authKey = @"Uq8e962ghCCY2pBUB9Me2Fwy";
    NSString *keyStr = [NSString stringWithFormat:@"%@%@%.0f", path, authKey, expire];
    
    const char *cKeyStr = [keyStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cKeyStr, (CC_LONG)strlen(cKeyStr), result);
    NSMutableString *sign = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [sign appendFormat:@"%02x",result[i]];
    }
    
    NSString *addr = [NSString stringWithFormat:@"rtmp://fcdn-test-hl.uplive.ixigua.com/rtc_test/%@?sign=%@&expire=%.0f", taskID, sign, expire];
    if (block) {
        block(addr);
    }
}
#endif

@end
