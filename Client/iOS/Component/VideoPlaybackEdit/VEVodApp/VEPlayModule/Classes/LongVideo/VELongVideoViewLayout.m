// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELongVideoViewLayout.h"
#import <ToolKit/UIColor+String.h>
#define VELongTopCellWidth          (UIScreen.mainScreen.bounds.size.width)
#define VELongTopCellHeight         (VELongTopCellWidth * (9.00 / 16.00))

#define VELongHeaderWidth           (UIScreen.mainScreen.bounds.size.width)
#define VELongHeaderHeight          (50.0)

#define VELongNormalSectionMargin   (12.0)
#define VELongNormalItemEdge        (12.0)
#define VELongNormalCellWidth       (((UIScreen.mainScreen.bounds.size.width) - VELongNormalItemEdge - 2 * VELongNormalSectionMargin) / 2.0)
#define VELongNormalCellHeight      (VELongNormalCellWidth * (162.0 / 170.0))


@interface VELongCollectionSectionItem : NSObject

@property (nonatomic, strong) UICollectionViewLayoutAttributes *headerAttributes;

@property (nonatomic, strong) NSArray *items;

@end

@implementation VELongCollectionSectionItem

@end

@interface VELongVideoViewLayout ()

@property (nonatomic, strong) NSMutableArray<VELongCollectionSectionItem *> *attributes;

@end

@implementation VELongVideoViewLayout

- (NSMutableArray *)attributes {
    if (!_attributes) {
        _attributes = [NSMutableArray array];
    }
    return _attributes;
}

- (void)prepareLayout {
    [super prepareLayout];
    [self.attributes removeAllObjects];
    NSInteger sectionCount = [self.collectionView numberOfSections];
    for (NSInteger sectionIdx = 0; sectionIdx < sectionCount; sectionIdx++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:sectionIdx];
        NSMutableArray *sectionItems = [NSMutableArray array];
        for (NSInteger itemIdx = 0; itemIdx < itemCount; itemIdx++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIdx inSection:sectionIdx];
            id obj = [self createLayoutAttributesForItemAtIndexPath:indexPath];
            [sectionItems addObject:obj];
        }
        VELongCollectionSectionItem *item = [VELongCollectionSectionItem new];
        item.items = sectionItems;
        item.headerAttributes = [self createLayoutAttributesForHeaderAtSection:sectionIdx];
        [self.attributes addObject:item];
    }
}

- (UICollectionViewLayoutAttributes *)createLayoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGRect frame = CGRectZero;
    switch (indexPath.section) {
        case 0: {
            frame.origin.x = 0;
            frame.origin.y = 0;
            frame.size.width = VELongTopCellWidth;
            frame.size.height = VELongTopCellHeight;
        }
            break;
        default: {
            frame.origin.x = (indexPath.row % 2) ? (VELongNormalItemEdge + VELongNormalCellWidth + VELongNormalSectionMargin) : VELongNormalSectionMargin;
            frame.origin.y = VELongTopCellHeight + (indexPath.section * VELongHeaderHeight) + ((indexPath.section - 1) * (VELongNormalCellHeight * 2)) + ((indexPath.row / 2) * VELongNormalCellHeight);
            frame.size.width = VELongNormalCellWidth;
            frame.size.height = VELongNormalCellHeight;
        };
            break;
    }
    attributes.frame = frame;
    return attributes;
}

- (UICollectionViewLayoutAttributes *)createLayoutAttributesForHeaderAtSection:(NSInteger)section {
    NSIndexPath *sectionFirstItem = [NSIndexPath indexPathForItem:0 inSection:section];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:sectionFirstItem];
    CGRect frame = CGRectZero;
    switch (section) {
        case 0: {
            frame.origin.x = 0;
            frame.origin.y = 0;
            frame.size.width = 0;
            frame.size.height = 0;
        }
            break;
        default: {
            frame.origin.x = 0;
            frame.origin.y = ((section - 1) * (VELongHeaderHeight + VELongNormalCellHeight * 2)) + VELongTopCellHeight;
            frame.size.width = (UIScreen.mainScreen.bounds.size.width);
            frame.size.height = VELongHeaderHeight;
        }
            break;
    }
    attributes.frame = frame;
    return attributes;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray<UICollectionViewLayoutAttributes *> *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy] ?: [NSMutableArray array];
    for (VELongCollectionSectionItem *sectionItem in self.attributes) {
        [attributes addObject:sectionItem.headerAttributes];
        for (UICollectionViewLayoutAttributes * _Nonnull obj in sectionItem.items) {
            [attributes addObject:obj];
        }
    }
    return attributes;
}

- (CGSize)collectionViewContentSize {
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSInteger lastSectionItemCount = [self.collectionView numberOfItemsInSection:sectionCount - 1];
    CGFloat height = VELongTopCellHeight + (sectionCount - 2) * (VELongHeaderHeight + VELongNormalCellHeight * 2) + VELongHeaderHeight + ((lastSectionItemCount + 1) / 2) * VELongNormalCellHeight;
    CGFloat width = (UIScreen.mainScreen.bounds.size.width);
    return CGSizeMake(width, height);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end

@interface VELongVideoHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation VELongVideoHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        _titleLabel.textColor = [UIColor colorFromRGBHexString:@"0x0C0D0F" andAlpha:255.0];
        _titleLabel.frame = CGRectMake(0.0, 0.0, (UIScreen.mainScreen.bounds.size.width), VELongHeaderHeight);
    }
    return _titleLabel;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = [NSString stringWithFormat:@"   %@", title];
}

@end
