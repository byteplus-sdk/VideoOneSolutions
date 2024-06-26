// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEShortVideoCellController.h"
#import "UIViewController+Orientation.h"
#import "VEEventMessageBus.h"
#import "VEGradientView.h"
#import "VEInterfaceShortVideoSceneConf.h"
#import "VEInterfaceSocialStackView.h"
#import "VEPlayerKit.h"
#import "VEPlayerUIModule.h"
#import "VESettingManager.h"
#import "VEVideoDetailViewController.h"
#import "VEVideoModel.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ReportComponent.h>
#import <ToolKit/ToolKit.h>

@interface VEShortVideoMaskView : VEGradientView

typedef NS_ENUM(NSInteger, MaskViewType) {
    MaskViewTypeTop = 0,
    MaskViewTypeBottom,
};

@end

@implementation VEShortVideoMaskView

- (instancetype)initWithType:(MaskViewType)type {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
        if (type == MaskViewTypeBottom) {
            UIColor *startColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.0 * 255];
            UIColor *middleColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.3 * 255];
            UIColor *endColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.5 * 255];
            self.gradientLayer.colors = @[(id)startColor.CGColor, (id)middleColor.CGColor, (id)endColor.CGColor];
            self.gradientLayer.startPoint = CGPointMake(0.5, 0);
            self.gradientLayer.endPoint = CGPointMake(0.5, 1.0);
        } else {
            UIColor *startColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.3 * 255];
            UIColor *middleColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.1157 * 255];
            UIColor *endColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0 * 255];
            self.gradientLayer.colors = @[(id)startColor.CGColor, (id)middleColor.CGColor, (id)endColor.CGColor];
            self.gradientLayer.startPoint = CGPointMake(0.5, 0);
            self.gradientLayer.endPoint = CGPointMake(0.5, 1.0);
        }
    }
    return self;
}

@end

@interface VEShortVideoCellController () <VEInterfaceDelegate, VEVideoDetailProtocol>

@property (nonatomic, strong) VEVideoPlayerController *playerController;
@property (nonatomic, strong) VEInterface *playerControlInterface;
@property (nonatomic, strong) VEShortVideoMaskView *topMaskView;
@property (nonatomic, strong) VEShortVideoMaskView *bottomMaskView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) BaseButton *fullScreenButton;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) VEInterfaceSocialStackView *socialView;
@property (nonatomic, assign) VEVideoPlayerType currentType;
@property (nonatomic, assign) BOOL isReturnPortrait;
@end

@implementation VEShortVideoCellController

@synthesize reuseIdentifier;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isReturnPortrait = NO;
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)removeFromParentViewController {
    [super removeFromParentViewController];
    [self playerStop];
}

#pragma mark - Publish Action

- (void)setVideoModel:(VEVideoModel *)videoModel {
    _videoModel = videoModel;
    BOOL isHorizontalScreen = ([videoModel.width floatValue] / [videoModel.height floatValue] > 1) ? YES : NO;
    VEVideoPlayerType type = isHorizontalScreen ? VEVideoPlayerTypeShortHorizontalScreen : VEVideoPlayerTypeShortVerticalScreen;
    self.currentType = type;
    self.titleLabel.text = [NSString stringWithFormat:@"@%@", videoModel.userName];
    self.subtitleLabel.text = videoModel.title;
    self.avatar.image = [UIImage avatarImageForUid:videoModel.uid];
    self.socialView.videoModel = videoModel;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [ReportComponent report:self.videoModel.videoId cancelHandler:nil completion:nil];
    }
}

#pragma mark----- Life Circle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self playerCover];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isReturnPortrait = NO;
    [self playerStop];
}

#pragma mark----- Play

- (void)playerCover {
    [self createPlayer:self.currentType];
    [self createPlayerControl];
    [self.playerController loadBackgourdImageWithMediaSource:[VEVideoModel videoEngineVidSource:self.videoModel]];
}

- (void)playerStart {
    if (self.playerController.isPlaying) {
        return;
    }
    if (self.playerController.isPause) {
        if (!self.isReturnPortrait) {
            [self.playerController play];
        }
        return;
    }
    [self createPlayer:self.currentType];
    [self createPlayerControl];
    [self playerOptions];
    if (self.videoModel.playUrl.length) {
        [self.playerController setMediaSource:[VEVideoModel videoEngineUrlSource:self.videoModel]];
    } else if (self.videoModel.videoId.length) {
        [self.playerController setMediaSource:[VEVideoModel videoEngineVidSource:self.videoModel]];
    }
    [self.playerController setLooping:YES];
    [self.playerController play];
}

