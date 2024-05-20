// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPopupMenuView.h"
#import "NSObject+VELAdd.h"
#import "NSArray+VELAdd.h"
#import "UIView+VELAdd.h"
#import "VELCommonDefine.h"
@interface VELPopupMenuView ()
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) NSMutableArray<CALayer *> *itemSeparatorLayers;
@property(nonatomic, strong) NSMutableArray<CALayer *> *sectionSeparatorLayers;
@end
@implementation VELPopupMenuView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentEdgeInsets = UIEdgeInsetsZero;
        
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.scrollsToTop = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.contentView addSubview:self.scrollView];
        
        self.itemSeparatorLayers = [[NSMutableArray alloc] init];
        self.sectionSeparatorLayers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setItems:(NSArray<__kindof VELPopupMenuBaseItem *> *)items {
    [_items enumerateObjectsUsingBlock:^(__kindof VELPopupMenuBaseItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.menuView = nil;
    }];
    _items = items;
    if (!items) {
        self.itemSections = nil;
    } else {
        self.itemSections = @[_items];
    }
}

- (void)setItemSections:(NSArray<NSArray<__kindof VELPopupMenuBaseItem *> *> *)itemSections {
    [_itemSections vel_enumerateNestedArrayWithBlock:^(__kindof VELPopupMenuBaseItem * item, BOOL *stop) {
        item.menuView = nil;
    }];
    _itemSections = itemSections;
    [self configureItems];
}

- (void)setItemConfigurationHandler:(void (^)(VELPopupMenuView *, __kindof VELPopupMenuBaseItem *, NSInteger, NSInteger))itemConfigurationHandler {
    _itemConfigurationHandler = [itemConfigurationHandler copy];
    if (_itemConfigurationHandler && self.itemSections.count) {
        for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
            NSArray<VELPopupMenuBaseItem *> *items = self.itemSections[section];
            for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
                VELPopupMenuBaseItem *item = items[row];
                _itemConfigurationHandler(self, item, section, row);
            }
        }
    }
}
- (CALayer *)createSeparatorLayer {
    CALayer *layer = [CALayer layer];
    [layer removeAllAnimations];
    layer.backgroundColor = UIColor.clearColor.CGColor;
    layer.frame = CGRectMake(0, 0, 0, (1 / [[UIScreen mainScreen] scale]));
    return layer;
}
- (void)configureItems {
    __block NSInteger globalItemIndex = 0;
    __block NSInteger separatorIndex = 0;
    [self.scrollView vel_removeAllSubviews];
    [self.itemSeparatorLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        layer.hidden = YES;
    }];
    [self.sectionSeparatorLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        layer.hidden = YES;
    }];
    
    [self enumerateItemsWithBlock:^(VELPopupMenuBaseItem *item, NSInteger section, NSInteger sectionCount, NSInteger row, NSInteger rowCount) {
        item.menuView = self;
        [item updateAppearance];
        if (self.itemConfigurationHandler) {
            self.itemConfigurationHandler(self, item, section, row);
        }
        [self.scrollView addSubview:item];
        BOOL shouldShowItemSeparator = self.shouldShowItemSeparator && row < rowCount - 1;
        if (shouldShowItemSeparator) {
            CALayer *separatorLayer = nil;
            if (separatorIndex < self.itemSeparatorLayers.count) {
                separatorLayer = self.itemSeparatorLayers[separatorIndex];
            } else {
                separatorLayer = [self createSeparatorLayer];
                [self.scrollView.layer addSublayer:separatorLayer];
                [self.itemSeparatorLayers addObject:separatorLayer];
            }
            separatorLayer.hidden = NO;
            separatorLayer.backgroundColor = self.itemSeparatorColor.CGColor;
            separatorIndex++;
        }
        
        globalItemIndex++;
    }];
    
    for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
        BOOL shouldShowSectionSeparator = self.shouldShowSectionSeparator && section < sectionCount - 1;
        if (shouldShowSectionSeparator) {
            CALayer *separatorLayer = nil;
            if (section < self.sectionSeparatorLayers.count) {
                separatorLayer = self.sectionSeparatorLayers[section];
            } else {
                separatorLayer = [self createSeparatorLayer];
                [self.scrollView.layer addSublayer:separatorLayer];
                [self.sectionSeparatorLayers addObject:separatorLayer];
            }
            separatorLayer.hidden = NO;
            separatorLayer.backgroundColor = self.sectionSeparatorColor.CGColor;
        }
    }
}

- (void)setItemSeparatorInset:(UIEdgeInsets)itemSeparatorInset {
    _itemSeparatorInset = itemSeparatorInset;
    [self setNeedsLayout];
}

- (void)setItemSeparatorColor:(UIColor *)itemSeparatorColor {
    _itemSeparatorColor = itemSeparatorColor;
    [self.itemSeparatorLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        layer.backgroundColor = itemSeparatorColor.CGColor;
    }];
}

