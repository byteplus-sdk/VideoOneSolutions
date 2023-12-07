// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoDetailViewController.h"
#import "NSString+VE.h"
#import "NetworkingManager+Vod.h"
#import "VEDataManager.h"
#import "VEEventMessageBus.h"
#import "VEInterfaceSimpleBlockSceneConf.h"
#import "VEPlayerKit.h"
#import "VEPlayerUIModule.h"
#import "VESettingManager.h"
#import "VEVideoDetailTableView.h"
#import "VEVideoDetailVideoInfoView.h"
#import "VEVideoModel.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIColor+String.h>
#import <ToolKit/UIViewController+Orientation.h>

@interface VEVideoDetailViewController () <VEInterfaceDelegate, VEVideoDetailTableViewDelegate>

@property (nonatomic, strong) VEVideoPlayerController *playerController; // player Container

@property (nonatomic, strong) VEInterface *playerControlView; // player Control view

@property (nonatomic, strong) UIView *playContainerView; // playerView & playerControlView Container

@property (nonatomic, strong) VEVideoDetailTableView *tableView;
@property (nonatomic, assign) VEVideoPlayerType videoPlayerType;
@property (nonatomic, strong) NSMutableArray<VEVideoModel *> *recommendedListData;

@property (nonatomic, strong) VEVideoDetailVideoInfoView *videoInfoView;

@end

@implementation VEVideoDetailViewController

- (instancetype)initWithType:(VEVideoPlayerType)videoPlayerType {
    self = [super init];
    if (self) {
        self.videoPlayerType = videoPlayerType;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_playerControlView) {
        [_playerControlView removeFromSuperview];
        [_playerControlView destory];
        _playerControlView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadPlayerController];
    [self layoutUI];
    [self addOrientationNotice];
    if (!self.landscapeMode) {
        [self loadDataWithRecommended:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    if (self.closeCallback) {
        self.closeCallback(self.landscapeMode, self.playerController);
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    if (!parent) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [_playerControlView destory];
    }
}

- (void)layoutUI {
    if (self.landscapeMode) {
        [self setDeviceInterfaceOrientation:UIDeviceOrientationLandscapeLeft];
    }
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationItem.title = @"";
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.playContainerView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.videoInfoView];
    [self.playContainerView addSubview:self.playerController.view];
    [self.playContainerView addSubview:self.playerControlView];
    [self.playContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
    }];
    [self.videoInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view).offset(12);
        make.trailing.mas_equalTo(self.view).offset(-12);
        make.top.mas_equalTo(self.playContainerView.mas_bottom).offset(20);
    }];
    [self.playerController.view mas_remakeConstraints:^(MASConstraintMaker *make) { // need remake
        make.edges.equalTo(self.playContainerView);
    }];
    [self.playerControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playContainerView);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.videoInfoView.mas_bottom).offset(16);
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).priority(MASLayoutPriorityDefaultLow);
    }];
    [self updateUI];
}

- (void)updateUI {
    BOOL isPortrait = normalScreenBehaivor();
    self.navigationController.interactivePopGestureRecognizer.enabled = isPortrait;
    CGFloat screenRate = isPortrait ? (9.0 / 16.0) : (UIScreen.mainScreen.bounds.size.height / UIScreen.mainScreen.bounds.size.width);
    CGFloat height = UIScreen.mainScreen.bounds.size.width * (screenRate);
    CGFloat top = isPortrait ? UIApplication.sharedApplication.statusBarFrame.size.height : 0.0;

    [self.playContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(top);
        make.height.equalTo(@(height));
    }];

    if (@available(iOS 11.0, *)) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
}

- (void)setVideoModel:(VEVideoModel *)videoModel {
    _videoModel = videoModel;
    if (self.viewLoaded) {
        [self reloadPlayerController];
        [_videoInfoView updateModel:videoModel];
    }
}

- (void)reloadPlayerController {
    VEVideoPlayerController *mayPlayer = [self.delegate currentPlayerController:self.videoModel];
    if ([mayPlayer isKindOfClass:[VEVideoPlayerController class]]) {
        [mayPlayer.view removeFromSuperview];
        [mayPlayer removeFromParentViewController];
        [self addChildViewController:mayPlayer];
        self.playerController = mayPlayer;
        [self.playerController play];
    } else {
        [self playerOptions];
        if (self.videoModel.playUrl) {
            [self.playerController playWithMediaSource:[VEVideoModel videoEngineUrlSource:self.videoModel]];
        } else if (self.videoModel.videoId) {
            [self.playerController playWithMediaSource:[VEVideoModel videoEngineVidSource:self.videoModel]];
        }
        [self.playerController play];
    }
    self.playerController.playerTitle = self.videoModel.title;
}

- (void)reloadTableView:(NSArray<VEVideoModel *> *)listData {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(VEVideoModel *videoModel, NSDictionary *bindings) {
        return ![videoModel.videoId isEqualToString:self.videoModel.videoId];
    }];
    NSArray *filteredArray = [listData filteredArrayUsingPredicate:predicate];
    self.tableView.hidden = filteredArray.count > 0 ? NO : YES;
    self.tableView.dataLists = filteredArray;
}

#pragma mark - Getter

- (UIView *)playContainerView {
    if (!_playContainerView) {
        _playContainerView = [UIView new];
    }
    return _playContainerView;
}

