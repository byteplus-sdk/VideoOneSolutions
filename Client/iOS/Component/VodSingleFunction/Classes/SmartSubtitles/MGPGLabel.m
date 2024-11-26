// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MGPGLabel.h"

@implementation MGPGLabel

- (void)drawTextInRect:(CGRect)rect {
    if (self.strokeWidth > 0) {
        CGSize shadowOffset = self.shadowOffset;
        UIColor *textColor = self.textColor;

        CGContextRef c = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(c, self.strokeWidth);
        CGContextSetLineJoin(c, kCGLineJoinRound);
        CGContextSetTextDrawingMode(c, kCGTextStroke);
        self.textColor = self.strokeColor;
        [super drawTextInRect:rect];
        CGContextSetTextDrawingMode(c, kCGTextFill);
        self.textColor = textColor;
        self.shadowOffset = CGSizeMake(0, 0);
        [super drawTextInRect:rect];
        self.shadowOffset = shadowOffset;
    } else {
        [super drawTextInRect:rect];
    }
}

@end