- (void)setSectionSeparatorInset:(UIEdgeInsets)sectionSeparatorInset {
    _sectionSeparatorInset = sectionSeparatorInset;
    [self setNeedsLayout];
}

- (void)setSectionSeparatorColor:(UIColor *)sectionSeparatorColor {
    _sectionSeparatorColor = sectionSeparatorColor;
    [self.sectionSeparatorLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        layer.backgroundColor = sectionSeparatorColor.CGColor;
    }];
}

- (void)setItemTitleFont:(UIFont *)itemTitleFont {
    _itemTitleFont = itemTitleFont;
    [self enumerateItemsWithBlock:^(VELPopupMenuBaseItem *item, NSInteger section, NSInteger sectionCount, NSInteger row, NSInteger rowCount) {
        [item updateAppearance];
    }];
}

- (void)setItemTitleColor:(UIColor *)itemTitleColor {
    _itemTitleColor = itemTitleColor;
    [self enumerateItemsWithBlock:^(VELPopupMenuBaseItem *item, NSInteger section, NSInteger sectionCount, NSInteger row, NSInteger rowCount) {
        [item updateAppearance];
    }];
}

- (void)setPadding:(UIEdgeInsets)padding {
    _padding = padding;
    [self enumerateItemsWithBlock:^(VELPopupMenuBaseItem *item, NSInteger section, NSInteger sectionCount, NSInteger row, NSInteger rowCount) {
        [item updateAppearance];
    }];
}

- (void)enumerateItemsWithBlock:(void (^)(VELPopupMenuBaseItem *item, NSInteger section, NSInteger sectionCount, NSInteger row, NSInteger rowCount))block {
    if (!block) return;
    for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
        NSArray<VELPopupMenuBaseItem *> *items = self.itemSections[section];
        for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
            VELPopupMenuBaseItem *item = items[row];
            block(item, section, sectionCount, row, rowCount);
        }
    }
}

- (CGSize)sizeThatFitsInContentView:(CGSize)size {
    __block CGFloat width = 0;
    __block CGFloat height = VELUIEdgeInsetsGetVerticalValue(self.padding);
    [self.itemSections vel_enumerateNestedArrayWithBlock:^(__kindof VELPopupMenuBaseItem *item, BOOL *stop) {
        CGSize itemSize = [item sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)];
        CGFloat itemHeight = item.height;
        if (itemHeight < 0) {
            itemHeight = self.itemHeight;
        }
        if (isinf(itemHeight)) {
            itemHeight = itemSize.height;
        }
        height += itemHeight;
        width = MAX(width, MIN(itemSize.width, size.width));
    }];
    size.width = width;
    size.height = height;
    return size;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.contentView.bounds;
    
    CGFloat minY = self.padding.top;
    CGFloat contentWidth = CGRectGetWidth(self.scrollView.bounds);
    NSInteger separatorIndex = 0;
    for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
        NSArray<VELPopupMenuBaseItem *> *items = self.itemSections[section];
        for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
            VELPopupMenuBaseItem *item = items[row];
            CGFloat itemHeight = item.height;
            if (itemHeight < 0) {
                itemHeight = self.itemHeight;
            }
            if (isinf(itemHeight)) {
                itemHeight = [item sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)].height;
            }
            item.frame = CGRectMake(0, minY, contentWidth, itemHeight);
            minY = CGRectGetMaxY(item.frame);
            
            if (self.shouldShowItemSeparator && row < rowCount - 1) {
                CALayer *layer = self.itemSeparatorLayers[separatorIndex];
                if (!layer.hidden) {
                    layer.frame = CGRectMake(self.padding.left + self.itemSeparatorInset.left, minY - (1 / [[UIScreen mainScreen] scale]) + self.itemSeparatorInset.top - self.itemSeparatorInset.bottom, contentWidth - VELUIEdgeInsetsGetHorizontalValue(self.padding) - VELUIEdgeInsetsGetHorizontalValue(self.itemSeparatorInset), (1 / [[UIScreen mainScreen] scale]));
                    separatorIndex++;
                }
            }
        }
        
        if (self.shouldShowSectionSeparator && section < sectionCount - 1) {
            self.sectionSeparatorLayers[section].frame = CGRectMake(0, minY - (1 / [[UIScreen mainScreen] scale]) + self.sectionSeparatorInset.top - self.sectionSeparatorInset.bottom, contentWidth - VELUIEdgeInsetsGetHorizontalValue(self.sectionSeparatorInset), (1 / [[UIScreen mainScreen] scale]));
        }
    }
    minY += self.padding.bottom;
    self.scrollView.contentSize = CGSizeMake(contentWidth, minY);
}
@end
