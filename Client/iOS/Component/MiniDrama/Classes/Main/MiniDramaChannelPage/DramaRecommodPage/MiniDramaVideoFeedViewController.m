//
//  MiniDramaVideoFeedViewController.m
//  VOLCDemo
//

#import "MiniDramaVideoFeedViewController.h"
#import "MiniDramaVideoCellController.h"
#import "MDPageViewController.h"
#import "MDPlayerKit.h"
#import <Masonry/Masonry.h>
#import "MDDramaFeedInfo.h"
#import "MiniDramaDetailFeedViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "BTDMacros.h"
#import "MDDramaEpisodeInfoModel.h"
#import <NetworkingManager+MiniDrama.h>
#import <TTSDK/TTVideoEngine+Strategy.h>
#import <ToolKit/ToolKit.h>

static NSInteger MiniDramaVideoFeedPageCount = 10;
static NSInteger MiniDramaVideoFeedLoadMoreDetection = 3;

static NSString *MiniDramaVideoFeedCellReuseID = @"MiniDramaVideoFeedCellReuseID";

@interface MiniDramaVideoFeedViewController ()<
MiniDramaPageDataSource,
MiniDramaPageDelegate,
MiniDramaVideoCellControllerDelegate
>

@property (nonatomic, strong) MDPageViewController *pageContainer;
@property (nonatomic, strong) NSMutableArray<MDDramaFeedInfo *> *dramaVideoModels;
@property (nonatomic, assign) NSInteger pageOffset;
@property (nonatomic, assign) BOOL isLoadingData;
@property (nonatomic, assign) BOOL enableLoadMore;

@end

@implementation MiniDramaVideoFeedViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.pageOffset = 0;
        self.enableLoadMore = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData:NO];
    [self configuratoinCustomView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.dramaVideoModels.count > 0 && self.viewisVisible) {
        [self startVideoStategy];
        [self setVideoStrategySource:YES];
    }
}

- (void)setViewisVisible:(BOOL)viewisVisible {
    _viewisVisible = viewisVisible;
    if (viewisVisible) {
        [self startVideoStategy];
        [self setVideoStrategySource:YES];
    } else {
        [MDVideoPlayerController clearAllEngineStrategy];
    }
    MiniDramaVideoCellController *cellController = (MiniDramaVideoCellController *)self.pageContainer.currentViewController;
    if (cellController) {
        if (viewisVisible) {
            [cellController playerResume];
        } else {
            [cellController playerPause];
        }
    }
    self.pageContainer.viewAppeared = viewisVisible;
}

#pragma mark ----- UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor blackColor];
    [self addChildViewController:self.pageContainer];
    [self.view addSubview:self.pageContainer.view];
    [self.pageContainer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    @weakify(self);
    self.pageContainer.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadData:NO];
    }];
    self.pageContainer.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self loadData:YES];
    }];
    self.pageContainer.scrollView.mj_footer.hidden = YES;
}

