//
//  MiniDramaCarouselViewFlowLayout.m
//  Pods
//
//  Created by ByteDance on 2024/11/15.
//

#import "MiniDramaCarouselViewFlowLayout.h"
#import <Masonry/Masonry.h>

@interface MiniDramaCarouselViewFlowLayout ()

@property (nonatomic, assign)CGFloat scale;
@property (nonatomic, assign)CGFloat alpha;

@end

@implementation MiniDramaCarouselViewFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scale = 0.8333333;
        self.alpha = 0.3;
    }
    return self;
}

#pragma mark- UICollectionViewFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributesArray = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
    CGRect visibleRect = {self.collectionView.contentOffset, self.collectionView.bounds.size};
    for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
        if (!CGRectIntersectsRect(visibleRect, attributes.frame)) {
            continue;
        }
        CGFloat width = self.collectionView.frame.size.width;
        if (width <= 0) {
            continue;
        }
        CGFloat centerX = self.collectionView.contentOffset.x + width / 2;
        CGFloat delta = ABS(attributes.center.x - centerX);
        CGFloat scale = MAX(1 - delta / width * 0.4, self.scale);
        CGFloat alpha = MAX(1 - delta / width, self.alpha);

        CGFloat tranX = 0;
        CGFloat tranY = 0;
        if (ABS(attributes.center.x  - centerX) < 0.5) { // center
            alpha = 1.0;
        } else if (attributes.center.x  - centerX < 0) { // left
            tranX = 1.2 * attributes.size.width * (1 - scale) / 2;
            tranY = attributes.size.height * (1- scale);
        } else { // right
            tranX = -1.2 * attributes.size.width * (1 - scale) / 2;
            tranY = attributes.size.height * (1- scale);
        }
        attributes.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scale, scale), tranX, tranY);
        attributes.alpha = alpha;
    }
    return attributesArray;
    
}

@end
