// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEShortVideoViewController.h"
#import "UIScrollView+Refresh.h"
#import "VEDataManager.h"
#import "VEPageViewController.h"
#import "VEPlayerKit.h"
#import "VESettingManager.h"
#import "VEShortVideoCellController.h"
#import "VEVideoModel.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>

static NSInteger VEShortVideoLoadMoreDetection = 2;

static NSString *VEShortVideoCellReuseID = @"VEShortVideoCellReuseID";

static NSInteger VEShortVideoPreloadVideoCount = 3;

@interface VEShortVideoViewController () <VEPageDataSource, VEPageDelegate, VEShortVideoCellControllerDelegate>

@property (nonatomic, strong) VEPageViewController *pageContainer;

@property (nonatomic, strong) BaseButton *backButton;

@property (nonatomic, strong) VEDataManager *dataManager;

@property (nonatomic, assign) BOOL preloadOpen;

@end

@implementation VEShortVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
    [self startVideoStategy];
    [self refreshData];
}

- (void)tabViewDidAppear {
    [super tabViewDidAppear];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.pageContainer.viewAppeared = YES;
    [self.pageContainer beginAppearanceTransition:YES animated:NO];
    [self.pageContainer endAppearanceTransition];
}

- (void)tabViewDidDisappear {
    [super tabViewDidDisappear];
    self.pageContainer.viewAppeared = NO;
    [self.pageContainer beginAppearanceTransition:NO animated:NO];
    [self.pageContainer endAppearanceTransition];
}

- (void)dealloc {
    [VEVideoPlayerController clearAllEngineStrategy];
    [VEVideoPlayerController cancelPreloadVideoSources];
}

#pragma mark---- ATPageViewControllerDataSource & Delegate
- (NSInteger)numberOfItemInPageViewController:(VEPageViewController *)pageViewController {
    return self.videoModels.count;
}

// designed like the cellForRow Method of UITableView, you should return the cell corresponding to the exact index
- (__kindof UIViewController<VEPageItem> *)pageViewController:(VEPageViewController *)pageViewController pageForItemAtIndex:(NSUInteger)index {
    VEShortVideoCellController *cell = [pageViewController dequeueItemForReuseIdentifier:VEShortVideoCellReuseID];
    if (!cell) {
        cell = [VEShortVideoCellController new];
        cell.reuseIdentifier = VEShortVideoCellReuseID;
    }
    cell.delegate = self;
    cell.videoModel = [self.videoModels objectAtIndex:index];
    return cell;
}

- (BOOL)shouldScrollVertically:(VEPageViewController *)pageViewController {
    return YES;
}

- (void)pageViewController:(VEPageViewController *)pageViewController
    didScrollChangeDirection:(VEPageItemMoveDirection)direction
              offsetProgress:(CGFloat)progress {
    if (((self.videoModels.count - 1) - self.pageContainer.currentIndex <= VEShortVideoLoadMoreDetection) && direction == VEPageItemMoveDirectionNext) {
        if (!self.pageContainer.scrollView.veLoading && !self.dataManager.isNoMoreData) {
            [self loadMoreData];
        }
    }
}

- (void)pageViewControllerWillBeginDragging:(VEPageViewController *)pageViewController {
    [VEVideoPlayerController cancelPreloadVideoSources];
}

- (void)pageViewController:(VEPageViewController *)pageViewController didDisplayItem:(id<VEPageItem>)viewController atIndex:(NSUInteger)index {
    if (!self.preloadOpen || !self.videoModels.count || index == self.videoModels.count - 1) {
        return;
    }
    NSUInteger loc = index + 1;
    NSUInteger len = MIN(VEShortVideoPreloadVideoCount, self.videoModels.count - loc);
    [[self.videoModels subarrayWithRange:NSMakeRange(loc, len)] enumerateObjectsUsingBlock:^(VEVideoModel *obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [VEVideoPlayerController preloadVideoSource:[VEVideoModel videoEngineVidSource:obj]];
    }];
}

#pragma mark----- Lazy load

- (VEPageViewController *)pageContainer {
    if (!_pageContainer) {
        _pageContainer = [VEPageViewController new];
        _pageContainer.dataSource = self;
        _pageContainer.delegate = self;
        _pageContainer.scrollView.directionalLockEnabled = YES;
        _pageContainer.scrollView.scrollsToTop = NO;
    }
    return _pageContainer;
}

- (BaseButton *)backButton {
    if (!_backButton) {
        _backButton = [BaseButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"nav_left"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (VEDataManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [[VEDataManager alloc] initWithScene:VESceneTypeShortVideo];
    }
    return _dataManager;
}

- (NSMutableArray *)videoModels {
    return self.dataManager.videoModels;
}

#pragma mark----- Data
- (void)refreshData {
    [self.pageContainer.scrollView beginRefresh];
    self.pageContainer.scrollView.scrollEnabled = NO;
    __weak typeof(self) weakSelf = self;
    [self.dataManager refreshData:^{
        weakSelf.pageContainer.scrollView.scrollEnabled = YES;
        [weakSelf.pageContainer reloadData];
        [weakSelf.pageContainer.scrollView endRefresh];
    } failure:^(NSString *_Nonnull errorMessage) {
        weakSelf.pageContainer.scrollView.scrollEnabled = YES;
        [weakSelf.pageContainer.scrollView endRefresh];
    }];
}

- (void)loadMoreData {
    self.pageContainer.scrollView.veLoading = YES;
    __weak typeof(self) weakSelf = self;
    [self.dataManager looadMoreData:^{
        [weakSelf.pageContainer reloadContentSize];
        weakSelf.pageContainer.scrollView.veLoading = NO;
    } failure:^(NSString *_Nonnull errorMessage) {
        weakSelf.pageContainer.scrollView.veLoading = NO;
    }];
}

- (void)startVideoStategy {
    VESettingModel *preRender = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreRenderStrategy];
    if (preRender.open) {
        [VEVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreRender scene:TTVEngineStrategySceneSmallVideo];
    }
    VESettingModel *preload = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreloadStrategy];
    if (preload.open) {
        [VEVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreload scene:TTVEngineStrategySceneSmallVideo];
    }
    self.preloadOpen = preload.open;
}

#pragma mark----- UI
- (void)initialUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self addChildViewController:self.pageContainer];
    [self.view addSubview:self.pageContainer.view];
    [self.pageContainer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.view addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo([DeviceInforTool getStatusBarHight] + 14);
        make.left.mas_equalTo(15);
        make.size.equalTo(@(CGSizeMake(16, 16)));
    }];
    __weak typeof(self) weakSelf = self;
    [self.pageContainer.scrollView systemRefresh:^{
        [weakSelf refreshData];
    }];
}

#pragma mark----- VEShortVideoCellControllerDelegate

- (void)shortVideoController:(VEShortVideoCellController *)controller shouldLockVerticalScroll:(BOOL)shouldLock {
    self.pageContainer.scrollView.scrollEnabled = !shouldLock;
}

@end