- (VEInterface *)playerControlView {
    if (!_playerControlView) {
        VEInterfaceSimpleBlockSceneConf *scene = [VEInterfaceSimpleBlockSceneConf new];
        if (self.videoPlayerType == VEVideoPlayerTypeShortHorizontalScreen) {
            scene.skipPlayMode = YES;
        }
        scene.videoModel = self.videoModel;
        _playerControlView = [[VEInterface alloc] initWithPlayerCore:self.playerController scene:scene];
        _playerControlView.delegate = self;
    }
    return _playerControlView;
}

- (VEVideoPlayerController *)playerController {
    if (!_playerController) {
        _playerController = [[VEVideoPlayerController alloc] initWithType:self.videoPlayerType];
        [self addChildViewController:_playerController];
    }
    return _playerController;
}

- (VEVideoDetailVideoInfoView *)videoInfoView {
    if (!_videoInfoView) {
        _videoInfoView = [VEVideoDetailVideoInfoView new];
        [_videoInfoView updateModel:self.videoModel];
    }
    return _videoInfoView;
}

- (VEVideoDetailTableView *)tableView {
    if (!_tableView) {
        _tableView = [[VEVideoDetailTableView alloc] init];
        _tableView.delegate = self;
        _tableView.hidden = YES;
    }
    return _tableView;
}

- (NSMutableArray<VEVideoModel *> *)recommendedListData {
    if (!_recommendedListData) {
        _recommendedListData = [[NSMutableArray alloc] init];
    }
    return _recommendedListData;
}

- (void)playerOptions {
    VESettingModel *preRender = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreRenderStrategy];
    self.playerController.preRenderOpen = preRender.open;

    VESettingModel *preload = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreloadStrategy];
    self.playerController.preloadOpen = preload.open;

    VESettingModel *h265 = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalH265];
    self.playerController.h265Open = h265.open;

    VESettingModel *hardwareDecode = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalHardwareDecode];
    self.playerController.hardwareDecodeOpen = hardwareDecode.open;
}

#pragma mark----- Network request Method

- (void)loadDataWithRecommended:(BOOL)isRefresh {
    NSInteger sceneType = (self.videoPlayerType == VEVideoPlayerTypeFeed) ? VESceneTypeFeedVideo : VESceneTypeLongVideo;
    NSInteger limit = 10;
    __weak __typeof(self) wself = self;
    [NetworkingManager similarDataForScene:sceneType
                                       vid:self.videoModel.videoId
                                     range:NSMakeRange(self.recommendedListData.count, limit)
                                   success:^(NSArray<VEVideoModel *> *_Nonnull videoModels) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (isRefresh) {
                                               [wself.recommendedListData removeAllObjects];
                                           }
                                           [wself.recommendedListData addObjectsFromArray:videoModels];
                                           [wself reloadTableView:[wself.recommendedListData copy]];
                                           if (videoModels.count < limit) {
                                               [wself.tableView endRefreshingWithNoMoreData];
                                           } else {
                                               [wself.tableView endRefresh];
                                           }
                                       });
                                   }
                                   failure:nil];
}

#pragma mark----- VEVideoDetailTableViewDelegate

- (void)tableView:(VEVideoDetailTableView *)tableView didSelectRowAtModel:(VEVideoModel *)model {
    self.closeCallback = nil;
    VEVideoDetailViewController *detailViewController = [[VEVideoDetailViewController alloc] initWithType:self.videoPlayerType];
    detailViewController.videoModel = model;
    UINavigationController *navigationController = self.navigationController;
    NSMutableArray *viewControllers = navigationController.viewControllers.mutableCopy;
    [viewControllers removeObject:self];
    [navigationController setViewControllers:viewControllers animated:NO];
    [navigationController pushViewController:detailViewController animated:NO];
}

- (void)tableView:(VEVideoDetailTableView *)tableView loadDataWithMore:(BOOL)result {
    [self loadDataWithRecommended:NO];
}

#pragma mark----- VEInterfaceDelegate

- (void)interfaceCallScreenRotation:(UIView *)interface {
    UIDeviceOrientation oriention = normalScreenBehaivor() ? UIDeviceOrientationLandscapeLeft : UIDeviceOrientationPortrait;
    [self setDeviceInterfaceOrientation:oriention];
}

#pragma mark----- UIInterfaceOrientation

- (void)orientationDidChang:(BOOL)isLandscape {
    [self updateUI];
    [self.view setNeedsLayout];
}

- (void)interfaceCallPageBack:(UIView *)interface {
    if (normalScreenBehaivor()) {
        [self closeViewControllerAnimated:YES];
        return;
    }
    if (self.landscapeMode) {
        // 全屏模式需要先 pop 然后竖屏
        [self closeViewControllerAnimated:NO];
        [self setDeviceInterfaceOrientation:UIDeviceOrientationPortrait];
        return;
    }
    // 需要通过发送通知的形式刷新UI
    [self.playerControlView.eventMessageBus postEvent:VEUIEventScreenRotation withObject:nil rightNow:YES];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return !normalScreenBehaivor();
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return 1;
}

- (void)closeViewControllerAnimated:(BOOL)animated {
    if (self.closeCallback) {
        self.closeCallback(self.landscapeMode, self.playerController);
        self.closeCallback = nil;
    }
    [self.navigationController popViewControllerAnimated:animated];
}

@end
