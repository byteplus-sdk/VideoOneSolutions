// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaTrendingCell.h"
#import "MiniDramaTrendingSubCell.h"

static NSString *MiniDramaTrendingCellReuseID = @"MiniDramaTrendingCellReuseID";

@interface MiniDramaTrendingCell ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<MDDramaInfoModel *> *datas;

@end

@implementation MiniDramaTrendingCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

-(void)initViews {
    UIGraphicsBeginImageContext(self.bounds.size);
    [[UIImage imageNamed:@"mini_drama_trending_cell_bg"] drawInRect:self.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundColor = [UIColor colorWithPatternImage:image];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat width = (self.bounds.size.width - 32) * 0.5;
    layout.itemSize = CGSizeMake(width, self.bounds.size.height - 16);
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
    
    [self.collectionView registerClass:[MiniDramaTrendingSubCell class] forCellWithReuseIdentifier:MiniDramaTrendingCellReuseID];
    
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).mas_offset(16);
        make.right.equalTo(self).mas_offset(-16);
        make.bottom.equalTo(self).mas_offset(-16);
    }];
}

- (void)setMiniDramaDatas:(NSArray<MDDramaInfoModel *> *)miniDramaDatas {
    self.datas = [NSArray arrayWithArray:miniDramaDatas];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.datas.count/3 + (self.datas.count%3 == 0 ? 0 : 1);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MiniDramaTrendingSubCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MiniDramaTrendingCellReuseID forIndexPath:indexPath];
    NSInteger startIndex = 3 * indexPath.section;
    NSInteger endIndex = startIndex + 2 < self.datas.count ? startIndex + 2 : self.datas.count - 1;
    [cell setMiniDramaData:self.datas startIndex:startIndex endIndex:endIndex];
    cell.selectDelegate = self.selectDelegate;
    return cell;
}
@end
