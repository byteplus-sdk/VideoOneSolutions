// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (VELAdd)
- (NSString *)vel_md5String;
- (NSString *)vel_hashSha256String;
- (NSString *)vel_hmacSha256StringWithKey:(NSString *)key;
- (NSData *)vel_hmacSha256DataWithKey:(NSString *)key;
- (NSData *)vel_hmacSha256DataWithKeyData:(NSData *)keyData;
- (NSString *)vel_hmacSha256StringWithKeyData:(NSData *)keyData;
- (NSString *)vel_hexString;
@end

NS_ASSUME_NONNULL_END
