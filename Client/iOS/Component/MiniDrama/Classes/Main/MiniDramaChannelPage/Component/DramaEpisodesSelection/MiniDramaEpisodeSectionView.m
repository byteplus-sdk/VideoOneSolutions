// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaEpisodeSectionView.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIColor+String.h>
#import <ToolKit/ToolKit.h>
#import "BTDMacros.h"

static NSString *MiniDramaEpisodeSectionViewCellReuseID = @"MiniDramaEpisodeSectionViewCellReuseID";

@interface MiniDramaEpisodeSectionViewCell ()

@property (nonatomic, strong) UILabel *title;

@end

@implementation MiniDramaEpisodeSectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configuratoinCustomView];
    }
    return self;
}

- (void)configuratoinCustomView {
    [self.contentView addSubview:self.title];
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
    }];
}

- (void)setCellName:(NSString *)cellName {
    self.title.text = cellName;
}

- (void)setIsActive:(BOOL)isActive {
    if (isActive) {
        self.title.textColor = [UIColor whiteColor];
    } else {
        self.title.textColor = [UIColor colorFromHexString:@"#76797E"];
    }
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = [UIColor colorFromHexString:@"#76797E"];
        _title.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    }
    return _title;
}

@end

@interface MiniDramaEpisodeSectionView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *sectionTabCollection;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSInteger segmentCount;

@end

@implementation MiniDramaEpisodeSectionView

- (instancetype)initWith:(NSInteger)totalCount segmentCount:(NSInteger)segmentCount {
    self = [super init];
    if (self) {
        _totalCount = totalCount;
        _segmentCount = segmentCount;
        _currentTabOrder = -1;
        [self configuratoinCustomView];
    }
    return self;
}


- (void)configuratoinCustomView {
    [self addSubview:self.sectionTabCollection];
    [self.sectionTabCollection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setCurrentTabOrder:(NSInteger)currentTabOrder {
    if (currentTabOrder == self.currentTabOrder) {
        return;
    }
    _currentTabOrder = currentTabOrder;
    [self.sectionTabCollection reloadData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectTab:segmentCount:)]) {
        [self.delegate onSelectTab:currentTabOrder segmentCount:self.segmentCount];
    }
    __weak __typeof(self) weak_self = self;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        [weak_self.sectionTabCollection
         scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentTabOrder inSection:0]
         atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    });
}

- (NSString *)getCellName:(NSIndexPath *)indexPath {
    NSInteger startNumber =  indexPath.row * self.segmentCount + 1;
    NSInteger endNumber = MIN(startNumber + self.segmentCount - 1, self.totalCount);
    return [NSString stringWithFormat:@"%ld-%ld", startNumber, endNumber];
}

#pragma mark ----- UICollectionView Delegate & DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   NSInteger res =  self.totalCount % self.segmentCount;
    if (res == 0) {
        return self.totalCount / self.segmentCount;
    } else if (res == self.totalCount) {
        return 1;
    } else {
        return self.totalCount / self.segmentCount + 1;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MiniDramaEpisodeSectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MiniDramaEpisodeSectionViewCellReuseID forIndexPath:indexPath];
    cell.cellName  = [self getCellName:indexPath];
    cell.isActive = self.currentTabOrder == indexPath.row;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.currentTabOrder = indexPath.row;
}


- (UICollectionView *)sectionTabCollection {
    if (!_sectionTabCollection) {
        UICollectionViewFlowLayout *collectionViewlayout = [UICollectionViewFlowLayout new];
        collectionViewlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        collectionViewlayout.itemSize = CGSizeMake(71, 46);
        collectionViewlayout.sectionInset = UIEdgeInsetsZero;
        _sectionTabCollection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewlayout];
        _sectionTabCollection.dataSource = self;
        _sectionTabCollection.delegate = self;
        _sectionTabCollection.backgroundColor = [UIColor clearColor];
        [_sectionTabCollection registerClass:[MiniDramaEpisodeSectionViewCell class] forCellWithReuseIdentifier:MiniDramaEpisodeSectionViewCellReuseID];
    }
    return _sectionTabCollection;
}

@end
