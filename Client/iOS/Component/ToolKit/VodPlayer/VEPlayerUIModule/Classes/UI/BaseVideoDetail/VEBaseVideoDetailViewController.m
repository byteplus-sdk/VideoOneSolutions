//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "FullScreenVideoGestureGuide.h"
#import "VEBaseVideoDetailViewController+Private.h"
#import "VEEventMessageBus.h"
#import "VEVideoCache.h"
#import <ToolKit/ToolKit.h>

@implementation VEBaseVideoDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.videoPlayerType = VEVideoPlayerTypeFeed;
    }
    return self;
}

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
    [self updateUIToSize:self.view.bounds.size];
    [self preparePIP:nil];
    if (self.landscapeMode) {
        [self setDeviceInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.playerControlView.eventPoster cancelPreparePIP];
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

- (void)layoutUI {
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationItem.title = @"";
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.playContainerView];
    [self.playContainerView.contentView addSubview:self.playerController.view];
    [self.playContainerView addSubview:self.playerControlView];
    [self.playContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.leading.trailing.equalTo(self.view);
    }];
    [self.playerController.view mas_remakeConstraints:^(MASConstraintMaker *make) { // need remake
        make.edges.equalTo(self.playContainerView.contentView);
    }];
    [self.playerControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playContainerView);
    }];
    if (!self.landscapeMode) {
        [self.view addSubview:self.videoInfoView];
        [self.videoInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(12);
            make.trailing.equalTo(self.view).offset(-12);
            make.top.equalTo(self.playContainerView.mas_bottom).offset(20);
        }];
    }
}

- (void)updateUIToSize:(CGSize)size {
    BOOL isPortrait = size.height > size.width;
    self.navigationController.interactivePopGestureRecognizer.enabled = isPortrait;
    CGFloat screenRate = isPortrait ? (9.0 / 16.0) : (size.height / size.width);
    CGFloat height = size.width * (screenRate);
    [self.playContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(height));
    }];
    self.prefersHomeIndicatorAutoHidden = !isPortrait;
    [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    if (!isPortrait) {
        [FullScreenVideoGestureGuide addGuideIfNeed:self.view];
    }
}

- (void)setVideoModel:(BaseVideoModel *)videoModel {
    _videoModel = videoModel;
    if (self.isViewLoaded) {
        [self.sceneConf.eventPoster cancelPreparePIP];
        [self.sceneConf.eventPoster updatePIPPlayUrl:nil];
        self.sceneConf.videoModel = videoModel;
        [self reloadPlayerController];
        [_videoInfoView updateModel:videoModel];
        [self preparePIP:nil];
    }
}

- (void)reloadPlayerController {
    VEVideoPlayerController *mayPlayer = [self.delegate currentPlayerController:self.videoModel];
    if ([mayPlayer isKindOfClass:[VEVideoPlayerController class]]) {
        [mayPlayer.view removeFromSuperview];
        [mayPlayer removeFromParentViewController];
        [self addChildViewController:mayPlayer];
        self.playerController = mayPlayer;
        self.playerController.delegate = self;
        self.playerController.playerTitle = self.videoModel.title;
        [self playerOptionsAfterSetMediaSource];
    } else {
        [self playerOptionsBeforeSetMediaSource];
        if (self.videoModel.playUrl) {
            [self.playerController setMediaSource:[BaseVideoModel videoEngineUrlSource:self.videoModel]];
        } else if (self.videoModel.videoId) {
            [self.playerController setMediaSource:[BaseVideoModel videoEngineVidSource:self.videoModel]];
        }
        self.playerController.playerTitle = self.videoModel.title;
        [self playerOptionsAfterSetMediaSource];
        [self.playerController play];
    }
}

- (void)playerOptionsBeforeSetMediaSource {
}

- (void)playerOptionsAfterSetMediaSource {
}

- (void)closeViewControllerAnimated:(BOOL)animated {
    if (self.closeCallback) {
        self.playerController.delegate = nil;
        self.closeCallback(self.landscapeMode, self.playerController);
        self.closeCallback = nil;
    }
    [self.navigationController popViewControllerAnimated:animated];
}

#pragma mark - PIP

- (void)preparePIP:(TTVideoEngineModel *)videoModel {
    if (self.sceneConf.skipPIPMode) {
        return;
    }
    if (!videoModel) {
        videoModel = [[VEVideoCache shared] videoForKey:self.videoModel.videoId];
    }
    if (!videoModel) {
        return;
    }
    NSString *playUrlString = [[[videoModel videoInfo] videoInfoForType:TTVideoEngineResolutionTypeSD] getValueStr:VALUE_MAIN_URL];
    [self.playerControlView.eventPoster updatePIPPlayUrl:playUrlString];
}

#pragma mark - Getter

+ (Class)playerContainerClass {
    return [VEPlayerContainer class];
}

- (VEPlayerContainer *)playContainerView {
    if (!_playContainerView) {
        _playContainerView = [self.class.playerContainerClass new];
    }
    return _playContainerView;
}

- (VEInterface *)playerControlView {
    if (!_playerControlView) {
        self.sceneConf = [self interfaceScene];
        self.sceneConf.videoModel = self.videoModel;
        if (self.videoPlayerType & VEVideoPlayerTypeShort) {
            self.sceneConf.skipPlayMode = YES;
            self.sceneConf.skipPIPMode = YES;
        }
        _playerControlView = [[VEInterface alloc] initWithPlayerCore:[self playerCore]
                                                               scene:self.sceneConf];
        _playerControlView.delegate = self;
    }
    return _playerControlView;
}

- (VEVideoPlayerController *)playerController {
    if (!_playerController) {
        _playerController = [[VEVideoPlayerController alloc] initWithType:self.videoPlayerType];
        _playerController.delegate = self;
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

- (id<VEPlayCoreAbilityProtocol>)playerCore {
    return self.playerController;
}

- (VEInterfaceBaseVideoDetailSceneConf *)interfaceScene {
    return [VEInterfaceBaseVideoDetailSceneConf new];
}

#pragma mark----- VEVideoPlaybackDelegate

- (void)videoPlayer:(id<VEVideoPlayback>)player fetchedVideoModel:(TTVideoEngineModel *_Nonnull)videoModel {
    [self preparePIP:videoModel];
}

#pragma mark----- VEInterfaceDelegate

- (void)interfaceCallScreenRotation:(UIView *)interface {
    VOLogD(VOToolKit, @"interfaceCallScreenRotation");
    UIInterfaceOrientation oriention = normalScreenBehaivor() ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
    [self setDeviceInterfaceOrientation:oriention];
}

- (void)interfaceCallPageBack:(UIView *)interface {
    VOLogD(VOToolKit, @"interfaceCallPageBack");
    if (normalScreenBehaivor()) {
        [self closeViewControllerAnimated:YES];
        return;
    }
    if (self.landscapeMode) {
        [self closeViewControllerAnimated:NO];
        [self setDeviceInterfaceOrientation:UIInterfaceOrientationPortrait];
        return;
    }
    [self.playerControlView.eventMessageBus postEvent:VEUIEventScreenRotation withObject:nil rightNow:YES];
}

#pragma mark----- UIViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self updateUIToSize:size];
}

@end
