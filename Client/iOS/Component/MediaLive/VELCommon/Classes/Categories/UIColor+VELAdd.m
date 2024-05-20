// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "UIColor+VELAdd.h"

@implementation UIColor (VELAdd)
+ (instancetype)vel_colorWithHexString:(NSString *)hexString {
    if (hexString.length <= 0) {
        return nil;
    }
    NSString *replaceString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([replaceString hasPrefix:@"0x"]) {
        replaceString = [replaceString stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
    }
    NSString *colorString = [replaceString uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3:// #RGB
            alpha = 1.0f;
            red   = [self vel_colorComponentFrom:colorString start:0 length:1];
            green = [self vel_colorComponentFrom:colorString start:1 length:1];
            blue  = [self vel_colorComponentFrom:colorString start:2 length:1];
            break;
        case 4:// #ARGB
            alpha = [self vel_colorComponentFrom:colorString start:0 length:1];
            red   = [self vel_colorComponentFrom:colorString start:1 length:1];
            green = [self vel_colorComponentFrom:colorString start:2 length:1];
            blue  = [self vel_colorComponentFrom:colorString start:3 length:1];
            break;
        case 6:// #RRGGBB
            alpha = 1.0f;
            red   = [self vel_colorComponentFrom:colorString start:0 length:2];
            green = [self vel_colorComponentFrom:colorString start:2 length:2];
            blue  = [self vel_colorComponentFrom:colorString start:4 length:2];
            break;
        case 8:// #AARRGGBB
            alpha = [self vel_colorComponentFrom:colorString start:0 length:2];
            red   = [self vel_colorComponentFrom:colorString start:2 length:2];
            green = [self vel_colorComponentFrom:colorString start:4 length:2];
            blue  = [self vel_colorComponentFrom:colorString start:6 length:2];
            break;
        default: {
            return nil;
        }
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)vel_colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring :[NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

+ (UIColor *)vel_colorFromRGBHexString:(NSString *)hexString {
    if (!hexString || hexString.length<0) {
        return [UIColor clearColor];
    }
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor *)vel_colorFromRGBHexString:(NSString *)hexString andAlpha:(NSInteger)alpha {
    if (!hexString || hexString.length<0) {
        return [UIColor clearColor];
    }
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha/255.0];
}

+ (UIColor *)vel_colorFromRGBAHexString:(NSString *)hexString {
    if (!hexString || hexString.length<0) {
        return [UIColor clearColor];
    }
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF000000) >> 24)/255.0 green:((rgbValue & 0xFF0000) >> 16)/255.0 blue:((rgbValue & 0xFF00)  >> 8)/255.0 alpha:(rgbValue & 0xFF)/255.0];
}

+ (UIColor *)vel_colorFromHexString:(NSString *)hexString {
    if (!hexString) {
        return [UIColor clearColor];
    }
    
    if (hexString.length == 7) {
        return [UIColor vel_colorFromRGBHexString:hexString];
    } else if (hexString.length == 9) {
        return [UIColor vel_colorFromRGBAHexString:hexString];
    } else {
        return [UIColor clearColor];
    }
}

+ (UIColor *)vel_randomColor {
    CGFloat red = arc4random_uniform(255) / 255.0;
    CGFloat green = arc4random_uniform(255) / 255.0;
    CGFloat blue = arc4random_uniform(255) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

+ (NSString *)vel_randomHexColor {
    int red = arc4random_uniform(255);
    int green = arc4random_uniform(255);
    int blue = arc4random_uniform(255);
    return [NSString stringWithFormat:@"#%X%X%X",red,green,blue];
}
@end
