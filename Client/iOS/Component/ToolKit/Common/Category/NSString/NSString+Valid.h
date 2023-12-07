// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Valid)
- (BOOL)isValidPhoneNumber;
- (BOOL)isValidEmail;
- (BOOL)isValidNumber;
@end

@interface NSString (Format)

+ (NSString *)stringForCount:(NSUInteger)count;

+ (NSString *)timeStringForUTCTime:(NSString *)utcTime;

+ (NSString *)timeStringSinceNow;

+ (NSString *)timeStringForDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
