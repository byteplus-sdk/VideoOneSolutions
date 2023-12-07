// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELongVideoViewController.h"
#import "BaseButton.h"
#import "DeviceInforTool.h"
#import "Localizator.h"
#import "NetworkingManager+Vod.h"
#import "ToolKit.h"
#import "UIScrollView+Refresh.h"
#import "VELongVideoViewLayout.h"
#import "VELongVideoViewNormalCell.h"
#import "VELongVideoViewTopCell.h"
#import "VEVideoDetailViewController.h"
#import "VEVideoModel.h"
#import <MJRefresh/MJRefresh.h>
#import <Masonry/Masonry.h>

static NSString *VELongVideoTopCellReuseID = @"VELongVideoTopCellReuseID";

static NSString *VELongVideoNormalCellReuseID = @"VELongVideoNormalCellReuseID";

static NSString *VELongVideoHeaderViewReuseID = @"VELongVideoHeaderViewReuseID";

static NSString *VELongVideoHeaderEmptyViewReuseID = @"VELongVideoHeaderEmptyViewReuseID";

static NSString *VELongSectionTopHeaderKey = @"置顶";

static NSString *VELongSectionHotHeaderKey = @"热播剧场";

static NSString *VELongSectionRecommendTodayHeaderKey = @"今日推荐";

static NSString *VELongSectionRecommendForUHeaderKey = @"为你推荐";

@interface VELongVideoViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableDictionary *videoModelDic;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation VELongVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
    [self loadDataWithMore:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)tabViewDidAppear {
    [super tabViewDidAppear];
}

#pragma mark----- Base

- (void)initialUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    if (@available(iOS 11.0, *)) {
        self.collectionView.insetsLayoutMarginsFromSafeArea = NO;
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    NSBundle *currentBundle = [NSBundle bundleForClass:NSClassFromString(@"VELongVideoViewTopCell")];
    [self.collectionView registerNib:[UINib nibWithNibName:@"VELongVideoViewTopCell" bundle:currentBundle] forCellWithReuseIdentifier:VELongVideoTopCellReuseID];
    NSBundle *currentBundle2 = [NSBundle bundleForClass:NSClassFromString(@"VELongVideoViewNormalCell")];
    [self.collectionView registerNib:[UINib nibWithNibName:@"VELongVideoViewNormalCell" bundle:currentBundle2] forCellWithReuseIdentifier:VELongVideoNormalCellReuseID];
    [self.collectionView registerClass:[VELongVideoHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:VELongVideoHeaderViewReuseID];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:VELongVideoHeaderEmptyViewReuseID];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    WeakSelf;
    [self.collectionView systemRefresh:^{
        StrongSelf;
        [sself loadDataWithMore:NO];
    }];
    self.title = @"长视频";
    BaseButton *button = [[BaseButton alloc] init];
    button.backgroundColor = [UIColor clearColor];
    UIImage *image = [UIImage imageNamed:@"nav_left"];
    button.tintColor = [UIColor whiteColor];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(16, 16));
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(44 + [DeviceInforTool getStatusBarHight] - 30);
    }];

    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        StrongSelf;
        [sself loadDataWithMore:YES];
    }];
}

- (void)close {
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark----- UICollectionView Delegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self sectionKeys] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *sectionKeys = [self sectionKeys];
    NSString *sectionKey = [sectionKeys objectAtIndex:section];
    NSArray *sectionItems = [self.videoModelDic objectForKey:sectionKey];
    return sectionItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionKeys = [self sectionKeys];
    NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
    NSArray *sectionItems = [self.videoModelDic objectForKey:sectionKey];
    VEVideoModel *videoModel = [sectionItems objectAtIndex:indexPath.row];
    if (indexPath.section) {
        VELongVideoViewNormalCell *normalCell = [collectionView dequeueReusableCellWithReuseIdentifier:VELongVideoNormalCellReuseID forIndexPath:indexPath];
        normalCell.videoModel = videoModel;
        return normalCell;
    } else {
        VELongVideoViewTopCell *topCell = [collectionView dequeueReusableCellWithReuseIdentifier:VELongVideoTopCellReuseID forIndexPath:indexPath];
        topCell.videoModel = videoModel;
        return topCell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader && indexPath.section) {
        VELongVideoHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:VELongVideoHeaderViewReuseID forIndexPath:indexPath];
        NSDictionary *map = [self sectionKeyLanguageMap];
        NSString *key = [[self sectionKeys] objectAtIndex:indexPath.section];
        header.title = [map objectForKey:key];
        return header;
    } else {
        return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:VELongVideoHeaderEmptyViewReuseID forIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionKeys = [self sectionKeys];
    NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
    NSArray *sectionItems = [self.videoModelDic objectForKey:sectionKey];
    VEVideoModel *videoModel = [sectionItems objectAtIndex:indexPath.row];
    VEVideoDetailViewController *detailViewController = [[VEVideoDetailViewController alloc] initWithType:VEVideoPlayerTypeLong];
    detailViewController.videoModel = videoModel;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark----- lazy load

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[VELongVideoViewLayout new]];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

