// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaLandscapeViewController.h"
#import "FullScreenVideoGestureGuide.h"
#import "MDPlayerUIModule.h"
#import "MDPlayerKit.h"
#import "MiniDramaLandscapeSceneConf.h"
#import "NetworkingManager+MiniDrama.h"
#import <Masonry/Masonry.h>
#import "MDEventMessageBus.h"
#import "MDEventConst.h"
#import "MiniDramaSelectionFloatView.h"
#import "MiniDramaEpisodeSelectionProtocol.h"
#import <ToolKit/ToolKit.h>
#import <ToolKit/UIViewController+Orientation.h>
#import "NetworkingManager+MiniDrama.h"
#import "MiniDramaPayViewController.h"
#import "NetworkingManager+MiniDrama.h"
#import "DramaSubtitleManage.h"
#import "DramaSubtitleListView.h"
#import "MDVideoPlayerController+Observer.h"
#import <AVKit/AVKit.h>
#import "MDVideoPlayerController+DisRecordScreen.h"

@interface MiniDramaLandscapeViewController ()<MDVideoPlaybackDelegate,
MDInterfaceDelegate,
MiniDramaSelectionViewDelegate,
MiniDramaPayViewControllerDelegate,
DramaSubtitleListViewDelegate,
MDPlayCorePipStatusDelegate
>

@property (nonatomic, strong) MDVideoPlayerController *playerController;

@property (nonatomic, strong) MDInterface *playerControlView; // player Control view

@property (nonatomic, strong) UIView *playContainerView; // playerView & playerControlView Container

@property (nonatomic, strong) MiniDramaPayViewController *payViewController;

@property (nonatomic, strong) MiniDramaLandscapeSceneConf *scene;

@property (nonatomic, strong) MDDramaEpisodeInfoModel *videoModel;

@property (nonatomic, strong) NSMutableArray<MDDramaEpisodeInfoModel *> *dramaVideoModels;

@property (nonatomic, strong) MDDramaInfoModel *fromDramInfo;

@property (nonatomic, strong) MDDramaEpisodeInfoModel *fromVideoInfo;

@property (nonatomic, strong) DramaSubtitleManage *manager;

@property (nonatomic, assign) BOOL isOpenPip;

@end

@implementation MiniDramaLandscapeViewController
static inline BOOL normalScreenBehaivor () {
    return ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait);
}

- (instancetype)initWithDramaInfo:(MDDramaInfoModel *)dramaInfo {
    self = [super init];
    if (self) {
        _fromDramInfo = dramaInfo;
    }
    return self;
}

- (instancetype)initWithVideoInfo:(MDDramaFeedInfo *)videoInfo {
    self = [super init];
    if (self) {
        _fromDramInfo = videoInfo.dramaInfo;
        _fromVideoInfo = videoInfo.videoInfo;
    }
    return self;
}

