// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "NSString+VELAdd.h"
#import <objc/runtime.h>
#import "NSData+VELAdd.h"
@implementation NSString (VELAdd)

- (NSString *)vel_hmacSha256StringWithKey:(NSString *)key {
    NSData *strData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [strData vel_hmacSha256StringWithKey:key];
}

- (NSData *)vel_hmacSha256DataWithKey:(NSString *)key {
    NSData *strData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [strData vel_hmacSha256DataWithKey:key];
}

- (NSData *)vel_hmacSha256DataWithKeyData:(NSData *)keyData {
    NSData *strData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [strData vel_hmacSha256DataWithKeyData:keyData];
}

- (NSString *)vel_hmacSha256StringWithKeyData:(NSData *)keyData {
    NSData *strData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [strData vel_hmacSha256StringWithKeyData:keyData];
}

- (NSString *)vel_hashSha256String {
    NSData *strData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [strData vel_hashSha256String];
}

- (NSData *)vel_hexData {
    NSString * string = [self lowercaseString];
    NSMutableData *data = [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    int length = (int)string.length;
    while (i < length - 1) {
        char c = [string characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
            continue;
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
}

- (NSString *)vel_urlEncode {
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@";
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    static NSUInteger const batchSize = 50;
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    while (index < self.length) {
        NSUInteger length = MIN(self.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);
        range = [self rangeOfComposedCharacterSequencesForRange:range];
        NSString *substring = [self substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        index += range.length;
    }
    return escaped;
}

- (NSString *)vel_transformToPinyin {
    NSMutableString *mutableString = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    mutableString = (NSMutableString *)[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    NSString *str = [mutableString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return str;
}

- (NSString *)vel_trim {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

- (BOOL)vel_isValidURL {
    if(self.length < 6 || [self rangeOfString:@"://"].location == NSNotFound) {
        return NO;
    }
    return self.vel_URLValue != nil && self.vel_URLValue.scheme != nil;
}

- (NSString *)vel_validURLString {
    NSString *trimStr = [self vel_trim];
    if (![trimStr vel_isValidURL]) {
        return nil;
    }
    return trimStr.vel_URLValue.absoluteString;
}

- (NSString *)vel_validPushURLString {
    NSString *trimStr = [self vel_trim];
    if (![trimStr vel_isValidURL]) {
        return nil;
    }
    NSURL *url = trimStr.vel_URLValue;
    NSArray <NSString *>* validSchemes = @[@"rtmp", @"rtmpq", @"rtmps", @"http", @"https", @"srt"/*, @"rts", @"rtspt", @"rtspu"*/];
    if (url.port != nil || ![validSchemes containsObject:url.scheme]) {
        return nil;
    }
    return url.absoluteString;
}

static char kAssociatedObjectKey_urlValue;
- (NSURL *)vel_URLValue {
    NSURL *url = (NSURL *)objc_getAssociatedObject(self, &kAssociatedObjectKey_urlValue);
    if (url == nil) {
        url = [NSURL URLWithString:self];
        objc_setAssociatedObject(self, &kAssociatedObjectKey_urlValue, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return url;
}
@end
