//
//  MixFeedViewController.m
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/5.
//

#import "MixFeedViewController.h"
#import "TTPageViewController.h"
#import "TTDataManager.h"
#import "TTViewController.h"
#import "UIScrollView+Refresh.h"
#import "VEPlayerKit.h"
#import "TTMixModel.h"
#import "UIImage+Bundle.h"
#import "TTVideoCellController.h"
#import "TTLiveCellController.h"
#import <ToolKit/ToolKit.h>
#import <Masonry/Masonry.h>

static NSInteger TTMixFeedDetection = 2;

static NSInteger TTPreloadVideoCount = 3;

static NSString *TTVideoCellReuseID = @"TTVideoCellReuseID";

static NSString *TTLiveCellReuseID = @"TTLiveCellReuseID";

@interface MixFeedViewController () <TTPageDataSource, TTPageDelegate, TTVideoCellControllerDelegate, TTVideoEnginePreRenderDelegate>

@property (nonatomic, strong) TTPageViewController *pageContainer;

@property (nonatomic, strong) BaseButton *backButton;

@property (nonatomic, strong) TTDataManager *dataManager;

@property (nonatomic, strong) NSArray <TTMixModel *> *mixModels;

@property (nonatomic, strong) NSArray *videoSources;

@property (nonatomic, assign) BOOL isFirstLoad;

@end

@implementation MixFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
    [self startVideoStrategy];
    self.isFirstLoad = YES;
    [self refreshData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    [VEVideoPlayerController clearAllEngineStrategy];
    [VEVideoPlayerController cancelPreloadVideoSources];
    [VEVideoPlayerController cleanCache];
    [[TTLivePlayerManager sharedLiveManager] cleanCache];
}

#pragma mark ----- Private Method

- (void)initialUI {
    self.view.backgroundColor = [UIColor blackColor];
    [self addChildViewController:self.pageContainer];
    [self.view addSubview:self.pageContainer.view];
    [self.pageContainer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.view addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(14);
        make.left.mas_equalTo(15);
        make.size.equalTo(@(CGSizeMake(16, 16)));
    }];
    __weak typeof(self) weakSelf = self;
    [self.pageContainer.scrollView systemRefresh:^{
        [weakSelf refreshData];
    }];
}

- (void)startVideoStrategy {
    [VEVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreload scene:TTVEngineStrategySceneSmallVideo];
    [VEVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreRender scene:TTVEngineStrategySceneSmallVideo];
    [TTVideoEngine setPreRenderVideoEngineDelegate:self];
}