- (instancetype)initWithDramaList:(NSArray<MDDramaEpisodeInfoModel *> *)dramaModels dramaVideoInfo:(MDDramaFeedInfo *)dramaVideoInfo episodeInfo:(MDDramaEpisodeInfoModel *)episodeInfo {
    self = [super init];
    if (self) {
        _fromDramInfo = dramaVideoInfo.dramaInfo;
        _fromVideoInfo = episodeInfo;
        _dramaVideoModels = [dramaModels mutableCopy];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutUI];
    [self updateUIToSize:self.view.bounds.size];
    [self startVideoStategy];
    [self loadData];
    if (self.landscapeMode) {
        [self setDeviceInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MDVideoPlayerController clearAllEngineStrategy];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.playerController.closeResumePlay = NO;
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

#pragma mark - Private
- (void)startVideoStategy {
    [MDVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreRender scene:TTVEngineStrategySceneSmallVideo];
    [MDVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreload scene:TTVEngineStrategySceneSmallVideo];
}
- (void)loadData {
    if (self.dramaVideoModels.count > 0) {
        [self setVideoStrategySource];
        [self updateCurrentVideo:(MDDramaEpisodeInfoModel *)self.fromVideoInfo];
        return;
    }
    @weakify(self);
    [[ToastComponent shareToastComponent] showLoading];
    [NetworkingManager getDramaDataForDetailPage:self.fromDramInfo.dramaId success:^(NSArray<MDDramaEpisodeInfoModel *> * _Nonnull list) {
        @strongify(self);
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            [[ToastComponent shareToastComponent] dismiss];
            [self.dramaVideoModels addObjectsFromArray:list];
            // set video strategy source
            [self setVideoStrategySource];
            if (self.fromVideoInfo) {
                [self updateCurrentVideo:self.dramaVideoModels[self.fromVideoInfo.order - 1]];
            } else {
                [self updateCurrentVideo:self.dramaVideoModels.firstObject];
            }
        });
    } failure:^(NSString * _Nonnull errMessage) {
        [[ToastComponent shareToastComponent] dismiss];
        @strongify(self);
        [[ToastComponent shareToastComponent] showWithMessage:errMessage];
    }];
}
- (void)setVideoStrategySource {
    NSMutableArray *sources = [NSMutableArray array];
    [self.dramaVideoModels enumerateObjectsUsingBlock:^(MDDramaEpisodeInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.vip) {
            [sources addObject:[MDDramaEpisodeInfoModel videoEngineVidSource:obj]];
        }
    }];
    [MDVideoPlayerController setStrategyVideoSources:sources];
}
- (void)updateVideoStrategySource:(NSArray <MDDramaEpisodeInfoModel *> *)videoModels {
    NSMutableArray *sources = [NSMutableArray array];
    [videoModels enumerateObjectsUsingBlock:^(MDDramaEpisodeInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sources addObject:[MDDramaEpisodeInfoModel videoEngineVidSource:obj]];
    }];
    [MDVideoPlayerController addStrategyVideoSources:sources];
}

- (void)registMessage {
    [[MDEventMessageBus universalBus] registEvent:MDUIEventShowEpisodesView withAction:@selector(showEpisodesSelectionView) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDPlayEventShowSubtitleMenu withAction:@selector(showSubtileView) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDPlayEventPlay withAction:@selector(checkVideo) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDPlayEventPause withAction:@selector(checkVideo) ofTarget:self];
}

-(void)checkVideo {
    if (self.videoModel && self.videoModel.vip) {
        [self onPlayNeedPayDramaVideo:self.videoModel];
    }
}
- (void)showEpisodesSelectionView {
    [[MDEventPoster currentPoster] setScreenIsClear:YES];
    [[MDEventMessageBus universalBus] postEvent:MDUIEventScreenClearStateChanged withObject:nil rightNow:YES];
    MiniDramaSelectionFloatView *episodeSelectionView = [[MiniDramaSelectionFloatView alloc] initWtihDramaVideoInfo:self.videoModel dramaList:self.dramaVideoModels];
    episodeSelectionView.dramaCoverUrl = self.fromDramInfo.dramaCoverUrl;
    episodeSelectionView.dramaTitle = self.fromDramInfo.dramaTitle;
    episodeSelectionView.delegate = self;
    [episodeSelectionView show];
}
- (void)showSubtileView {
    [[MDEventPoster currentPoster] setScreenIsClear:YES];
    [[MDEventMessageBus universalBus] postEvent:MDUIEventScreenClearStateChanged withObject:nil rightNow:YES];
    DramaSubtitleListView *subtitleListView = [[DramaSubtitleListView alloc] init];
    subtitleListView.delegate = self;
    subtitleListView.subtitleList = self.manager.subtitleList;
    subtitleListView.currentSubtitleId = self.manager.currentSubtitleModel.subtitleId;
    [subtitleListView show];
}

- (void)layoutUI {
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationItem.title = @"";
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.playContainerView];
    [self.playContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.leading.trailing.equalTo(self.view);
    }];
}

- (void)updateUIToSize:(CGSize)size {
    BOOL isPortrait = size.height > size.width;
    self.navigationController.interactivePopGestureRecognizer.enabled = isPortrait;
    CGFloat screenRate = isPortrait ? (9.0 / 16.0) : (size.height / size.width);
    CGFloat height = size.width * (screenRate);
    [self.playContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(height));
    }];
    [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    if (!isPortrait) {
        [FullScreenVideoGestureGuide addGuideIfNeed:self.view];
    }
}

