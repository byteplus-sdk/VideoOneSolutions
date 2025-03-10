// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaListViewController.h"
#import "MiniDramaVideoViewNormalCell.h"
#import "MDDramaInfoModel.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import <ToolKit/UIColor+String.h>
#import "MiniDramaCarouselView.h"
#import <NetworkingManager+MiniDrama.h>
#import <ToolKit/ToolKit.h>
#import "MinidramaHeaderCell.h"
#import "MiniDramaTrendingCell.h"
#import "MiniDramaNewCell.h"
#import "MiniDramaDetailFeedViewController.h"
#import "MiniDramaLandscapeViewController.h"

static NSString *MiniDramaCarouselCellReuseID = @"MiniDramaCarouselCellReuseID";
static NSString *MiniDramaTrendingCellReuseID = @"MiniDramaTrendingCellReuseID";
static NSString *MiniDramaNewCellReuseID = @"MiniDramaNewCellReuseID";
static NSString *MiniDramaVideoNormalCellReuseID = @"MiniDramaVideoNormalCellReuseID";
static NSString *MiniDramaVideoHeaderViewReuseID = @"MiniDramaVideoHeaderViewReuseID";
static NSString *MiniDramaVideoHFooterViewReuseID = @"MiniDramaVideoFooterViewReuseID";

@interface MiniDramaListViewController () <UICollectionViewDelegate, 
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIScrollViewDelegate,
MiniDramaItemSelectDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL isLoadingData;

@property (nonatomic, assign)CGSize carouselCellSize;
@property (nonatomic, assign)CGSize trendingCellSize;
@property (nonatomic, assign)CGSize newCellSize;
@property (nonatomic, assign)CGSize normalCellSize;
@property (nonatomic, assign)CGSize headerSize;
@property (nonatomic, weak)MiniDramaCarouselView *carouselView;

@property (nonatomic, strong) MDHomePageData* channelData;

@end

@implementation MiniDramaListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self loadData];
}

- (void)initViews {
    self.view.backgroundColor = [UIColor colorFromHexString:@"#161823"];
    self.carouselCellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 363);
    self.trendingCellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 310);
    self.newCellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 181);
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 42) / 2.0;
    CGFloat height = width * 284 / 167.0f;
    self.normalCellSize = CGSizeMake(width, height);
    self.headerSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 84);
    
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[MiniDramaCarouselView class] forCellWithReuseIdentifier:MiniDramaCarouselCellReuseID];
    [self.collectionView registerClass:[MiniDramaTrendingCell class] forCellWithReuseIdentifier:MiniDramaTrendingCellReuseID];
    [self.collectionView registerClass:[MiniDramaNewCell class] forCellWithReuseIdentifier:MiniDramaNewCellReuseID];
    [self.collectionView registerClass:[MiniDramaVideoViewNormalCell class] forCellWithReuseIdentifier:MiniDramaVideoNormalCellReuseID];
    [self.collectionView registerClass:[MiniDramaHeaderCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MiniDramaVideoHeaderViewReuseID];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:MiniDramaVideoHFooterViewReuseID];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(44);
        } else {
            make.top.equalTo(self.view).offset(64);
        }
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    __weak typeof(self) weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf loadData];
    }];
    self.collectionView.mj_footer.hidden = YES;
}

- (void)loadData {
    if (self.isLoadingData) {
        return;
    }
    self.isLoadingData = YES;
    self.collectionView.mj_footer.hidden = NO;

    [NetworkingManager getDramaDataForHomePageData:^(MDHomePageData * _Nonnull pageData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView.mj_header endRefreshing];
            self.channelData = pageData;
            [self.collectionView reloadData];
            self.isLoadingData = NO;
        });
    } failure:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ToastComponent shareToastComponent] showWithMessage:message];
            self.isLoadingData = NO;
        });
    }];
}

- (void)setViewisVisible:(BOOL)viewisVisible {
    _viewisVisible = viewisVisible;
    if (self.carouselView) {
        self.carouselView.viewisVisible = viewisVisible;
    }
}

#pragma mark --UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        NSIndexPath *specificIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        BOOL isVisible = [self isCellVisibleForIndexPath:specificIndexPath];
        if (self.carouselView) {
            self.carouselView.viewisVisible = isVisible;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *specificIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    BOOL isVisible = [self isCellVisibleForIndexPath:specificIndexPath];
    if (self.carouselView) {
        self.carouselView.viewisVisible = isVisible;
    }
}

- (BOOL)isCellVisibleForIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect itemFrameInCollectionView = attributes.frame;
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    return CGRectIntersectsRect(itemFrameInCollectionView, visibleRect);
}

