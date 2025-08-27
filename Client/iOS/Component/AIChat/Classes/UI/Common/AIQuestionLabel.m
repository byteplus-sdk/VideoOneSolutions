//
//  AIQuestionLabel.m
//  AFNetworking
//
//  Created by ByteDance on 2025/3/14.
//

#import "AIQuestionLabel.h"

@implementation AIQuestionLabel

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.padding)];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.width += self.padding.left + self.padding.right;
    size.height += self.padding.top + self.padding.bottom;
    return size;
}

@end
