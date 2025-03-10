// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaItemButton.h"
#import "ToolKit.h"

@implementation MiniDramaItemButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clipsToBounds = NO;
        [self bingFont:[UIFont systemFontOfSize:12] status:MiniDramaMainItemStatusDeactive];
        [self bingFont:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium] status:MiniDramaMainItemStatusActive];
        [self bingTitleColor:[UIColor colorWithWhite:1 alpha:0.7] status:MiniDramaMainItemStatusDeactive];
        [self bingTitleColor:[UIColor colorWithWhite:1 alpha:0.7] status:MiniDramaMainItemStatusActive];
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
