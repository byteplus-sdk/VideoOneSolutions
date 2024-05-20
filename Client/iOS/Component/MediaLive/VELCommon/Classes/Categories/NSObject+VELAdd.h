// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (VELAdd)
- (NSString *)vel_className;
+ (NSString *)vel_className;


+ (void)swizzleOriginal:(SEL)original replace:(SEL)other onInstance:(BOOL)instance;
@end

NS_ASSUME_NONNULL_END
