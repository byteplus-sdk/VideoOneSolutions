// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaNewCell.h"
#import "MiniDramaNewSubCell.h"

static NSString *MiniDramaNewSubCellReuseID = @"MiniDramaNewSubCellReuseID";

@interface MiniDramaNewCell ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<MDDramaInfoModel *> *datas;

@end

@implementation MiniDramaNewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

-(void)initViews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, self.bounds.size.height);
    layout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 0);
    layout.minimumInteritemSpacing = 16;
    layout.minimumLineSpacing = 16;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;

    [self.collectionView registerClass:[MiniDramaNewSubCell class] forCellWithReuseIdentifier:MiniDramaNewSubCellReuseID];

    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self);
    }];
}

- (void)setMiniDramaDatas:(NSArray<MDDramaInfoModel *> *)miniDramaDatas {
    self.datas = [NSArray arrayWithArray:miniDramaDatas];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.datas.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MiniDramaNewSubCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MiniDramaNewSubCellReuseID forIndexPath:indexPath];
    cell.dramaInfoModel = self.datas[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.selectDelegate didMiniDramaSelectItem:self.datas[indexPath.row]];
}

@end
