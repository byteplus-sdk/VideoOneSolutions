// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ColorItemCell.h"

@interface ColorItemCell ()

@end

@implementation ColorItemCell

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, true);
    CGContextClearRect(context, rect);
    
    BOOL selected = self.selected;
    if (selected) {
        CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
        CGContextSetLineWidth(context, 1.5f);
        CGContextAddEllipseInRect(context, [self innerCircleRect:.75f]);
        CGContextDrawPath(context, kCGPathStroke);
        
        CGContextSetFillColorWithColor(context, [self.color CGColor]);
        CGContextAddEllipseInRect(context, [self innerCircleRect:3.f]);
        CGContextDrawPath(context, kCGPathFill);
    } else {
        CGContextSetFillColorWithColor(context, [self.color CGColor]);
        CGContextAddEllipseInRect(context, [self innerCircleRect:0.f]);
        CGContextDrawPath(context, kCGPathFill);
    }
}

- (CGRect)innerCircleRect:(CGFloat)padding {
    CGRect bounds = self.bounds;
    return CGRectMake(bounds.origin.x + padding, bounds.origin.y + padding, bounds.size.width - 2 * padding, bounds.size.height - 2 * padding);
}

@end
