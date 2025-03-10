// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "EffectColorItem.h"

@interface EffectColorItem ()

@end

@implementation EffectColorItem

@synthesize title = _title;

- (instancetype)initWithTitle:(NSString *)title color:(UIColor *)color {
    self = [super init];
    if (self) {
        _title = title;
        _color = color;
        [color getRed:&_red green:&_green blue:&_blue alpha:&_alpha];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    self = [super init];
    if (self) {
        _title = title;
        _red = red;
        _green = green;
        _blue = blue;
        _color = [UIColor colorWithRed:red green:green blue:blue alpha:1.f];
    }
    return self;
}

@end
