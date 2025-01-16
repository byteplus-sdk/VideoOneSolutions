//
//  MiniDramaDetailFeedViewController.m
//  MDPlayModule
//

#import "MiniDramaDetailFeedViewController.h"
#import "MiniDramaDetailVideoCellController.h"
#import "MiniDramaSelectionViewController.h"
#import "MiniDramaPayViewController.h"
#import "MDDramaFeedInfo.h"
#import "MDPageViewController.h"
#import "MDPlayerKit.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import "NSArray+BTDAdditions.h"
#import "BTDMacros.h"
#import "MDPlayerUtility.h"
#import "MiniDramaPayViewController.h"
#import "MDDramaEpisodeInfoModel.h"
#import "MDSimpleEpisodeInfoModel.h"
#import <ToolKit/ToolKit.h>
#import <ToolKit/UIImage+Bundle.h>
#import <ToolKit/Localizator.h>
#import "MiniDramaSelectionTabView.h"
#import "NetworkingManager+MiniDrama.h"
#import "MiniDramaPlayerSpeedView.h"
#import "MiniDramaLandscapeViewController.h"

static NSString *const MiniDramaDetailVideoFeedCellReuseID = @"MiniDramaDetailVideoFeedCellReuseID";

@interface MiniDramaDetailFeedViewController () <MiniDramaPageDataSource, 
MiniDramaPageDelegate,
MiniDramaDetailVideoCellControllerDelegate,
MiniDramaSelectionTabViewDelegate,
MiniDramaSelectionViewDelegate,
MiniDramaPayViewControllerDelegate,
MiniDramaPlayerSpeedViewDelegate,
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) MDPageViewController *pageContainer;
@property (nonatomic, strong) MiniDramaSelectionTabView *episodeSelectionTab;
@property (nonatomic, strong) MiniDramaSelectionViewController *selectionViewController;
@property (nonatomic, strong) MiniDramaPayViewController *payViewController;
@property (nonatomic, strong) UIButton *speedButton;
@property (nonatomic, strong) MiniDramaPlayerSpeedView *speedView;
@property (nonatomic, strong) UILabel *dramaEpisodeLabel;
@property (nonatomic, strong) NSMutableArray<MDDramaEpisodeInfoModel *> *dramaVideoModels;
@property (nonatomic, assign) NSInteger fromOrder;
@property (nonatomic, assign) NSInteger fromStartTime;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, assign) BOOL isLoadingData;
@property (nonatomic, strong) MDDramaInfoModel *fromDramInfo;
@end

@implementation MiniDramaDetailFeedViewController

- (instancetype)initWtihDramaVideoInfo:(MDDramaFeedInfo *)dramaVideoInfo {
    self = [super init];
    if (self) {
    
        _fromDramInfo =dramaVideoInfo.dramaInfo;
        
        self.fromOrder = dramaVideoInfo.videoInfo.order;
        self.fromStartTime = dramaVideoInfo.videoInfo.startTime;
    }
    return self;
}

- (instancetype)initWithDramaInfo:(MDDramaInfoModel *)dramaInfo {
    self = [super init];
    if (self) {
        _fromDramInfo = dramaInfo;
        self.fromOrder = 1;
        self.fromStartTime = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self configuratoinCustomView];
    [self firstUpdateDramaTitle];
    [self startVideoStategy];
    [self loadData:NO dramaId:self.fromDramInfo.dramaId];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MDVideoPlayerController clearAllEngineStrategy];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark ----- UI
- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor blackColor];
    
    UIView *tabbarView = [[UIView alloc] init];
    tabbarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:tabbarView];
    [tabbarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(82);
    }];
    [tabbarView addSubview:self.episodeSelectionTab];
    [tabbarView addSubview:self.speedButton];
    [self.episodeSelectionTab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(tabbarView).offset(12);
        make.height.mas_equalTo(36);
        make.width.mas_greaterThanOrEqualTo(290);
    }];
    [self.speedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.episodeSelectionTab);
        make.right.mas_equalTo(self.view).offset(-12);
        make.size.mas_equalTo(CGSizeMake(38, 36));
    }];
    
    [self addChildViewController:self.pageContainer];
    [self.view addSubview:self.pageContainer.view];
    [self.pageContainer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(tabbarView.mas_top);
    }];
    
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.dramaEpisodeLabel];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view).offset(24);
        }
        make.left.equalTo(self.view).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [self.dramaEpisodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.left.equalTo(self.backButton.mas_right);
    }];
}