- (void)playerStop {
    @autoreleasepool {
        [self.playerControlInterface destory];
        self.playerControlInterface = nil;
        [self.playerController stop];
        [self.playerController.view removeFromSuperview];
        [self.playerController removeFromParentViewController];
        self.playerController = nil;
    }
}

#pragma mark - VEPageItem

- (void)prepareToPlay {
    [self playerCover];
}

- (void)play {
    [self playerStart];
}

- (void)pause {
    [self.playerController pause];
}

- (void)stop {
    [self playerStop];
}

- (void)setVisible:(BOOL)visible {
    self.playerControlInterface.scene.deactive = !visible;
    if (visible) {
        [self playerCover];
        [self playerStart];
    } else {
        self.isReturnPortrait = NO;
        [self.playerController pause];
    }
}

#pragma mark----- Player

- (void)createPlayer:(VEVideoPlayerType)playerType {
    if (!self.playerController) {
        self.playerController = [[VEVideoPlayerController alloc] initWithType:playerType];
    }
    [self addChildViewController:self.playerController];
    [self.view addSubview:self.playerController.view];
    [self.view bringSubviewToFront:self.playerController.view];
    if (playerType == VEVideoPlayerTypeShortHorizontalScreen) {
        CGFloat videoModelWidth = MAX([self.videoModel.width floatValue], 1);
        CGFloat width = MAX(self.view.frame.size.width, 1);
        CGFloat height = width * [self.videoModel.height floatValue] / videoModelWidth;
        [self.playerController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(height));
            make.leading.trailing.equalTo(self.view);
            make.center.equalTo(self.view);
        }];
        self.fullScreenButton.hidden = NO;
    } else {
        [self.playerController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        self.fullScreenButton.hidden = YES;
    }
}

- (void)createPlayerControl {
    if (!self.playerControlInterface) {
        self.playerControlInterface = [[VEInterface alloc] initWithPlayerCore:self.playerController scene:[VEInterfaceShortVideoSceneConf new]];
        self.socialView.eventMessageBus = self.playerControlInterface.eventMessageBus;
    }
    self.playerControlInterface.delegate = self;
    [self.view addSubview:self.playerControlInterface];
    [self.playerControlInterface mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.playerControlInterface addSubview:self.topMaskView];
    [self.playerControlInterface sendSubviewToBack:self.topMaskView];
    [self.topMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.playerControlInterface);
        make.height.mas_equalTo(200);
    }];

    [self.playerControlInterface addSubview:self.bottomMaskView];
    [self.playerControlInterface sendSubviewToBack:self.bottomMaskView];
    [self.bottomMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.playerControlInterface);
        make.height.mas_equalTo(200);
    }];

    [self.playerControlInterface addSubview:self.subtitleLabel];
    [self.subtitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.bottom.mas_equalTo(-12);
        make.width.mas_equalTo(SCREEN_WIDTH * 0.73);
    }];

    [self.playerControlInterface addSubview:self.titleLabel];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.bottom.equalTo(self.subtitleLabel.mas_top).offset(-6);
        make.width.equalTo(self.subtitleLabel);
    }];

    [self.playerControlInterface addSubview:self.fullScreenButton];
    [self.fullScreenButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(self.playerController.view.mas_bottom).offset(12);
        make.width.equalTo(@98);
        make.height.equalTo(@32);
    }];

    [self.playerControlInterface addSubview:self.socialView];
    [self.socialView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.playerControlInterface).offset(-13);
        make.bottom.equalTo(self.playerControlInterface).offset(-24);
    }];

    [self.playerControlInterface addSubview:self.avatar];
    [self.avatar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(48);
        make.centerX.equalTo(self.socialView);
        make.bottom.equalTo(self.socialView.mas_top).offset(-14);
    }];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.playerControlInterface addGestureRecognizer:longPress];
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

#pragma mark----- VEInterfaceDelegate

- (void)interfaceShouldEnableSlide:(BOOL)enable {
    if ([self.delegate respondsToSelector:@selector(shortVideoController:shouldLockVerticalScroll:)]) {
        [self.delegate shortVideoController:self shouldLockVerticalScroll:enable];
    }
}