- (NSMutableDictionary *)videoModelDic {
    if (!_videoModelDic) {
        _videoModelDic = [NSMutableDictionary dictionary];
    }
    return _videoModelDic;
}

#pragma mark----- Data

- (void)loadDataWithMore:(BOOL)more {
    NSArray *allValues = self.videoModelDic.allValues;
    NSInteger currentCount = 0;
    for (id obj in allValues) {
        if ([obj isKindOfClass:[NSArray class]]) {
            currentCount += [(NSArray *)obj count];
        }
    }
    NSInteger fetchCount = 10;
    [NetworkingManager dataForScene:VESceneTypeLongVideo
                              range:NSMakeRange(more ? currentCount : 0, fetchCount)
                            success:^(NSArray<VEVideoModel *> *_Nonnull videoModels) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (more) {
                                        if (videoModels.count) {
                                            NSMutableArray *array = [NSMutableArray array];
                                            NSArray *ary = [self.videoModelDic valueForKey:VELongSectionRecommendForUHeaderKey];
                                            if (ary.count) {
                                                [array addObjectsFromArray:ary];
                                            }
                                            [array addObjectsFromArray:videoModels];
                                            [self.videoModelDic setObject:array.mutableCopy forKey:VELongSectionRecommendForUHeaderKey];
                                        }
                                        if (videoModels.count == fetchCount) {
                                            [self.collectionView.mj_footer endRefreshing];
                                        } else {
                                            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                                        }

                                    } else {
                                        [self.collectionView endRefresh];
                                        [self.collectionView.mj_footer resetNoMoreData];
                                        [self.videoModelDic removeAllObjects];
                                        [self _fakeSection:videoModels];
                                    }

                                    [self.collectionView reloadData];
                                });
                            }
                            failure:nil];
}

- (void)_fakeSection:(NSArray *)originalArray {
    if (originalArray.count == 0) {
        return;
    }
    [self.videoModelDic setValue:[originalArray subarrayWithRange:NSMakeRange(0, 1)] forKey:VELongSectionTopHeaderKey];
    if (originalArray.count >= 4) {
        NSArray *arr2 = [originalArray subarrayWithRange:NSMakeRange(1, 4)];
        [self.videoModelDic setValue:arr2 forKey:VELongSectionHotHeaderKey];
    }
    if (originalArray.count > 9) {
        [self.videoModelDic setValue:[originalArray subarrayWithRange:NSMakeRange(5, 4)] forKey:VELongSectionRecommendTodayHeaderKey];
        [self.videoModelDic setValue:[originalArray subarrayWithRange:NSMakeRange(9, (originalArray.count - 9))] forKey:VELongSectionRecommendForUHeaderKey];
    }
}

- (NSArray *)sectionKeys {
    @autoreleasepool {
        return @[VELongSectionTopHeaderKey, VELongSectionHotHeaderKey, VELongSectionRecommendTodayHeaderKey, VELongSectionRecommendForUHeaderKey];
    }
}

- (NSDictionary *)sectionKeyLanguageMap {
    return @{
        VELongSectionTopHeaderKey: LocalizedStringFromBundle(@"longvideo_top", @"VEVodApp"),
        VELongSectionHotHeaderKey: LocalizedStringFromBundle(@"longvideo_playlist", @"VEVodApp"),
        VELongSectionRecommendTodayHeaderKey: LocalizedStringFromBundle(@"longvideo_recommended", @"VEVodApp"),
        VELongSectionRecommendForUHeaderKey: LocalizedStringFromBundle(@"longvideo_recommended_foru", @"VEVodApp"),
    };
}

@end
