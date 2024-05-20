// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsCollectionView.h"
#import <Masonry/Masonry.h>
@interface VELSettingsHeaderFooterView : UICollectionReusableView
@property (nonatomic, strong) UIView *contentView;
@end
@implementation VELSettingsHeaderFooterView

- (void)setContentView:(UIView *)contentView {
    if (_contentView != contentView) {
        [_contentView removeFromSuperview];
        _contentView = contentView;
        if (contentView != nil) {
            [self addSubview:contentView];
            [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
    }
}

@end
@interface VELSettingsCollectionView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) VELCollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSDate *lastTouchDate;
@end

@implementation VELSettingsCollectionView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.itemMargin = 10;
        self.headerHeight = 0;
        _scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layoutMode = VELCollectionViewLayoutModeLeft;
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}
- (void)setAllowSelection:(BOOL)allowSelection {
    _allowSelection = allowSelection;
    self.collectionView.allowsSelection = allowSelection;
}
- (void)setModels:(NSArray<__kindof VELSettingsBaseViewModel *> *)models {
    _models = models;
    [models enumerateObjectsUsingBlock:^(VELSettingsBaseViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.collectionView registerClass:obj.collectionCellClass forCellWithReuseIdentifier:obj.identifier];
    }];
    [self.collectionView reloadData];
}

- (void)selecteIndex:(NSInteger)index animation:(BOOL)animation {
    if (!self.allowSelection || index < 0 || index >= self.models.count) {
        return;
    }
    [self.collectionView reloadData];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                                      animated:animation
                                scrollPosition:(UICollectionViewScrollPositionNone)];
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;
    self.flowLayout.scrollDirection = scrollDirection;
    [self.collectionView reloadData];
}

- (void)setLayoutMode:(VELCollectionViewLayoutMode)layoutMode {
    _layoutMode = layoutMode;
    self.flowLayout.mode = layoutMode;
    [self.collectionView reloadData];
}
- (void)setItemMargin:(CGFloat)itemMargin {
    _itemMargin = itemMargin;
    [self.collectionView reloadData];
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.models[indexPath.item].identifier
                                                                           forIndexPath:indexPath];
    [(id <VELSettingsUIViewProtocol>)cell setModel:self.models[indexPath.row]];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.itemMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.itemMargin;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    VELSettingsHeaderFooterView *view = (VELSettingsHeaderFooterView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                        withReuseIdentifier:@"VELSettingsHeaderFooterView"
                                                                               forIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        view.contentView = self.headerView;
        return view;
    }
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.headerView == nil) {
        return CGSizeZero;
    }
    return CGSizeMake(collectionView.frame.size.width, self.headerHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.lastTouchDate != nil && [NSDate.date timeIntervalSinceDate:self.lastTouchDate] < 0.2) {
        self.lastTouchDate = [NSDate date];
        return;
    }
    self.lastTouchDate = [NSDate date];
    VELSettingsBaseViewModel *model = self.models[indexPath.row];
    if (self.selectedItemBlock) {
        self.selectedItemBlock(model, indexPath.item);
    }
    if (model.selectedBlock) {
        model.selectedBlock(model, indexPath.item);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = 50;
    VELSettingsBaseViewModel *model = self.models[indexPath.item];
    if (model.size.width > 0) {
        itemWidth = model.size.width;
    } else {
        CGFloat width = collectionView.frame.size.width;
        if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            CGFloat margin = (self.models.count - 1) * self.itemMargin;
            itemWidth = (width - margin) / MAX(self.models.count, 1);
            itemWidth = MAX(itemWidth, 70);
        } else {
            itemWidth = width - VELUIEdgeInsetsGetHorizontalValue(self.flowLayout.sectionInset);
            if (self.numberOfColumns > 0) {
                CGFloat margin = (self.numberOfColumns - 1) * self.itemMargin;
                itemWidth = (itemWidth - margin) / self.numberOfColumns;
            }
        }
    }
    
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        if (collectionView.vel_width > 0) {
            itemWidth = MIN(collectionView.vel_width - VELUIEdgeInsetsGetHorizontalValue(self.flowLayout.sectionInset),
                            itemWidth);
        }
    }
    
    CGFloat itemHeight = 52;
    if (model.size.height > 0) {
        itemHeight = model.size.height;
    } else {
        if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            itemHeight = collectionView.vel_height - VELUIEdgeInsetsGetVerticalValue(self.flowLayout.sectionInset);
        } else {
            itemHeight = collectionView.vel_height;
        }
    }
    
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        if (collectionView.frame.size.height > 0) {
            itemHeight = MIN(collectionView.frame.size.height, itemHeight);
        }
    }
    
    return CGSizeMake(itemWidth, itemHeight);
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.allowsMultipleSelection = NO;
        _collectionView.allowsSelection = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = UIColor.clearColor;
        [self.collectionView registerClass:[VELSettingsHeaderFooterView class]
                forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                       withReuseIdentifier:@"VELSettingsHeaderFooterView"];
        [self.collectionView registerClass:[VELSettingsHeaderFooterView class]
                forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                       withReuseIdentifier:@"VELSettingsHeaderFooterView"];
    }
    return _collectionView;
}

- (VELCollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[VELCollectionViewFlowLayout alloc] init];
        _flowLayout.mode = VELCollectionViewLayoutModeLeft;
        _flowLayout.minimumLineSpacing = self.itemMargin;
        _flowLayout.minimumInteritemSpacing = self.itemMargin;
        _scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}
@end