- (void)refreshData {
    [self.pageContainer.scrollView beginRefresh];
    self.pageContainer.scrollView.scrollEnabled = NO;
    __weak typeof(self) weakSelf = self;
    if (self.isFirstLoad) {
        [[ToastComponent shareToastComponent] showLoading];
        self.isFirstLoad = NO;
    }
    [self.dataManager refreshData:^{
        [[ToastComponent shareToastComponent] dismiss];
        weakSelf.pageContainer.scrollView.scrollEnabled = YES;
        [weakSelf.pageContainer  reloadData];
        [weakSelf.pageContainer.scrollView endRefresh];
    } failure:^(NSString * _Nonnull errorMessage) {
        [[ToastComponent shareToastComponent] dismiss];
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

#pragma mark---- TTPageDataSource & TTPageDelegate
- (BOOL)shouldScrollVertically:(TTPageViewController *)pageViewController {
    return YES;
}

- (NSInteger)numberOfItemInPageViewController:(TTPageViewController *)pageViewController {
    return self.mixModels.count;
}

- (__kindof UIViewController<TTPageItem> *)pageViewController:(TTPageViewController *)pageViewController pageForItemAtIndex:(NSUInteger)index {
    TTMixModel *mixModel = [self.mixModels objectAtIndex:index];
    if (mixModel.modelType == TTModelTypeVideo) {
        VOLogI(VOTTProto, @"TTModelTypeVideo, index: %ld", index);
        TTVideoCellController *cell = [pageViewController dequeueItemForReuseIdentifier:TTVideoCellReuseID];
        if (!cell) {
            cell = [TTVideoCellController new];
            cell.reuseIdentifier = TTVideoCellReuseID;
        }
        cell.delegate = self;
        cell.mixModel = mixModel;
        return cell;
    } else {
        VOLogI(VOTTProto, @"TTModelTypeLive, index: %ld", index);
        TTLiveCellController *cell = [pageViewController dequeueItemForReuseIdentifier:TTLiveCellReuseID];
        if (!cell) {
            cell = [TTLiveCellController new];
            cell.reuseIdentifier = TTLiveCellReuseID;
        }
        cell.mixModel = mixModel;
        return cell;
    }
}
- (void)pageViewController:(TTPageViewController *)pageViewController didScrollChangeDirection:(TTPageItemMoveDirection)direction offsetProgress:(CGFloat)progress {
    if (((self.mixModels.count - 1) - self.pageContainer.currentIndex <= TTMixFeedDetection) && direction == TTPageItemMoveDirectionNext) {
        VOLogI(VOTTProto, @"load more, isNoMoreData: %d", self.dataManager.isNoMoreData);
        // loadMore
        if (!self.pageContainer.scrollView.veLoading && !self.dataManager.isNoMoreData) {
            [self loadMoreData];
        }
    }
}
- (void)pageViewControllerWillBeginDragging:(TTPageViewController *)pageViewController {
    VOLogI(VOTTProto, @"WillBeginDragging");
    [VEVideoPlayerController cancelPreloadVideoSources];
}
- (NSArray *)getPreloadVideoModels:(NSUInteger)loc {
    NSMutableArray * videoModels = [NSMutableArray array];
    for (NSUInteger i = loc; i < self.mixModels.count -1; i ++) {
        if (self.mixModels[i].modelType == TTModelTypeVideo) {
            [videoModels addObject:self.mixModels[i].videoModel];
        }
        if (videoModels.count == TTPreloadVideoCount) {
            break;
        }
    }
    return [videoModels copy];
}
- (void)pageViewController:(TTPageViewController *)pageViewController didDisplayItem:(id<TTPageItem>)viewController atIndex:(NSUInteger)index {
    VOLogI(VOTTProto, @"didDisplayItem");
    if (!self.mixModels.count || index == self.mixModels.count - 1) {
        return;
    }
    NSUInteger loc = index + 1;
    [[self getPreloadVideoModels:loc] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [VEVideoPlayerController preloadVideoSource:[TTVideoModel videoEngineVidSource:obj]];
    }];
}

#pragma mark----- Lazy load

- (TTPageViewController *)pageContainer {
    if (!_pageContainer) {
        _pageContainer = [TTPageViewController new];
        _pageContainer.viewAppeared = YES;
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
        [_backButton setImage:[UIImage imageNamed:@"nav_left" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (TTDataManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [[TTDataManager alloc] init];
    }
    return _dataManager;
}

- (NSArray<TTMixModel *> *)mixModels {
    return self.dataManager.mixModels;
}

#pragma mark----- TTVideoCellControllerDelegate
- (void)TTVideoController:(TTVideoCellController *)controller shouldLockVerticalScroll:(BOOL)shouldLock {
    self.pageContainer.scrollView.scrollEnabled = !shouldLock;
}

#pragma mark -- TTVideoEnginePreRenderDelegate
- (void)videoEngine:(TTVideoEngine *)videoEngine willPreRenderSource:(id<TTVideoEngineMediaSource>)source {
    NSString *url = [(NSObject *)source valueForKey:@"cover"];
    VOLogI(VOTTProto, @"willPreRenderSource, url: %@", url);
}

- (void)videoEngineWillPrepare:(TTVideoEngine *)videoEngine {
    VOLogI(VOTTProto, @"videoEngineWillPrepare");
}

@end
