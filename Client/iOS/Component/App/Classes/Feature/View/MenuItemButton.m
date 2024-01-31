// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "MenuItemButton.h"
#import "Masonry.h"
#import "ToolKit.h"

@interface MenuItemButton ()

@end

@implementation MenuItemButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = NO;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self bingTitleColor:[UIColor colorFromHexString:@"#86909C"] status:ButtonStatusNone];
        [self bingTitleColor:[UIColor colorFromHexString:@"#4080FF"] status:ButtonStatusActive];
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake((contentRect.size.width - 25) * 0.5, 12, 25, 25);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect rect = [super titleRectForContentRect:contentRect];
    CGFloat width = ceil(rect.size.width);
    CGFloat height = ceil(rect.size.height);
    return CGRectMake((contentRect.size.width - width) * 0.5, 37, width, height);
}

@end