- (void)setLandscape:(BOOL)landscape {
    _landscape = landscape;
}
#pragma mark ----- Data
- (void)loadData:(BOOL)isLoadMore dramaId:(NSString *)dramaId {
    if (self.isLoadingData) {
        return;
    }
    self.isLoadingData = YES;
    @weakify(self);
    [NetworkingManager getDramaDataForDetailPage:self.fromDramInfo.dramaId success:^(NSArray<MDDramaEpisodeInfoModel *> * _Nonnull list) {
        @strongify(self);
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            [self.dramaVideoModels removeAllObjects];
            [self.dramaVideoModels addObjectsFromArray:list];
            self.fromDramInfo.dramaLength = list.count;
            [self.pageContainer reloadData];
            [self onHandleFromDramaVideoInfo];
            self.episodeSelectionTab.episodeCount = list.count;
            self.isLoadingData = NO;
        });
        // set video strategy source
        [self setVideoStrategySource:!isLoadMore];
        self.pageContainer.scrollView.mj_header.hidden = YES;
    } failure:^(NSString * _Nonnull errMessage) {
        @strongify(self);
        [[ToastComponent shareToastComponent] showWithMessage:errMessage];
        self.isLoadingData = NO;
    }];
}
- (void)onHandleFromDramaVideoInfo {
    BOOL flag = NO;
    for (NSInteger i = 0; i < self.dramaVideoModels.count; i++) {
        MDDramaEpisodeInfoModel *tempDramaVideoInfo = [self.dramaVideoModels objectAtIndex:i];
        if (self.fromOrder == tempDramaVideoInfo.order) {
            if (self.fromStartTime > 0) {
                tempDramaVideoInfo.startTime = self.fromStartTime;
            }
            [self.pageContainer setCurrentIndex:i];
            flag = YES;
            break;
        }
    }
}

#pragma mark - private
- (void)firstUpdateDramaTitle {
    self.dramaEpisodeLabel.text = [NSString stringWithFormat:LocalizedStringFromBundle(@"mini_drama_episode_title", @"MiniDrama"), self.fromOrder];
}
- (void)updateDramaPlayOrderTitle {
    if (self.pageContainer.currentIndex < self.dramaVideoModels.count) {
        MDDramaEpisodeInfoModel *dramaVideoInfo = [self.dramaVideoModels objectAtIndex:self.pageContainer.currentIndex];
        self.dramaEpisodeLabel.text = [NSString stringWithFormat:LocalizedStringFromBundle(@"mini_drama_episode_title", @"MiniDrama"), dramaVideoInfo.order];
    }
}
- (void)updateParentPlayDramaVideoInfo {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(miniDramaDetailFeedViewWillback:)]) {
//        MDDramaEpisodeInfoModel *curDramaVideoInfo = [self.dramaVideoModels objectAtIndex:self.pageContainer.currentIndex];
//        // 当前剧集未解锁，找到上一个最近解锁的视频
//        if (curDramaVideoInfo.vip) {
//            for (NSInteger i = (self.dramaVideoModels.count - 1); i >= 0; i--) {
//                MDDramaEpisodeInfoModel *retDramaVideoInfo = [self.dramaVideoModels objectAtIndex:i];
//                if (retDramaVideoInfo.vip == NO) {
//                    curDramaVideoInfo = retDramaVideoInfo;
//                    break;
//                }
//            }
//        }
//        [self.delegate miniDramaDetailFeedViewWillback:curDramaVideoInfo];
//    }
}
- (void)handleSpeedButtomClick {
    [self.speedView showSpeedViewInView:self.view];
}

