// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSwitchTabView.h"

#import <Masonry/Masonry.h>
#import <MediaLive/VELCommon.h>

@implementation VELSwitchIndicatorLineStyle
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.widthRatio = 0.5;
        self.height = 2;
        self.bottomMargin = 1;
        self.cornerRadius = 1;
        self.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    }
    return self;
}
@end
@interface VELSwitchTabView ()

@property (nonatomic) BOOL shouldIgnoreAnimation;
@property (nonatomic, assign) NSInteger isFirstTemp;
@property (nonatomic, strong) VELCollectionViewFlowLayout *flowLayout;

@end

@implementation VELSwitchTabView

- (instancetype)initWithTitles:(NSArray *)categories {
    if (self = [super init]) {
        _itemMargin = 32;
        _position = VELSwitchTabPositionLeft;
        [self addSubview:self.collectionView];
        [self.collectionView addSubview:self.indicatorLine];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.categories = categories;
        _isFirstTemp = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.indicatorLine.frame = [self indicatorLineFrameForIndex:0];
        });
    }
    return self;
}
- (void)setPosition:(VELSwitchTabPosition)position {
    _position = position;
    _flowLayout.mode = (VELCollectionViewLayoutMode)position;
}

- (void)setItemMargin:(CGFloat)itemMargin {
    _itemMargin = itemMargin;
    _flowLayout.minimumLineSpacing = itemMargin;
    _flowLayout.minimumInteritemSpacing = itemMargin;
}
- (void)reloadData {
    [self.flowLayout invalidateLayout];
    [self.collectionView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self selectItemAtIndex:self.selectedIndex animated:NO];
    });
}

- (void)refreshWithTitles:(NSArray *)categories {
    self.categories = categories;
    [self.collectionView reloadData];
}


- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (index >= _categories.count) {
        return;
    }
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:animated scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    self.selectedIndex = index;
}

- (void)setIndicatorLineStyle:(VELSwitchIndicatorLineStyle *)indicatorLineStyle {
    _indicatorLineStyle = indicatorLineStyle;
    
    self.indicatorLine.backgroundColor = indicatorLineStyle.backgroundColor;
    self.indicatorLine.layer.cornerRadius = indicatorLineStyle.cornerRadius;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VELMainTabCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VELMainTabCell vel_identifier] forIndexPath:indexPath];
    cell.hightlightTextColor = self.hightlightTextColor;
    cell.normalTextColor = self.normalTextColor;
    [cell renderWithTitle:self.categories[indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.shouldIgnoreAnimation = YES;
    [self setSelectedIndex:indexPath.row updateLine:NO];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = self.frame.size.height;
    CGFloat cellWidth = [self itemWidthForIndexPath:indexPath.row];
    return CGSizeMake(cellWidth, cellHeight);
}

#pragma mark - Utils

- (CGRect)indicatorLineFrameForIndex:(NSInteger)index {
//    if (self.categories.count <= 1) return CGRectZero;
    
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if (self.indicatorLineStyle != nil) {
        NSInteger width = attributes.frame.size.width * self.indicatorLineStyle.widthRatio;
        NSInteger height = self.indicatorLineStyle.height;
        NSInteger bottomMargin = self.indicatorLineStyle.bottomMargin;
        return CGRectMake(attributes.frame.origin.x + (attributes.frame.size.width - width) / 2, self.bounds.size.height - bottomMargin - height, width, height);
    }

    if (_isFirstTemp < 2 && index == 0) {
        _isFirstTemp = _isFirstTemp + 1;
        return CGRectMake(attributes.frame.origin.x + (attributes.frame.size.width-26)/2, self.bounds.size.height - 2, 26, 2);
    }
    else {
        return CGRectMake(attributes.frame.origin.x + (attributes.frame.size.width-26)/2, self.bounds.size.height - 2, 26, 2);
    }
}

- (CGFloat)itemWidthForIndexPath:(NSInteger)index {
    
    NSString *title = self.categories[index];
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
    NSStringDrawingUsesFontLeading;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:15]};
    CGSize textSize = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, self.bounds.size.height)
                                          options:opts
                                       attributes:attributes
                                          context:nil].size;
    return textSize.width+5;
}

