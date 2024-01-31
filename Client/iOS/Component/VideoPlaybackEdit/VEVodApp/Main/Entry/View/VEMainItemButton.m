//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VEMainItemButton.h"
#import "ToolKit.h"

@implementation VEMainItemButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = NO;
        [self bingFont:[UIFont systemFontOfSize:12] status:VEMainItemStatusDark];
        [self bingFont:[UIFont systemFontOfSize:12] status:VEMainItemStatusLight];
        [self bingFont:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium] status:VEMainItemStatusActive];
        [self bingTitleColor:[UIColor colorFromHexString:@"#0C0D0F"] status:VEMainItemStatusDark];
        [self bingTitleColor:[UIColor colorWithWhite:1 alpha:0.7] status:VEMainItemStatusLight];
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    NSString *title = [self titleForState:self.state];
    if (!title.length) {
        return [super imageRectForContentRect:contentRect];
    }
    return CGRectMake((contentRect.size.width - 28) * 0.5, 4, 28, 28);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect rect = [super titleRectForContentRect:CGRectMake(0, 0, CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat width = ceil(rect.size.width);
    CGFloat height = ceil(rect.size.height);
    return CGRectMake((contentRect.size.width - width) * 0.5, 39 - height * 0.5, width, height);
}

@end