- (void)dismissPayviewController {
    if (self.payViewController) {
        [self.payViewController removeFromParentViewController];
        [self.payViewController.view removeFromSuperview];
        self.payViewController = nil;
    }
}
- (void)unlockEpisodes:(NSArray<MDDramaEpisodeInfoModel *> *)needPayArr {
    NSMutableArray  *vidList = [[NSMutableArray alloc] initWithCapacity:needPayArr.count];
    [needPayArr enumerateObjectsUsingBlock:^(MDDramaEpisodeInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [vidList addObject:obj.videoId];
    }];
    
    @weakify(self);
    [[ToastComponent shareToastComponent] showLoading];
    [NetworkingManager getDramaDataForPaymentEpisodeInfo:[LocalUserComponent userModel].uid
                                                 dramaId:self.fromDramInfo.dramaId
                                                 vidList:[vidList copy]
                                                 success:^(NSArray<MDSimpleEpisodeInfoModel *> * _Nonnull videoList) {
        [[ToastComponent shareToastComponent] dismiss];
        @strongify(self);
        NSInteger currentIndex = [self.pageContainer currentIndex];
        __block  BOOL includeCurrentView = NO;
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            [videoList enumerateObjectsUsingBlock:^(MDSimpleEpisodeInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSInteger index = obj.order - 1;
                self.dramaVideoModels[index].playAuthToken = obj.playAuthToken;
                self.dramaVideoModels[index].vip = NO;
                self.dramaVideoModels[index].subtitleToken = obj.subtitleToken;
                if (index == currentIndex) {
                    includeCurrentView = YES;
                }
            }];
            [self updateVideoStrategySource:needPayArr];
            if (includeCurrentView) {
                MiniDramaDetailVideoCellController *currentVC = [self.pageContainer currentViewController];
                [currentVC updateForUnlock];
            }
        });
    } failure:^(NSString * _Nonnull errMessage) {
        [[ToastComponent shareToastComponent] dismiss];
        [[ToastComponent shareToastComponent] showWithMessage:errMessage];
    }];

}

#pragma mark - engine startegy
- (void)setVideoStrategySource:(BOOL)reset {
    NSMutableArray *sources = [NSMutableArray array];
    [self.dramaVideoModels enumerateObjectsUsingBlock:^(MDDramaEpisodeInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.vip) {
            [sources addObject:[MDDramaEpisodeInfoModel videoEngineVidSource:obj]];
        }
    }];
    if (reset) {
        [MDVideoPlayerController setStrategyVideoSources:sources];
    } else {
        [MDVideoPlayerController addStrategyVideoSources:sources];
    }
}
- (void)updateVideoStrategySource:(NSArray <MDDramaEpisodeInfoModel *> *)videoModels {
    NSMutableArray *sources = [NSMutableArray array];
    [videoModels enumerateObjectsUsingBlock:^(MDDramaEpisodeInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sources addObject:[MDDramaEpisodeInfoModel videoEngineVidSource:obj]];
    }];
    [MDVideoPlayerController addStrategyVideoSources:sources];
}

- (void)startVideoStategy {
    [MDVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreRender scene:TTVEngineStrategySceneSmallVideo];
    [MDVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreload scene:TTVEngineStrategySceneSmallVideo];
}

#pragma mark -MiniDramaSelectionTabViewDelegate
- (void)onClickDramaSelectionCallback {
    if (self.pageContainer.currentIndex >= self.dramaVideoModels.count) {
        return;
    }
    MDDramaEpisodeInfoModel *dramaVideoInfo = [self.dramaVideoModels objectAtIndex:self.pageContainer.currentIndex];
    _selectionViewController = [[MiniDramaSelectionViewController alloc] initWtihDramaVideoInfo:dramaVideoInfo];
    _selectionViewController.dramaCoverUrl = self.fromDramInfo.dramaCoverUrl;
    _selectionViewController.dramaTitle = self.fromDramInfo.dramaTitle;
    _selectionViewController.dramaVideoModels = self.dramaVideoModels;
    _selectionViewController.delegate = self;
    [self addChildViewController:_selectionViewController];
    [self.view addSubview:_selectionViewController.view];
}