#pragma mark ----- UICollectionView Delegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.channelData sections].count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *sections = [self.channelData sections];
    switch ([sections[section] integerValue]) {
        case MDDramaSectionTypeLoop:
        case MDDramaSectionTypeTrending:
        case MDDramaSectionTypeNew:
            return 1;
        default:
            return [self.channelData getDramaInfo:[sections[section] integerValue]].count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sections = [self.channelData sections];
    NSInteger sectionType = [sections[indexPath.section] integerValue];
    NSArray<MDDramaInfoModel *> *infos = [self.channelData getDramaInfo:sectionType];
    switch (sectionType) {
        case MDDramaSectionTypeLoop:{
            MiniDramaCarouselView *carouselView = [collectionView dequeueReusableCellWithReuseIdentifier:MiniDramaCarouselCellReuseID forIndexPath:indexPath];
            carouselView.miniDramaDatas = infos;
            carouselView.selectDelegate = self;
            self.carouselView = carouselView;
            return carouselView;
        }
        case MDDramaSectionTypeTrending:{
            MiniDramaTrendingCell *trendingCell = [collectionView dequeueReusableCellWithReuseIdentifier:MiniDramaTrendingCellReuseID forIndexPath:indexPath];
            trendingCell.miniDramaDatas = infos;
            trendingCell.selectDelegate = self;
            return trendingCell;
        }
        case MDDramaSectionTypeNew:{
            MiniDramaNewCell *newCell = [collectionView dequeueReusableCellWithReuseIdentifier:MiniDramaNewCellReuseID forIndexPath:indexPath];
            newCell.miniDramaDatas = infos;
            newCell.selectDelegate = self;
            return newCell;
        }
            
        default:{
            MiniDramaVideoViewNormalCell *normalCell = [collectionView dequeueReusableCellWithReuseIdentifier:MiniDramaVideoNormalCellReuseID forIndexPath:indexPath];
            normalCell.dramaInfoModel = infos[indexPath.row];
            return normalCell;
        }
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        NSArray *sections = [self.channelData sections];
        NSInteger sectionType = [sections[indexPath.section] integerValue];
        MiniDramaHeaderCell *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MiniDramaVideoHeaderViewReuseID forIndexPath:indexPath];
        [header setText:[self sectionHeaderText:sectionType]  icon:nil];
        return header;
    } else {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MiniDramaVideoHFooterViewReuseID forIndexPath:indexPath];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeZero;
    }
    return self.headerSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sections = [self.channelData sections];
    MDDramaInfoModel *model = [self.channelData getDramaInfo:[sections[indexPath.section] integerValue]][indexPath.row];
    [self didMiniDramaSelectItem:model];
}

#pragma mark - MiniDramaItemSelectDelegate
- (void)didMiniDramaSelectItem:(MDDramaInfoModel *)dramaInfoModel{
    if (dramaInfoModel.dramaDisplayType == MiniDramaVideoDisplayTypeVertical) {
        MiniDramaDetailFeedViewController *vc = [[MiniDramaDetailFeedViewController alloc] initWithDramaInfo:dramaInfoModel];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        MiniDramaLandscapeViewController *vc = [[MiniDramaLandscapeViewController alloc] initWithDramaInfo:dramaInfoModel];
        vc.landscapeMode = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sections = [self.channelData sections];
    switch ([sections[indexPath.section] integerValue]) {
        case MDDramaSectionTypeLoop:
            return self.carouselCellSize;
        case MDDramaSectionTypeTrending:
            return self.trendingCellSize;
        case MDDramaSectionTypeNew:
            return self.newCellSize;
        default:
            return self.normalCellSize;
    }
}


#pragma mark ----- lazy load

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *viewFlowLayout = [UICollectionViewFlowLayout new];
        
        viewFlowLayout.itemSize = self.normalCellSize;
        viewFlowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        viewFlowLayout.minimumLineSpacing = 16.0;
        viewFlowLayout.minimumInteritemSpacing = 8.0;
        viewFlowLayout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 10);
        viewFlowLayout.footerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 10);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:viewFlowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

-(NSString *)sectionHeaderText:(NSInteger)type {
    switch (type) {
        case MDDramaSectionTypeLoop:
            return @"";
        case MDDramaSectionTypeTrending:
            return LocalizedStringFromBundle(@"mini_drama_trending", @"MiniDrama");
        case MDDramaSectionTypeNew:
            return LocalizedStringFromBundle(@"mini_drama_new_release", @"MiniDrama");
        case MDDramaSectionTypeRecommend:
            return LocalizedStringFromBundle(@"mini_drama_recommended", @"MiniDrama");
        default:
            return @"";
    }
}

@end
