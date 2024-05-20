// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (VELAdd)
// hmac sha256
- (NSString *)vel_hmacSha256StringWithKey:(NSString *)key;
// hmac sha256
- (NSData *)vel_hmacSha256DataWithKey:(NSString *)key;
// hmac sha256
- (NSData *)vel_hmacSha256DataWithKeyData:(NSData *)keyData;
// hmac sha256
- (NSString *)vel_hmacSha256StringWithKeyData:(NSData *)keyData;
// hash sha 256
- (NSString *)vel_hashSha256String;
- (NSData *)vel_hexData;
// query percent encode
- (NSString *)vel_urlEncode;
- (NSString *)vel_transformToPinyin;
- (NSString *)vel_trim;
- (BOOL)vel_isValidURL;
- (nullable NSString *)vel_validURLString;
- (nullable NSString *)vel_validPushURLString;
@end

NS_ASSUME_NONNULL_END
