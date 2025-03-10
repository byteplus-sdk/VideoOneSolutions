// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ModernFilterPickerView.h"
#import <Masonry/Masonry.h>
#import "EffectItem.h"
#import "RectangleSelectableView.h"


@interface ModernFilterPickerView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSArray <EffectItem *> *filters;
@property (nonatomic, copy) NSArray <EffectItem *> *lipsticks;
@property (nonatomic, weak) NSIndexPath* currentSelectedCellIndexPath;
@end

@implementation ModernFilterPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo((97));
            make.leading.trailing.equalTo(self);
            make.centerY.mas_equalTo(self);
        }];
    }
    return self;
}

#pragma mark - public
- (void)refreshWithFilters:(NSArray<EffectItem *> *)filters {
    self.filters = filters;
    [self.collectionView reloadData];
    NSInteger  index = 0;
    for (int i = 0; i<filters.count; i++) {
        EffectItem *item = filters[i];
        if (item.selected) {
            index = i;
        }
    }
    _currentSelectedCellIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    });
   
}

- (void)setAllCellsUnSelected{
    if (_currentSelectedCellIndexPath){
        [self.collectionView deselectItemAtIndexPath:_currentSelectedCellIndexPath animated:false];
    }
    _currentSelectedCellIndexPath = nil;
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)setSelectItem:(NSString *)filterPath {
    NSInteger index = 0;
    if (filterPath == nil || [filterPath isEqualToString:@""]) {
        index = 0;
    } else {
        for (int i = 0; i < self.filters.count; i++) {
            if ([filterPath isEqualToString:self.filters[i].resourcePath]) {
                index = i;
                break;
            }
        }
    }
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EffectItem *filter = self.filters[indexPath.row];
    SelectableCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectableCell" forIndexPath:indexPath];
    [cell setSelectableConfig:[RectangleSelectableConfig
                               initWithImageName:filter.selectImg imageSize:CGSizeMake((66), (66))]];
    cell.useCellSelectedState = YES;
    cell.selectableButton.title = filter.title;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (_currentSelectedCellIndexPath==indexPath) {
        return;
    }
    _currentSelectedCellIndexPath = indexPath;
    if ([self.delegate respondsToSelector:@selector(filterPicker:didSelectFilter:)]) {
        [self.delegate filterPicker:self didSelectFilter:self.filters[_currentSelectedCellIndexPath.row]];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((66), (97));
}


#pragma mark - getter && setter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = (14);
        flowLayout.minimumInteritemSpacing = 20;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, (13), 0, (13));
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[SelectableCell class] forCellWithReuseIdentifier:@"SelectableCell"];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}


@end
