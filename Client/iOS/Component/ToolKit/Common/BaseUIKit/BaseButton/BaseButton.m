// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseButton.h"

@interface BaseButton ()

@property (nonatomic, strong) NSMutableDictionary *bingDic;

@end

@implementation BaseButton

- (void)setStatus:(NSInteger)status {
    _status = status;
    NSString *key = [NSString stringWithFormat:@"status_%ld", (long)status];
    UIImage *image = self.bingDic[key];
    if (image && [image isKindOfClass:[UIImage class]]) {
        [self setImage:image forState:UIControlStateNormal];
    }
    NSString *fontKey = [NSString stringWithFormat:@"status_font_%ld", (long)status];
    UIFont *font = self.bingDic[fontKey];
    if (font && [font isKindOfClass:[UIFont class]]) {
        self.titleLabel.font = font;
    }
    NSString *titleColorKey = [NSString stringWithFormat:@"status_title_color_%ld", (long)status];
    UIColor *color = self.bingDic[titleColorKey];
    if (color && [color isKindOfClass:[UIColor class]]) {
        [self setTitleColor:color forState:UIControlStateNormal];
    }
}

- (void)bingImage:(UIImage *)image status:(NSInteger)status {
    if (image) {
        NSString *key = [NSString stringWithFormat:@"status_%ld", (long)status];
        [self.bingDic setValue:image forKey:key];
        if (status == 0) {
            [self setImage:image forState:UIControlStateNormal];
        }
    }
}

- (void)bingFont:(UIFont *)font status:(NSInteger)status {
    if (font) {
        NSString *key = [NSString stringWithFormat:@"status_font_%ld", (long)status];
        [self.bingDic setValue:font forKey:key];
        if (status == 0) {
            self.titleLabel.font = font;
        }
    }
}

- (void)bingTitleColor:(UIColor *)color status:(NSInteger)status {
    if (color) {
        NSString *key = [NSString stringWithFormat:@"status_title_color_%ld", (long)status];
        [self.bingDic setValue:color forKey:key];
        if (status == 0) {
            [self setTitleColor:color forState:UIControlStateNormal];
        }
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}

#pragma mark - Getter

- (NSMutableDictionary *)bingDic {
    if (!_bingDic) {
        _bingDic = [[NSMutableDictionary alloc] init];
    }
    return _bingDic;
}

@end
