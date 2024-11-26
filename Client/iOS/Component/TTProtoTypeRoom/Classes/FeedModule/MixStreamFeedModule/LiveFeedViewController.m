//
//  LiveFeedViewController.m
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/11.
//

#import "LiveFeedViewController.h"
#import "TTPageViewController.h"
#import "TTLiveModel.h"
#import "TTDataManager.h"
#import "TTRTCManager.h"
#import "TTLiveRoomCellController.h"
#import <ToolKit/ToolKit.h>
#import <Masonry/Masonry.h>

static NSString *TTLiveRoomCellReuseID = @"TTLiveRoomCellReuseID";

static NSInteger TTLiveFeedDetection = 2;

@interface LiveFeedViewController () <TTPageDataSource, TTPageDelegate>

@property (nonatomic, strong) TTPageViewController *pageContainer;
@property (nonatomic, strong) TTDataManager *dataManager;
@property (nonatomic, strong) TTLiveModel *initialModel;
@property (nonatomic, strong) NSArray <TTLiveModel *> *liveModels;

@end

@implementation LiveFeedViewController

- (instancetype)initWithLiveModel:(TTLiveModel *)liveModel {
    self = [super init];
    if (self) {
        _initialModel = liveModel;
        [self intialRTCEngine];
    }
    return self;
}
#pragma mark -- system method override
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self firstLoadData];
    [self loadMoreData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc
{
    [[TTRTCManager shareRtc] disconnect];
}

#pragma mark ----- Private Method
- (void)initialUI {
    self.view.backgroundColor = [UIColor blackColor];
    [self addChildViewController:self.pageContainer];
    [self.view addSubview:self.pageContainer.view];
    [self.pageContainer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)firstLoadData {
    __weak typeof(self) weakSelf = self;
    self.pageContainer.scrollView.scrollEnabled = NO;
    [self.dataManager enterLiveRoomWithLiveModel:self.initialModel success:^{
        weakSelf.pageContainer.scrollView.scrollEnabled = YES;
        [weakSelf.pageContainer reloadData];
    } failure:^(NSString * _Nonnull errorMessage) {
        weakSelf.pageContainer.scrollView.scrollEnabled = YES;
    }];
}

- (void)loadMoreData {
    self.pageContainer.scrollView.veLoading = YES;
    __weak typeof(self) weakSelf = self;
    [self.dataManager looadMoreLiveRoomData:^{
        [weakSelf.pageContainer reloadContentSize];
        weakSelf.pageContainer.scrollView.veLoading = NO;
    } failure:^(NSString * _Nonnull errorMessage) {
        weakSelf.pageContainer.scrollView.veLoading = NO;
    }];
}


//create RTCVideo
- (void)intialRTCEngine {
    [[TTRTCManager shareRtc] connect:self.initialModel.appId bid:@"" block:^(BOOL result) {
        if (!result) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"tt_rtc_initial_failed", @"TTProto")];
        }
    }];
}

#pragma mark---- TTPageDataSource & TTPageDelegate

- (BOOL)shouldScrollVertically:(TTPageViewController *)pageViewController {
    return YES;
}

- (NSInteger)numberOfItemInPageViewController:(TTPageViewController *)pageViewController {
    VOLogI(VOTTProto, @"liveModels count: %ld", self.liveModels.count);
    return self.liveModels.count;
}

- (__kindof UIViewController<TTPageItem> *)pageViewController:(TTPageViewController *)pageViewController pageForItemAtIndex:(NSUInteger)index {
    VOLogI(VOTTProto, @"%@, index: %ld", TTLiveRoomCellReuseID, index);
    TTLiveModel *liveModel = [self.liveModels objectAtIndex:index];
    
    TTLiveRoomCellController *cell = [pageViewController dequeueItemForReuseIdentifier:TTLiveRoomCellReuseID];
    if (!cell) {
        cell = [[TTLiveRoomCellController alloc] init];
        cell.reuseIdentifier = TTLiveRoomCellReuseID;
    }
    cell.liveModel = liveModel;
    return cell;
}

- (void)pageViewControllerWillBeginDragging:(TTPageViewController *)pageViewController {
    VOLogI(VOTTProto, @"WillBeginDragging");
}
- (void)pageViewController:(TTPageViewController *)pageViewController willDisplayItem:(id<TTPageItem>)viewController {
    VOLogI(VOTTProto, @"willDisplayItem");
}
- (void)pageViewController:(TTPageViewController *)pageViewController didScrollChangeDirection:(TTPageItemMoveDirection)direction offsetProgress:(CGFloat)progress {
    if (((self.liveModels.count - 1) - self.pageContainer.currentIndex <= TTLiveFeedDetection) && direction == TTPageItemMoveDirectionNext) {
        VOLogI(VOTTProto, @"load more, isNoMoreData: %d", self.dataManager.isNoMoreData);
        // loadMore
        if (!self.pageContainer.scrollView.veLoading && !self.dataManager.isNoMoreData) {
            [self loadMoreData];
        }
    }
}
- (void)pageViewController:(TTPageViewController *)pageViewController didDisplayItem:(id<TTPageItem>)viewController atIndex:(NSUInteger)index {
    VOLogI(VOTTProto, @"didDisplayItem");
    
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


- (TTDataManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [[TTDataManager alloc] init];
    }
    return _dataManager;
}

- (NSArray<TTLiveModel *> *)liveModels {
    return self.dataManager.liveModels;
}

@end