- (void)updateIndicatorLineFrameWithProportion:(CGFloat)proportion {
    if (proportion<0) {
        return;
    }
    if (self.categories.count <= 1) {
        self.indicatorLine.frame = CGRectZero;
        return;
    }
    NSInteger proportionInteger = floor(proportion) < 0 ? 0 : floor(proportion) ;
    CGFloat proportionDecimal = proportion - floor(proportion);
    
    CGFloat indicatorWidth = 0;
    CGFloat indicatorOffsetX = 0;
    if (proportion < 0) {
        UICollectionViewLayoutAttributes *firstTitleLayoutAttribute = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//        indicatorWidth = firstTitleLayoutAttribute.bounds.size.width / 2;
        if (self.indicatorLineStyle) {
            indicatorWidth = firstTitleLayoutAttribute.frame.size.width * self.indicatorLineStyle.widthRatio;
        } else {
            indicatorWidth = 26;
        }
        indicatorOffsetX = proportion * firstTitleLayoutAttribute.bounds.size.width + indicatorWidth / 2;
        
    } else if (proportionInteger >= self.categories.count - 1) {
        NSInteger numberOfCell = [self.collectionView numberOfItemsInSection:0];
        UICollectionViewLayoutAttributes *lastTitleLayoutAttribute = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:numberOfCell - 1 inSection:0]];
//        indicatorWidth = lastTitleLayoutAttribute.bounds.size.width / 2;
        if (self.indicatorLineStyle) {
            indicatorWidth = lastTitleLayoutAttribute.frame.size.width * self.indicatorLineStyle.widthRatio;
        } else {
            indicatorWidth = 26;
        }
        indicatorOffsetX = lastTitleLayoutAttribute.frame.origin.x + (lastTitleLayoutAttribute.bounds.size.width - indicatorWidth) / 2 + proportionDecimal * lastTitleLayoutAttribute.bounds.size.width;
        
    } else {
        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:proportionInteger inSection:0];
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:proportionInteger + 1 inSection:0];
        
        UICollectionViewLayoutAttributes *currentLayoutAttribute = [self.collectionView layoutAttributesForItemAtIndexPath:currentIndexPath];
        UICollectionViewLayoutAttributes *nextLayoutAttribute = [self.collectionView layoutAttributesForItemAtIndexPath:nextIndexPath];
        if (self.indicatorLineStyle) {
            indicatorWidth = currentLayoutAttribute.bounds.size.width * self.indicatorLineStyle.widthRatio * (1 - proportionDecimal) + nextLayoutAttribute.bounds.size.width * self.indicatorLineStyle.widthRatio * (proportionDecimal);
        } else {
            indicatorWidth = 26;
        }
        CGFloat currentCenter = currentLayoutAttribute.frame.origin.x + currentLayoutAttribute.frame.size.width / 2;
        CGFloat nextCenter = nextLayoutAttribute.frame.origin.x + nextLayoutAttribute.frame.size.width / 2;
        indicatorOffsetX = currentCenter + (nextCenter - currentCenter) * proportionDecimal - indicatorWidth / 2;
    }
    if (self.indicatorLineStyle) {
        self.indicatorLine.frame = CGRectMake(indicatorOffsetX, self.bounds.size.height - 2 - self.indicatorLineStyle.bottomMargin, indicatorWidth, 2);
    } else {
        self.indicatorLine.frame = CGRectMake(indicatorOffsetX, self.bounds.size.height - 2, indicatorWidth, 2);
    }
}

#pragma mark - getter && setter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[VELMainTabCell class] forCellWithReuseIdentifier:[VELMainTabCell vel_identifier]];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

- (VELCollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        VELCollectionViewFlowLayout *flowLayout = [[VELCollectionViewFlowLayout alloc] init];
        flowLayout.mode = (VELCollectionViewLayoutMode)self.position;
        flowLayout.minimumLineSpacing = self.itemMargin;
        flowLayout.minimumInteritemSpacing = self.itemMargin;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout = flowLayout;
    }
    return _flowLayout;
}

- (UIView *)indicatorLine {
    if (!_indicatorLine) {
        _indicatorLine = [[UIView alloc] init];
        _indicatorLine.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    }
    return _indicatorLine;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex updateLine:(BOOL)updateLine {
    _selectedIndex = selectedIndex;
    if (updateLine) {
        self.indicatorLine.frame = [self indicatorLineFrameForIndex:selectedIndex];
    }
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(switchTabDidSelectedAtIndex:)]) {
        [self.delegate switchTabDidSelectedAtIndex:selectedIndex];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex updateLine:YES];
}

- (void)setProportion:(float)proportion {
    _proportion = proportion;
    
    [self updateIndicatorLineFrameWithProportion:proportion];
}

@end
