// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VELDnsHelper : NSObject
+ (void)parse:(NSString *)hostName;
+ (NSDictionary <NSString *, NSString *> *)getCachedIpHost;
+ (NSDictionary <NSString *, NSArray <NSString *> *> *)getCachedHostIpList;
@end

NS_ASSUME_NONNULL_END