#pragma mark ----- Data
- (void)loadData:(BOOL)isLoadMore {
    if (self.isLoadingData) {
        return;
    }
    self.isLoadingData = YES;
    if (!isLoadMore) {
        self.pageOffset = 0;
        self.pageContainer.scrollView.mj_footer.hidden = NO;
        [[ToastComponent shareToastComponent] showLoading];
    }
    
    @weakify(self);
    [NetworkingManager getDramaDataForChannelPage:NSMakeRange(self.pageOffset, MiniDramaVideoFeedPageCount) success:^(NSArray<MDDramaFeedInfo *> * _Nonnull list) {
        [[ToastComponent shareToastComponent] dismiss];
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isLoadMore) {
                [self.dramaVideoModels addObjectsFromArray:list];
                [self.pageContainer reloadContentSize];
                [self.pageContainer.scrollView.mj_footer endRefreshing];
            } else {
                self.dramaVideoModels = [list mutableCopy];
                [self.pageContainer.scrollView.mj_header endRefreshing];
                [self.pageContainer reloadData];
            }
            
            // set video strategy source
            if (self.viewisVisible) {
                [self setVideoStrategySource:!isLoadMore];
            }
            self.pageOffset = self.dramaVideoModels.count;
            
            if (list.count < MiniDramaVideoFeedPageCount) {
                self.enableLoadMore = NO;
                self.pageContainer.scrollView.mj_footer.hidden = YES;
            } else {
                self.enableLoadMore = YES;
                self.pageContainer.scrollView.mj_footer.hidden = NO;
            }
            self.isLoadingData = NO;
        });
    } failure:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ToastComponent shareToastComponent] dismiss];
            [[ToastComponent shareToastComponent] showWithMessage:message];
            self.isLoadingData = NO;
        });
    }];
}
- (void)setVideoStrategySource:(BOOL)reset {
    NSMutableArray *sources = [NSMutableArray array];
    [self.dramaVideoModels enumerateObjectsUsingBlock:^(MDDramaFeedInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sources addObject:[MDDramaEpisodeInfoModel videoEngineVidSource:obj.videoInfo]];
    }];
    if (reset) {
        [MDVideoPlayerController setStrategyVideoSources:sources];
    } else {
        [MDVideoPlayerController addStrategyVideoSources:sources];
    }
}

- (void)startVideoStategy {
    [MDVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreRender scene:TTVEngineStrategySceneSmallVideo];
    [MDVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreload scene:TTVEngineStrategySceneSmallVideo];
}

#pragma mark - MiniDramaVideoCellControllerDelegate
- (void)dramaVideoWatchDetail:(MDDramaFeedInfo *)dramaVideoInfo {
    [MDVideoPlayerController clearAllEngineStrategy];
    MiniDramaDetailFeedViewController *detailFeedViewController = [[MiniDramaDetailFeedViewController alloc] initWtihDramaVideoInfo:dramaVideoInfo];
    MiniDramaVideoCellController *cellController = (MiniDramaVideoCellController *)self.pageContainer.currentViewController;
    if (cellController) {
        [cellController playerPause];
    }
    [self.navigationController pushViewController:detailFeedViewController animated:YES];
}

#pragma mark ---- PageViewControllerDataSource & Delegate

- (NSInteger)numberOfItemInPageViewController:(MDPageViewController *)pageViewController {
    return self.dramaVideoModels.count;
}

- (__kindof UIViewController<MiniDramaPageItem> *)pageViewController:(MDPageViewController *)pageViewController pageForItemAtIndex:(NSUInteger)index {
    MiniDramaVideoCellController *cell = [pageViewController dequeueItemForReuseIdentifier:MiniDramaVideoFeedCellReuseID];
    if (!cell) {
        cell = [MiniDramaVideoCellController new];
        cell.delegate = self;
        cell.reuseIdentifier = MiniDramaVideoFeedCellReuseID;
    }
    [cell reloadData:[self.dramaVideoModels objectAtIndex:index]];
    return cell;
}

- (BOOL)shouldScrollVertically:(MDPageViewController *)pageViewController{
    return YES;
}

- (void)pageViewController:(MDPageViewController *)pageViewController didDisplayItem:(id<MiniDramaPageItem>)viewController {
    if (self.enableLoadMore && ((self.dramaVideoModels.count - 1) - self.pageContainer.currentIndex) <= MiniDramaVideoFeedLoadMoreDetection) {
        [self loadData:YES];
    }
}

#pragma mark ----- Lazy load

- (MDPageViewController *)pageContainer {
    if (!_pageContainer) {
        _pageContainer = [MDPageViewController new];
        _pageContainer.dataSource = self;
        _pageContainer.delegate = self;
        _pageContainer.scrollView.directionalLockEnabled = YES;
        _pageContainer.scrollView.scrollsToTop = NO;
    }
    return _pageContainer;
}

- (NSMutableArray *)dramaVideoModels {
    if (!_dramaVideoModels) {
        _dramaVideoModels = [NSMutableArray array];
    }
    return _dramaVideoModels;
}

@end
