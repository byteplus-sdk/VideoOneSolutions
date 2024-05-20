// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPopupMenuButtonItem.h"
#import "VELCommonDefine.h"
#import "VELPopupMenuView.h"
@implementation VELPopupMenuButtonItem

+ (instancetype)itemWithImage:(UIImage *)image title:(NSString *)title handler:(nullable void (^)(__kindof VELPopupMenuButtonItem *))handler {
    VELPopupMenuButtonItem *item = [[self alloc] init];
    item.image = image;
    item.title = title;
    item.handler = handler;
    return item;
}

- (instancetype)init {
    if (self = [super init]) {
        self.height = -1;
        _button = [[VELUIButton alloc] init];
        self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.button.tintColor = nil;
        [self.button addTarget:self action:@selector(handleButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize btnSize = [self.button sizeThatFits:size];
    if (self.width > 0) {
        btnSize.width = MAX(self.width, btnSize.width);
    }
    if (self.height > 0) {
        btnSize.height = MAX(self.height, btnSize.height);
    }
    return btnSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.button.frame = self.bounds;
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.button setImage:image forState:UIControlStateNormal];
    [self updateButtonImageEdgeInsets];
}

- (void)setImageMarginRight:(CGFloat)imageMarginRight {
    _imageMarginRight = imageMarginRight;
    [self updateButtonImageEdgeInsets];
}

- (void)updateButtonImageEdgeInsets {
    if (self.button.currentImage) {
        self.button.imageEdgeInsets = VELUIEdgeInsetsSetRight(self.button.imageEdgeInsets, self.imageMarginRight);
    }
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor {
    _highlightedBackgroundColor = highlightedBackgroundColor;
    self.button.highlightedBackgroundColor = highlightedBackgroundColor;
}

- (void)handleButtonEvent:(id)sender {
    if (self.menuView.willHandleButtonItemEventBlock) {
        BOOL found = NO;
        for (NSInteger section = 0, sectionCount = self.menuView.itemSections.count; section < sectionCount; section ++) {
            NSArray<VELPopupMenuBaseItem *> *items = self.menuView.itemSections[section];
            for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
                VELPopupMenuBaseItem *item = items[row];
                if (item == self) {
                    self.menuView.willHandleButtonItemEventBlock(self.menuView, self, section, row);
                    found = YES;
                    break;
                }
            }
            if (found) {
                break;
            }
        }
    }
    if (self.handler) {
        self.handler(self);
    }
}

- (void)updateAppearance {
    self.button.titleLabel.font = self.menuView.itemTitleFont;
    [self.button setTitleColor:self.menuView.itemTitleColor forState:UIControlStateNormal];
    self.button.contentEdgeInsets = UIEdgeInsetsMake(0, self.menuView.padding.left, 0, self.menuView.padding.right);
}

@end
