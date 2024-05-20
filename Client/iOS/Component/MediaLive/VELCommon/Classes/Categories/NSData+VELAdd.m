// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "NSData+VELAdd.h"
#include <CommonCrypto/CommonCrypto.h>
#include <zlib.h>
@implementation NSData (VELAdd)
- (NSString *)vel_md5String {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, (CC_LONG)self.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)vel_hashSha256String {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(self.bytes, (CC_LONG)self.length, result);
    NSMutableString *hash = [NSMutableString
                             stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}


- (NSString *)vel_hmacSha256StringWithKey:(NSString *)key {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), self.bytes, self.length, result);
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

- (NSData *)vel_hmacSha256DataWithKey:(NSString *)key {
    return [self vel_hmacSha256DataWithKeyData:[key dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSData *)vel_hmacSha256DataWithKeyData:(NSData *)keyData {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    const char *cKey = (const char *)keyData.bytes;
    CCHmac(kCCHmacAlgSHA256, cKey, keyData.length, self.bytes, self.length, result);
    return [[NSData alloc] initWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)vel_hmacSha256StringWithKeyData:(NSData *)keyData {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    const char *cKey = (const char *)keyData.bytes;
    CCHmac(kCCHmacAlgSHA256, cKey, keyData.length, self.bytes, self.length, result);
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

- (NSString *)vel_hexString {
    unsigned char *result = (unsigned char *)self.bytes;
    NSMutableString *hash = [NSMutableString
                             stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}
@end
