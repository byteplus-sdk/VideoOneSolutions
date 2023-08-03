// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

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
