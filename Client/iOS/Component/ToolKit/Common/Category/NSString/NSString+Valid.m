// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "Localizator.h"
#import "NSString+Valid.h"

@implementation NSString (Valid)
- (BOOL)isValidPhoneNumber {
    NSString *phoneRegex = @"^((\\+)|(00))?[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    if (![phoneTest evaluateWithObject:self]) {
        return NO;
    }
    if ([self hasPrefix:@"+86"]) {
        return self.length == (11 + 3) && [self hasPrefix:@"+861"];
    }
    return YES;
}

- (BOOL)isValidEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)isValidNumber {
    NSString *numberRegex = @"[0-9]*";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
    return [numberTest evaluateWithObject:self];
}

@end

@implementation NSString (Format)

+ (NSString *)stringForCount:(NSUInteger)count {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:1];
    if ([[Localizator getCurrentLanguage] isEqualToString:@"en"]) {
        if (count < 1000) {
            return [NSString stringWithFormat:@"%ld", count];
        } else if (count < 1e6) {
            NSNumber *result = [NSNumber numberWithInteger:count];
            float times = [result floatValue] / 1000;
            NSString *countString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:times]];
            return [NSString stringWithFormat:@"%@K", countString];
        } else {
            NSNumber *result = [NSNumber numberWithInteger:count];
            float times = [result floatValue] / (1e6);
            NSString *countString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:times]];
            return [NSString stringWithFormat:@"%@M", countString];
        }
    } else {
        if (count < 10000) {
            return [NSString stringWithFormat:@"%ld", count];
        } else {
            NSNumber *result = [NSNumber numberWithInteger:count];
            float times = [result floatValue] / 10000;
            NSString *countString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:times]];
            return [NSString stringWithFormat:@"%@万", countString];
        }
    }
}

+ (NSString *)timeStringForUTCTime:(NSString *)utcTime {
    NSDateFormatter *utcFormatter = [[NSDateFormatter alloc] init];
    [utcFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [utcFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [utcFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
    NSDate *date = [utcFormatter dateFromString:utcTime];
    NSString *ymdDateStr = [self timeStringForDate:date];
    if (!ymdDateStr) {
        NSArray *components = [utcTime componentsSeparatedByString:@"T"];
        return components[0];
    }
    return ymdDateStr;
}

+ (NSString *)timeStringSinceNow {
    return [self timeStringForDate:[NSDate date]];
}

+ (NSString *)timeStringForDate:(NSDate *)date {
    NSDateFormatter *ymdFormatter = [[NSDateFormatter alloc] init];
    [ymdFormatter setDateFormat:@"dd/MM/yyyy"];
    return [ymdFormatter stringFromDate:date];
}

@end