#pragma mark - Button Touch Action

- (void)fullScreenButtonAction {
    if ([self willPlayCurrentSource:self.videoModel]) {
        [self.playerControlInterface removeFromSuperview];
        [self.playerControlInterface destory];
        self.playerControlInterface = nil;
    }
    VEVideoDetailViewController *detailViewController = [[VEVideoDetailViewController alloc] initWithType:self.currentType];
    detailViewController.delegate = self;
    detailViewController.landscapeMode = YES;
    detailViewController.videoModel = self.videoModel;
    [self.navigationController pushViewController:detailViewController animated:NO];
    __weak __typeof(self) wself = self;
    detailViewController.closeCallback = ^(BOOL landscapeMode, VEVideoPlayerController *playerController) {
        wself.playerController = playerController;
        wself.isReturnPortrait = YES;
        [wself.socialView reloadData];
    };
}

#pragma mark----- VEVideoDetailProtocol

- (VEVideoPlayerController *)currentPlayerController:(VEVideoModel *)videoModel {
    if ([self willPlayCurrentSource:videoModel]) {
        VEVideoPlayerController *c = self.playerController;
        self.playerController = nil;
        return c;
    } else {
        return nil;
    }
}

- (BOOL)willPlayCurrentSource:(VEVideoModel *)videoModel {
    NSString *currentVid = @"";
    if (self.playerController && [self.playerController.mediaSource isKindOfClass:[TTVideoEngineVidSource class]]) {
        currentVid = [self.playerController.mediaSource performSelector:@selector(vid)];
    }
    if ([currentVid isEqualToString:videoModel.videoId]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.tag = 3001;
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.tag = 3002;
        _subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _subtitleLabel.textColor = [UIColor whiteColor];
        _subtitleLabel.numberOfLines = 2;
    }
    return _subtitleLabel;
}

- (VEShortVideoMaskView *)topMaskView {
    if (!_topMaskView) {
        _topMaskView = [[VEShortVideoMaskView alloc] initWithType:MaskViewTypeTop];
    }
    return _topMaskView;
}

- (VEShortVideoMaskView *)bottomMaskView {
    if (!_bottomMaskView) {
        _bottomMaskView = [[VEShortVideoMaskView alloc] initWithType:MaskViewTypeBottom];
    }
    return _bottomMaskView;
}

- (BaseButton *)fullScreenButton {
    if (!_fullScreenButton) {
        _fullScreenButton = [[BaseButton alloc] init];
        _fullScreenButton.backgroundColor = [UIColor colorFromRGBHexString:@"#292929" andAlpha:0.34 * 255];
        _fullScreenButton.layer.borderColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.2 * 255].CGColor;
        _fullScreenButton.layer.borderWidth = 1;
        _fullScreenButton.layer.cornerRadius = 4;
        _fullScreenButton.layer.masksToBounds = YES;
        _fullScreenButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_fullScreenButton addTarget:self action:@selector(fullScreenButtonAction) forControlEvents:UIControlEventTouchUpInside];

        UIImage *image = [UIImage imageNamed:@"vod_shortvideo_fullscreen"];
        NSString *title = LocalizedStringFromBundle(@"shortvideo_fullscreen", @"VEVodApp");
        CGFloat spacing = 4;
        [_fullScreenButton setImage:image forState:UIControlStateNormal];
        [_fullScreenButton setTitle:title forState:UIControlStateNormal];
        [_fullScreenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _fullScreenButton.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing / 2, 0, spacing / 2);
        _fullScreenButton.titleEdgeInsets = UIEdgeInsetsMake(0, spacing / 2, 0, -spacing / 2);
        _fullScreenButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _fullScreenButton.hidden = YES;
    }
    return _fullScreenButton;
}

- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [UIImageView new];
        _avatar.clipsToBounds = YES;
        _avatar.layer.borderColor = [UIColor whiteColor].CGColor;
        _avatar.layer.borderWidth = 2;
        _avatar.layer.cornerRadius = 24;
    }
    return _avatar;
}

- (VEInterfaceSocialStackView *)socialView {
    if (!_socialView) {
        _socialView = [VEInterfaceSocialStackView new];
        _socialView.axis = UILayoutConstraintAxisVertical;
    }
    return _socialView;
}

- (void)dealloc {
    VOLogI(VOVideoPlayback,@"deallocdeallocdealloc");
}

@end
