// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (VELAdd)
- (NSString *)vel_getQueryEncodeSortKeys:(BOOL)sortKeys urlEncode:(BOOL)urlEncode;
- (NSString *)vel_queryEncodeString;
- (NSString *)vel_queryString;
- (NSString *)vel_sortQueryEncodeString;
- (NSString *)vel_sortQueryString;
@end

NS_ASSUME_NONNULL_END