- (void)updateCurrentVideo:(MDDramaEpisodeInfoModel *)episodeModel {
    _videoModel = episodeModel;
    if (normalScreenBehaivor()) {
        [self setDeviceInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }
    [self reset];
    [self createPlayerAndView];
    if (episodeModel.vip) {
        [self onPlayNeedPayDramaVideo:episodeModel];
        [self.scene updatePlayButton:NO];
        return;
    }
    [self.playerController registerScreenCapturedDidChangeNotification];
    [self.playerController loadBackgourdImageWithMediaSource:[MDDramaEpisodeInfoModel videoEngineVidSource:episodeModel]];
    [self.playerController playWithMediaSource:[MDDramaEpisodeInfoModel videoEngineVidSource:episodeModel]];
    self.playerController.posterImageView.hidden = YES;
    [self setupSubtitle];
}
- (void)setupSubtitle {
    [self.manager clearState];
    self.manager.videoEngine = self.playerController.videoEngine;
    [self.manager openSubtitle:self.videoModel.subtitleToken];
    @weakify(self);
    self.manager.openSubtitleBlock = ^(BOOL result, DramaSubtitleModel * _Nullable model) {
        [weak_self.scene refreshSubtitleButton:model];
    };
}

- (void)reset {
    self.scene = nil;
    [self playerStop];
    [self resetPlayerControlView];
    [self.manager.subTitleLabel removeFromSuperview];
    [self.manager.subTitleLabel setText:@""];
}

- (void)createPlayerAndView {
    MDVideoPlayerConfiguration *configration = [MDVideoPlayerConfiguration defaultPlayerConfiguration];
    configration.enablePip = [AVPictureInPictureController isPictureInPictureSupported];
    configration.videoViewMode = MDVideoViewModeAspectFit;
    _playerController = [[MDVideoPlayerController alloc] initWithConfiguration:configration];
    _playerController.preloadOpen = YES;
    _playerController.preRenderOpen = YES;
    _playerController.delegate = self;
    _playerController.playerTitle = self.videoModel.videoTitle;
    _playerController.isPipOpen = self.isOpenPip;
    _playerController.pipStatusDelegate = self;
    [self.playContainerView addSubview:self.playerController.view];
    [self.playerController.view mas_remakeConstraints:^(MASConstraintMaker *make) { // need remake
        make.edges.equalTo(self.playContainerView);
    }];
    
    MiniDramaLandscapeSceneConf *scene = [MiniDramaLandscapeSceneConf new];
    scene.videoModel = self.videoModel;
    scene.videoCount = self.dramaVideoModels.count;
    
    _scene = scene;
    self.playerControlView = [[MDInterface alloc] initWithPlayerCore:self.playerController scene:scene];
    self.playerControlView.delegate = self;
    
    [self.playContainerView addSubview:self.playerControlView];
    [self.playerControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playContainerView);
    }];
    
    [self.playContainerView insertSubview:self.manager.subTitleLabel aboveSubview:self.playerController.view];
    [self.manager.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(44);
        make.trailing.offset(-44);
        make.bottom.equalTo(self.playContainerView.mas_safeAreaLayoutGuideBottom).offset(-25);
    }];
    [self registMessage];
}

- (void)playerStop {
    if (self.playerController) {
        [self.playerController stop];
        [self.playerController.view removeFromSuperview];
        [self.playerController removeFromParentViewController];
        self.playerController = nil;
    }
}

- (void)resetPlayerControlView {
    if (_playerControlView) {
        [_playerControlView removeFromSuperview];
        [_playerControlView destory];
        _playerControlView = nil;
    }
}

- (void)closeViewControllerAnimated:(BOOL)animated {
//    if (self.closeCallback) {
//        self.closeCallback(self.landscapeMode, self.playerController);
//        self.closeCallback = nil;
//    }
    [self reset];
    [self.navigationController popViewControllerAnimated:animated];
}

#pragma mark - DramaSubtitleListViewDelegate
- (void)onChangeSubtitle:(NSInteger)subtitleId {
    @weakify(self);
    [self.manager switchSubtitle:subtitleId withBlock:^(BOOL result) {
        @strongify(self);
        if (result) {
            [self.scene refreshSubtitleButton:self.manager.currentSubtitleModel];
        }
    }];
}

