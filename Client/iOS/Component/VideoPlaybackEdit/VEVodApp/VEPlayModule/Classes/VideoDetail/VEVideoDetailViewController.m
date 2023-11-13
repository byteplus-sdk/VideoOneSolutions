// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoDetailViewController.h"
#import "VEVideoModel.h"
#import "VESettingManager.h"
#import "VEPlayerUIModule.h"
#import "VEInterfaceSimpleBlockSceneConf.h"
#import "VEPlayerKit.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIViewController+Orientation.h>
#import <ToolKit/UIColor+String.h>
#import "VEEventMessageBus.h"

@interface VEVideoDetailViewController () <VEInterfaceDelegate>

@property (nonatomic, strong) VEVideoPlayerController *playerController; // player Container

@property (nonatomic, strong) VEInterface *playerControlView; // player Control view

@property (nonatomic, strong) UIView *playContainerView; // playerView & playerControlView Container

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, assign) VEVideoPlayerType videoPlayerType;

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
    [self.playerControlView destory];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationItem.title = @"";
    [self.view addSubview:self.playContainerView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.infoLabel];
    [self.playContainerView addSubview:self.playerController.view];
    [self.playContainerView addSubview:self.playerControlView];
    [self layoutUI];
    [self addObserver];
    [self.playerControlView.eventMessageBus registEvent:VEUIEventClearScreen withAction:@selector(clearScreenAction:) ofTarget:self];
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
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    if (!parent) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.playerControlView destory];
    }
}

- (void)layoutUI {
    CGFloat screenRate = (self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientationPortrait) ? (3.0 / 4.0) : (UIScreen.mainScreen.bounds.size.height / UIScreen.mainScreen.bounds.size.width);
    CGFloat height = UIScreen.mainScreen.bounds.size.width * (screenRate);
    CGFloat top = (self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientationPortrait) ? UIApplication.sharedApplication.statusBarFrame.size.height : 0.0;
    
    [self.playContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(top);
        make.leading.trailing.equalTo(self.view);
        make.height.equalTo(@(height));
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.playContainerView.mas_bottom).offset(20);
        make.left.mas_equalTo(self.view).offset(12);
        make.right.mas_equalTo(self.view).offset(-12);
    }];
        
    [self.infoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.left.right.mas_equalTo(self.titleLabel);
    }];
    
    [self.playerController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playContainerView);
    }];
    [self.playerControlView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playContainerView);
    }];
}

- (void)clearScreenAction:(id)param {
    self.titleLabel.hidden = self.playerControlView.eventPoster.screenIsClear;
    self.infoLabel.hidden = self.playerControlView.eventPoster.screenIsClear;
}

- (void)setVideoModel:(VEVideoModel *)videoModel {
    _videoModel = videoModel;
    self.playerController.playerTitle = videoModel.title;
    self.titleLabel.text = videoModel.title;
    self.infoLabel.text = [NSString stringWithFormat:@"%@ · %@",[videoModel playTimeToString], videoModel.createTime];
    VEVideoPlayerController *mayPlayer = [self.delegate currentPlayerController:videoModel];
    if ([mayPlayer isKindOfClass:[VEVideoPlayerController class]]) {
        self.playerController = mayPlayer;
        [self.playerController play];
    } else {
        TTVideoEngineVidSource *vidSource = [VEVideoModel videoEngineVidSource:videoModel];
        [self playerOptions];
        [self.playerController playWithMediaSource:vidSource];
        [self.playerController play];
    }
}

- (UIView *)playContainerView {
    if (!_playContainerView) {
        _playContainerView = [UIView new];
    }
    return _playContainerView;
}

- (VEInterface *)playerControlView {
    if (!_playerControlView) {
        VEInterfaceSimpleBlockSceneConf *scene = [VEInterfaceSimpleBlockSceneConf new];
        scene.videoModel = self.videoModel;
        _playerControlView = [[VEInterface alloc] initWithPlayerCore:self.playerController scene:scene];
        _playerControlView.delegate = self;
    }
    return _playerControlView;
}

- (VEVideoPlayerController *)playerController {
    if (!_playerController) {
        _playerController = [[VEVideoPlayerController alloc] initWithType:self.videoPlayerType];
    }
    return _playerController;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:18 weight:bold];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _infoLabel.textColor = [UIColor colorFromRGBHexString:@"#73767A"];
        _infoLabel.numberOfLines = 0;
    }
    return _infoLabel;
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


#pragma mark ----- VEInterfaceDelegate

- (void)interfaceCallScreenRotation:(UIView *)interface {
    UIDeviceOrientation oriention = ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) ? UIDeviceOrientationLandscapeLeft : UIDeviceOrientationPortrait;
    [self setDeviceInterfaceOrientation:oriention];
}


#pragma mark ----- UIInterfaceOrientation

- (void)screenOrientationChanged:(NSNotification *)notification {
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeRight: {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
            break;
        case UIInterfaceOrientationPortrait:
        default: {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
            break;
    }
    if (@available(iOS 11.0, *)) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
    [self layoutUI];
    [self.view setNeedsLayout];
}

- (void)interfaceCallPageBack:(UIView *)interface {
    switch (self.preferredInterfaceOrientationForPresentation) {
        case UIInterfaceOrientationLandscapeRight: {
            [self interfaceCallScreenRotation:nil];
        }
            break;
        case UIInterfaceOrientationPortrait:
        default: {
            [self close];
        }
            break;
    }
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    if (self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientationPortrait) {
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return 1;
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