#pragma mark - MiniDramaSelectionViewControllerDelegate
- (void)onDramaSelectionCallback:(MDDramaEpisodeInfoModel *)dramaVideoInfo {
    if (dramaVideoInfo.vip) {
        [self onPlayNeedPayDramaVideo:dramaVideoInfo];
    }
    NSInteger currentIndex =  self.pageContainer.currentIndex;
    if (currentIndex < self.dramaVideoModels.count) {
        MDDramaEpisodeInfoModel *currentVideoModel = [self.dramaVideoModels objectAtIndex:currentIndex];
        if (currentVideoModel.order == dramaVideoInfo.order) {
            return;
        }
    }
    for (NSInteger i = 0; i < self.dramaVideoModels.count; i++) {
        MDDramaEpisodeInfoModel *tempDramaVideoInfo = [self.dramaVideoModels objectAtIndex:i];
        if (dramaVideoInfo.order == tempDramaVideoInfo.order) {
            [self.pageContainer setCurrentIndex:i];
            break;
        }
    }
}
- (void)onCloseHandleCallback {
    if (self.selectionViewController) {
        [self.selectionViewController removeFromParentViewController];
        [self.selectionViewController.view removeFromSuperview];
        self.selectionViewController = nil;
    }
}

- (void)onClickUnlockAllEpisode {
    __block NSInteger count = 0;
    [self.dramaVideoModels enumerateObjectsUsingBlock:^(MDDramaEpisodeInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.vip) {
            count ++;
        }
    }];
    if (count == 0) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"mini_drama_already_unlock_all", @"MiniDrama")];
        return;
    }
    self.payViewController.count = count;
    self.payViewController.vipCount = count;
    self.payViewController.dramaInfo = self.fromDramInfo;
    [self.payViewController showPayview];
}

#pragma mark - MiniDramaDetailVideoCellControllerDelegate

- (void)onDramaDetailVideoPlayStart:(MDDramaEpisodeInfoModel *)dramaVideoInfo {
    if (self.selectionViewController) {
        [self.selectionViewController updateCurrentDramaVideoInfo:dramaVideoInfo];
    }
}

- (void)onPlayNeedPayDramaVideo:(MDDramaEpisodeInfoModel *)dramaVideoInfo {
    self.payViewController.dramaInfo = self.fromDramInfo;
    __block NSInteger vipCount = 0;
    __block NSInteger afterVipCount = 0;
    [self.dramaVideoModels enumerateObjectsUsingBlock:^(MDDramaEpisodeInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.vip) {
            vipCount ++;
            if (obj.order >= dramaVideoInfo.order) {
                afterVipCount ++;
            }
        }
    }];
    self.payViewController.count = afterVipCount;
    self.payViewController.vipCount = vipCount;
    [self.payViewController showPopup];
}


- (void)onCurrentPlaybackSpeed:(CGFloat)speed {
    VOLogI(VOMiniDrama, @"onCurrentPlaybackSpeed : %f",speed);
    [self.speedButton setTitle:[NSString stringWithFormat:@"%.2fX", speed] forState:UIControlStateNormal];
}

#pragma mark -MiniDramaPlayerSpeedViewDelegate
- (void)onChoosePlaybackSpeed:(CGFloat)speed {
    MiniDramaDetailVideoCellController *cell = self.pageContainer.currentViewController;
    [cell updatePlaybackSeed:speed];
    [self.speedButton setTitle:[NSString stringWithFormat:@"%.2fX", speed] forState:UIControlStateNormal];
}

#pragma mark - MiniDramaPayViewControllerDelegate
- (void)onUnlockEpisode:(MiniDramaPayViewController *)vc count:(NSInteger)count {
    [self dismissPayviewController];
    if (count < 1) {
        return;
    }
    NSMutableArray <MDDramaEpisodeInfoModel *> *needLockArr = [[NSMutableArray alloc] init];
    NSInteger startIndex = self.pageContainer.currentIndex;
    [self.dramaVideoModels enumerateObjectsUsingBlock:^(MDDramaEpisodeInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.vip && idx >= startIndex) {
            [needLockArr addObject:obj];
        }
        if (needLockArr.count >= count) {
            *stop = YES;
        }
    }];
    if (needLockArr.count < count) {
        [self.dramaVideoModels enumerateObjectsUsingBlock:^(MDDramaEpisodeInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.vip) {
                [needLockArr addObject:obj];
            }
            if (needLockArr.count >= count) {
                *stop = YES;
            }
        }];
    }
    [self unlockEpisodes:[needLockArr copy]];
}