#pragma mark - MDInterfaceDelegate
- (void)interfaceCallScreenRotation:(UIView *)interface {
    UIDeviceOrientation oriention = normalScreenBehaivor() ? UIDeviceOrientationLandscapeRight : UIDeviceOrientationPortrait;
    [self setDeviceInterfaceOrientation:oriention];
}

- (void)interfaceCallPageBack:(UIView *)interface {
    if (normalScreenBehaivor()) {
        [self closeViewControllerAnimated:YES];
        return;
    }
    if (self.landscapeMode) {
        [self closeViewControllerAnimated:NO];
        [self setDeviceInterfaceOrientation:UIInterfaceOrientationPortrait];
        return;
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
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            __block  BOOL includeCurrentView = NO;
            [videoList enumerateObjectsUsingBlock:^(MDSimpleEpisodeInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSInteger index = obj.order - 1;
                if ([obj.videoId isEqualToString:self.videoModel.videoId]) {
                    includeCurrentView = YES;
                }
                self.dramaVideoModels[index].playAuthToken = obj.playAuthToken;
                self.dramaVideoModels[index].vip = NO;
                self.dramaVideoModels[index].subtitleToken = obj.subtitleToken;
            }];
            [self updateVideoStrategySource:needPayArr];
            if (includeCurrentView) {
                [self updateCurrentVideo:self.videoModel];
            }
        });
    } failure:^(NSString * _Nonnull errMessage) {
        [[ToastComponent shareToastComponent] dismiss];
        [[ToastComponent shareToastComponent] showWithMessage:errMessage];
    }];

}
- (void)dismissPayviewController {
    if (self.payViewController) {
        [self.payViewController removeFromParentViewController];
        [self.payViewController.view removeFromSuperview];
        self.payViewController = nil;
    }
}

#pragma mark - MDPlayCorePipStatusDelegate
- (void)updatePipStatus:(BOOL)isPipOpen {
    self.isOpenPip = isPipOpen;
}

#pragma mark -MiniDramaPayViewControllerDelegate

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

- (void)onUnlockEpisode:(MiniDramaPayViewController *)vc count:(NSInteger)count {
    [self dismissPayviewController];
    if (count < 1) {
        return;
    }
    NSMutableArray <MDDramaEpisodeInfoModel *> *needLockArr = [[NSMutableArray alloc] init];
    [self.dramaVideoModels enumerateObjectsUsingBlock:^(MDDramaEpisodeInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.vip && obj.order >= self.videoModel.order) {
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

#pragma mark - MiniDramaSelectionViewControllerDelegate
- (void)onDramaSelectionCallback:(MDDramaEpisodeInfoModel *)dramaVideoInfo {
    if (dramaVideoInfo.vip) {
        [self onPlayNeedPayDramaVideo:dramaVideoInfo];
    }
    if (dramaVideoInfo.order == _videoModel.order) {
        return;
    }
    [self updateCurrentVideo:dramaVideoInfo];
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

#pragma mark----- UIViewController

- (BOOL)prefersHomeIndicatorAutoHidden {
    if (self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientationPortrait) {
            return NO;
        } else {
            return YES;
        }
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self updateUIToSize:size];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return 1;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.landscapeMode) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.landscapeMode) {
        return UIInterfaceOrientationLandscapeRight;
    }
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Getter

- (NSMutableArray<MDDramaEpisodeInfoModel *> *)dramaVideoModels {
    if (!_dramaVideoModels) {
        _dramaVideoModels = [[NSMutableArray alloc] init];
    }
    return _dramaVideoModels;
}

- (UIView *)playContainerView {
    if (!_playContainerView) {
        _playContainerView = [UIView new];
    }
    return _playContainerView;
}

- (MiniDramaPayViewController *)payViewController {
    if (_payViewController == nil) {
        _payViewController = [[MiniDramaPayViewController alloc] initWithlandscape:YES];
        _payViewController.delegate = self;
    }
    return _payViewController;
}

- (DramaSubtitleManage *)manager {
    if (!_manager) {
        _manager = [[DramaSubtitleManage alloc] init];
    }
    return _manager;
}
@end
