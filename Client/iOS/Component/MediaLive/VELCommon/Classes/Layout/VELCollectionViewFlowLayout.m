// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELCollectionViewFlowLayout.h"

@interface VELCollectionViewFlowLayout ()

@property (nonatomic, assign, readonly) BOOL isHorizontal;

@end

@implementation VELCollectionViewFlowLayout

- (void)setMode:(VELCollectionViewLayoutMode)mode {
    _mode = mode;
    [self invalidateLayout];
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<__kindof UICollectionViewLayoutAttributes *> *attrsSuper = [super layoutAttributesForElementsInRect:rect];
    NSArray<__kindof UICollectionViewLayoutAttributes *> *attrs = [[NSArray alloc] initWithArray:attrsSuper copyItems:YES];
    
    if (_mode == VELCollectionViewLayoutModeLeft) {
        return attrs;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (UICollectionViewLayoutAttributes *at in attrs) {
        [self addAttr:at into:dict];
    }
    
    CGFloat maxLength = self.isHorizontal ? self.collectionView.frame.size.width : self.collectionView.frame.size.height;
    for (NSArray *arr in [dict allValues]) {
        CGFloat totalLength = [self lineLengthOfAttr:arr];
        if (totalLength >= maxLength) {
            return attrs;
        }
    }
    
    for (NSArray *arr in [dict allValues]) {
        [self resetLineAttr:arr];
    }
    
    return attrs;
}

- (void)addAttr:(UICollectionViewLayoutAttributes *)attr into:(NSMutableDictionary *)dict {
    NSNumber *key = [NSNumber numberWithFloat:(self.isHorizontal ? (attr.frame.size.height + attr.frame.origin.y) : (attr.frame.size.width + attr.frame.origin.x))];
    NSMutableArray *arr = [dict objectForKey:key];
    if (arr == nil) {
        arr = [NSMutableArray array];
        [dict setObject:arr forKey:key];
    }
    [arr addObject:attr];
}

- (CGFloat)lineLengthOfAttr:(NSArray<UICollectionViewLayoutAttributes *> *)attrs {
    CGFloat totalLength = 0.f;
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        totalLength += attr.size.width;
    }
    totalLength += self.minimumLineSpacing * (attrs.count - 1);
    totalLength += self.isHorizontal ? (self.sectionInset.left + self.sectionInset.right) : (self.sectionInset.top + self.sectionInset.bottom);
    return totalLength;
}

- (void)resetLineAttr:(NSArray<UICollectionViewLayoutAttributes *> *)attrs {
    CGFloat totalLength = [self lineLengthOfAttr:attrs];
    CGFloat maxLength = self.isHorizontal ? self.collectionView.frame.size.width : self.collectionView.frame.size.height;
    if (totalLength >= maxLength) {
        return;
    }
    
    if (_mode == VELCollectionViewLayoutModeCenter) {
        CGFloat start = (maxLength - totalLength) / 2 + (self.isHorizontal ? self.sectionInset.left : self.sectionInset.top);
        for (UICollectionViewLayoutAttributes *attr in attrs) {
            CGRect frame = attr.frame;
            if (self.isHorizontal) {
                frame.origin.x = start;
            } else {
                frame.origin.y = start;
            }
            attr.frame = frame;
            
            start += (self.isHorizontal ? frame.size.width : frame.size.height) + self.minimumLineSpacing;
        }
    } else if (_mode == VELCollectionViewLayoutModeExpand) {
        CGFloat start = (self.isHorizontal ? self.sectionInset.left : self.sectionInset.top);
        CGFloat expandLength = (maxLength - totalLength) / attrs.count;
        for (UICollectionViewLayoutAttributes *attr in attrs) {
            CGRect frame = attr.frame;
            if (self.isHorizontal) {
                frame.origin.x = start;
                frame.size.width += expandLength;
                start += frame.size.width + self.minimumLineSpacing;
            } else {
                frame.origin.y = start;
                frame.size.height += expandLength;
                start += frame.size.height + self.minimumLineSpacing;
            }
            attr.frame = frame;
        }
    }
}

- (BOOL)isHorizontal {
    return self.scrollDirection == UICollectionViewScrollDirectionHorizontal;
}

- (CGFloat)lengthOfRect:(CGRect)rect {
    return self.isHorizontal ? (rect.origin.y + rect.size.height) : (rect.origin.x + rect.size.width);
}

@end