- (void)onUnlockAllEpisodes:(MiniDramaPayViewController *)vc {
    [self dismissPayviewController];
    NSMutableArray <MDDramaEpisodeInfoModel *> *needLockArr = [[NSMutableArray alloc] init];
    [self.dramaVideoModels enumerateObjectsUsingBlock:^(MDDramaEpisodeInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.vip) {
            [needLockArr addObject:obj];
        }
    }];
    [self unlockEpisodes:[needLockArr copy]];
}

#pragma mark - Event Response

- (void)onBackButtonHandle:(UIButton *)button {
    // Synchronize the current playing episode information of the parent page
    [self updateParentPlayDramaVideoInfo];
    [self.pageContainer onBack];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ---- PageViewControllerDataSource & Delegate

- (NSInteger)numberOfItemInPageViewController:(MDPageViewController *)pageViewController {
    return self.dramaVideoModels.count;
}

- (__kindof UIViewController<MiniDramaPageItem> *)pageViewController:(MDPageViewController *)pageViewController pageForItemAtIndex:(NSUInteger)index {
    MiniDramaDetailVideoCellController *cell = [pageViewController dequeueItemForReuseIdentifier:MiniDramaDetailVideoFeedCellReuseID];
    if (!cell) {
        cell = [MiniDramaDetailVideoCellController new];
        cell.reuseIdentifier = MiniDramaDetailVideoFeedCellReuseID;
    }
    cell.delegate = self;
    cell.dramaVideoModels = self.dramaVideoModels;
    if (index < self.dramaVideoModels.count) {
        [cell reloadData:[self.dramaVideoModels objectAtIndex:index]];
    }
    return cell;
}

- (BOOL)shouldScrollVertically:(MDPageViewController *)pceageViewController{
    return YES;
}

- (void)pageViewController:(MDPageViewController *)pageViewController willDisplayItem:(id<MiniDramaPageItem>)viewController {
    
}

- (void)pageViewController:(MDPageViewController *)pageViewController didDisplayItem:(id<MiniDramaPageItem>)viewController {
    [self updateDramaPlayOrderTitle];
}

#pragma mark ----- Lazy load

- (MDPageViewController *)pageContainer {
    if (!_pageContainer) {
        _pageContainer = [MDPageViewController new];
        _pageContainer.dataSource = self;
        _pageContainer.viewAppeared = YES;
        _pageContainer.delegate = self;
        _pageContainer.scrollView.directionalLockEnabled = YES;
        _pageContainer.scrollView.scrollsToTop = NO;
    }
    return _pageContainer;
}

- (MiniDramaSelectionTabView *)episodeSelectionTab {
    if (!_episodeSelectionTab) {
        _episodeSelectionTab = [[MiniDramaSelectionTabView alloc] init];
        _episodeSelectionTab.delegate = self;
    }
    return _episodeSelectionTab;
}

- (UIButton *)speedButton {
    if (!_speedButton) {
        _speedButton = [[UIButton alloc] init];
        [_speedButton addTarget:self action:@selector(handleSpeedButtomClick) forControlEvents:UIControlEventTouchUpInside];
        _speedButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_speedButton setTitleColor:[UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.75 * 255] forState:UIControlStateNormal];
    }
    return _speedButton;
}

- (MiniDramaPlayerSpeedView *)speedView {
    if (!_speedView) {
        _speedView = [[MiniDramaPlayerSpeedView alloc] init];
        _speedView.delegate = self;
    }
    return _speedView;
}

- (NSMutableArray<MDDramaEpisodeInfoModel *> *)dramaVideoModels {
    if (!_dramaVideoModels) {
        _dramaVideoModels = [NSMutableArray array];
    }
    return _dramaVideoModels;
}

- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"video_page_back" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(onBackButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)dramaEpisodeLabel {
    if (_dramaEpisodeLabel == nil) {
        _dramaEpisodeLabel = [[UILabel alloc] init];
        _dramaEpisodeLabel.textColor = [UIColor whiteColor];
        _dramaEpisodeLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    return _dramaEpisodeLabel;
}

- (MiniDramaPayViewController *)payViewController {
    if (_payViewController == nil) {
        _payViewController = [[MiniDramaPayViewController alloc] init];
        _payViewController.delegate = self;
    }
    return _payViewController;
}

@end
