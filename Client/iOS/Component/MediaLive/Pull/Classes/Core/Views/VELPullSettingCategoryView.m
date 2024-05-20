// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullSettingCategoryView.h"
#import <Masonry/Masonry.h>
#import "VELPullSettingContainerCell.h"
@interface VELPullSettingCategoryView () <VELSwitchTabViewDelegate>
@property (nonatomic, strong) VELCategoryView *categoryView;
@property (nonatomic, strong) UICollectionView *contentView;
@property (nonatomic, strong) UIVisualEffectView *bgView;
@property (nonatomic, strong) NSArray <NSString *> *categoryTitles;
@end
@implementation VELPullSettingCategoryView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.bgView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:(UIBlurEffectStyleDark)]];
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.layer.cornerRadius = 16;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setSettingViewModels:(NSArray<VELPullSettingViewModel *> *)settingViewModels {
    if (_settingViewModels != settingViewModels) {
        _settingViewModels = settingViewModels;
        _categoryTitles = nil;
        [settingViewModels enumerateObjectsUsingBlock:^(VELPullSettingViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.contentView registerClass:VELPullSettingContainerCell.class forCellWithReuseIdentifier:obj.cellIdentifier];
        }];
        [self.contentView reloadData];
        [self.categoryView.switchTabView refreshWithTitles:self.categoryTitles];
        [self.categoryView.switchTabView selectItemAtIndex:0 animated:NO];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.settingViewModels.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VELPullSettingViewModel *viewModel = [self.settingViewModels objectAtIndex:indexPath.item];
    VELPullSettingContainerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:viewModel.cellIdentifier forIndexPath:indexPath];
    [cell setViewModel:viewModel];
    return cell;
}

- (void)switchTabDidSelectedAtIndex:(NSInteger)index {
    [self.contentView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                             atScrollPosition:(UICollectionViewScrollPositionNone) animated:YES];
}

- (VELCategoryView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[VELCategoryView alloc] init];
        _categoryView.tabDelegate = self;
        _categoryView.contentView = self.contentView;
        _categoryView.tabInset = UIEdgeInsetsMake(0, 10, 0, 10);
        _categoryView.tabHeight = 40;
        _categoryView.switchTabView.itemMargin = 20;
        _categoryView.tabDelegate = self;
        VELSwitchTabView *tabView = [_categoryView switchTabView];
        [tabView refreshWithTitles:[self categoryTitles]];
        tabView.normalTextColor = [UIColor whiteColor];
        tabView.hightlightTextColor = VELColorWithHexString(@"#5980FF");
        VELSwitchIndicatorLineStyle *lineStyle = [[VELSwitchIndicatorLineStyle alloc] init];
        lineStyle.backgroundColor = VELColorWithHexString(@"#5980FF");
        lineStyle.widthRatio = 1;
        lineStyle.height = 2;
        lineStyle.bottomMargin = 1;
        tabView.indicatorLineStyle = lineStyle;
        [tabView selectItemAtIndex:0 animated:NO];
    }
    return _categoryView;
}

- (UICollectionView *)contentView {
    if (!_contentView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _contentView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _contentView.dataSource = self;
        _contentView.pagingEnabled = YES;
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}
- (NSArray<NSString *> *)categoryTitles {
    if (!_categoryTitles || _categoryTitles.count == 0) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.settingViewModels.count];
        [self.settingViewModels enumerateObjectsUsingBlock:^(VELPullSettingViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:obj.title?:@""];
        }];
        _categoryTitles = array.copy;
    }
    return _categoryTitles;
}
- (NSDictionary<NSString *,Class> *)cellClassMap {
    return @{};
}
@end
