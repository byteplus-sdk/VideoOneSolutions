//
//  TTVideoCellController.m
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/5.
//

#import "TTVideoCellController.h"
#import "VEPlayerUIModule.h"
#import "VEInterfaceSocialStackView.h"
#import "VEBaseVideoDetailViewController.h"
#import "VEGradientView.h"
#import "VEPlayerKit.h"
#import "TTMixModel.h"
#import "TTVideoModel.h"
#import "TTInterfaceVideoSceneConf.h"
#import "TTAvatarView.h"
#import "TTLivePlayerManager.h"
#import "LiveFeedViewController.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>
#import <ToolKit/VEInterfaceFactory.h>
#import <ToolKit/ReportComponent.h>

#pragma mark -- class:TTVideoMaskView

@interface TTVideoMaskView : VEGradientView

typedef NS_ENUM(NSInteger, VideoMaskViewType) {
    VideoMaskViewTypeTop = 0,
    VideoMaskViewTypeBottom,
};

@end

@implementation TTVideoMaskView

- (instancetype)initWithType:(VideoMaskViewType)type {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
        if (type == VideoMaskViewTypeBottom) {
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


#pragma mark -- class:TTVideoCellController
@interface TTVideoCellController ()<VEInterfaceDelegate, VEVideoDetailProtocol>

@property (nonatomic, strong) VEVideoPlayerController *playerController;
@property (nonatomic, strong) VEInterface *playerControlInterface;
@property (nonatomic, strong) TTVideoMaskView *topMaskView;
@property (nonatomic, strong) TTVideoMaskView *bottomMaskView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) BaseButton *fullScreenButton;
@property (nonatomic, strong) TTAvatarView *avatarView;
@property (nonatomic, strong) VEInterfaceSocialStackView *socialView;
@property (nonatomic, assign) VEVideoPlayerType currentType;
@property (nonatomic, assign) BOOL isReturnPortrait;

@end

@implementation TTVideoCellController

@synthesize reuseIdentifier;

#pragma mark -- system method override

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isReturnPortrait = NO;
    self.view.backgroundColor = [UIColor blackColor];
}

#pragma mark -- private method
- (void)playerCover {
    [self createPlayer:self.currentType];
    [self createPlayerControl];
    [self.playerController loadBackgourdImageWithMediaSource:[TTVideoModel videoEngineVidSource:self.mixModel.videoModel]];
}

- (void)playerStart {
    if (self.playerController.isPlaying) {
        return;
    }
    if (self.playerController.isPause) {
        if (!self.isReturnPortrait) {
            [self.playerController play];
        } else {
            UIView *playButton = [self.playerControlInterface viewWithTag:VEInterfaceButtonTag];
            if (playButton) {
                playButton.hidden = NO;
            }
        }
        return;
    }
    [self createPlayer:self.currentType];
    [self createPlayerControl];
    [self.playerController setMediaSource:[TTVideoModel videoEngineVidSource:self.mixModel.videoModel]];

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
- (void)createPlayer:(VEVideoPlayerType)playerType {
    if (!self.playerController) {
        self.playerController = [[VEVideoPlayerController alloc] initWithType:playerType];
    }
    self.playerController.preRenderOpen = YES;
    self.playerController.preloadOpen = YES;
    [self addChildViewController:self.playerController];
    [self.view addSubview:self.playerController.view];
    [self.view bringSubviewToFront:self.playerController.view];
    if (playerType == VEVideoPlayerTypeShortHorizontalScreen) {
        CGFloat videoModelWidth = MAX([self.mixModel.videoModel.width floatValue], 1);
        CGFloat width = MAX(self.view.frame.size.width, 1);
        CGFloat height = width * [self.mixModel.videoModel.height floatValue] / videoModelWidth;
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
        self.playerControlInterface = [[VEInterface alloc]
                                       initWithPlayerCore:self.playerController
                                       scene:[TTInterfaceVideoSceneConf new]];
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
        make.bottom.mas_equalTo(-([DeviceInforTool getSafeAreaInsets].bottom + 46));
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
        make.bottom.equalTo(self.playerControlInterface).offset(-([DeviceInforTool getSafeAreaInsets].bottom + 70));
    }];

    [self.playerControlInterface addSubview:self.avatarView];
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(60);
        make.centerX.equalTo(self.socialView);
        make.bottom.equalTo(self.socialView.mas_top).offset(-14);
    }];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.playerControlInterface addGestureRecognizer:longPress];
}
- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [ReportComponent report:self.mixModel.videoModel.videoId cancelHandler:nil completion:nil];
    }
}

- (void)fullScreenButtonAction {
    if ([self willPlayCurrentSource:self.mixModel.videoModel]) {
        [self.playerControlInterface removeFromSuperview];
        [self.playerControlInterface destory];
        self.playerControlInterface = nil;
    }
    VEBaseVideoDetailViewController *detailViewController = [[VEBaseVideoDetailViewController alloc] initWithType:self.currentType];
    detailViewController.delegate = self;
    detailViewController.landscapeMode = YES;
    detailViewController.videoModel = self.mixModel.videoModel;
    self.playerController.posterImageView.hidden = YES;
    [self.navigationController pushViewController:detailViewController animated:NO];
    __weak __typeof(self) wself = self;
    detailViewController.closeCallback = ^(BOOL landscapeMode, VEVideoPlayerController *playerController) {
        wself.playerController = playerController;
        wself.playerController.posterImageView.hidden = NO;
        wself.isReturnPortrait = YES;
        [wself.socialView reloadData];
    };
}

- (BOOL)willPlayCurrentSource:(TTVideoModel *)videoModel {
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
#pragma mark - VEPageItem protocol

- (void)itemDidLoad {
    
}

- (void)itemDidRemoved {
    [self playerStop];
}

- (void)partiallyShow {
    [self playerCover];
    UIView *progressView = [self.playerControlInterface viewWithTag:VEInterfaceProgressViewTag];
    if (progressView) {
        progressView.hidden = YES;
    }
}

- (void)completelyShow {
    [self playerStart];
}

- (void)endShow {
    self.isReturnPortrait = NO;
    [self.playerController stop];
    UIView *progressView = [self.playerControlInterface viewWithTag:VEInterfaceProgressViewTag];
    if (progressView) {
        progressView.hidden = YES;
    }
}

- (void)pageViewControllerDealloc {
    [self playerStop];
}

- (void)pageViewControllerVisible:(BOOL)visible {
    self.playerControlInterface.scene.deactive = !visible;
    if (visible) {
        [[TTLivePlayerManager sharedLiveManager] recoveryAllPlayerWithException:nil];
        [self playerCover];
        [self playerStart];
        self.avatarView.userInteractionEnabled = self.avatarView.active;
    } else {
        self.isReturnPortrait = NO;
        [self.playerController pause];
    }
}

#pragma mark -- getter&setter
- (void)setMixModel:(TTMixModel *)mixModel {
    _mixModel = mixModel;
    TTVideoModel *videoModel = mixModel.videoModel;
    BOOL isHorizontalScreen = ([videoModel.width floatValue] / [videoModel.height floatValue] > 1) ? YES : NO;
    VEVideoPlayerType type = isHorizontalScreen ? VEVideoPlayerTypeShortHorizontalScreen : VEVideoPlayerTypeShortVerticalScreen;
    self.currentType = type;
    self.titleLabel.text = [NSString stringWithFormat:@"@%@", videoModel.userName];
    self.subtitleLabel.text = videoModel.title;
    __weak __typeof(self) weakSelf = self;
    self.avatarView.didClickBlock = ^{
        [[TTLivePlayerManager sharedLiveManager] recoveryAllPlayerWithException:nil];
        LiveFeedViewController *liveFeedVC = [[LiveFeedViewController alloc] initWithLiveModel:mixModel.liveModel];
        [weakSelf.navigationController pushViewController:liveFeedVC animated:NO];
    };
    self.avatarView.avatarImage = [UIImage avatarImageForUid:videoModel.uid];
    self.avatarView.active = mixModel.userStatus  == TTUsesrStatusLiving;
    self.socialView.videoModel = videoModel;
}

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
        _subtitleLabel.tag = VEInterfaceSubtitleTag;
        _subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _subtitleLabel.textColor = [UIColor whiteColor];
        _subtitleLabel.numberOfLines = 2;
    }
    return _subtitleLabel;
}

- (TTVideoMaskView *)topMaskView {
    if (!_topMaskView) {
        _topMaskView = [[TTVideoMaskView alloc] initWithType:VideoMaskViewTypeTop];
    }
    return _topMaskView;
}

- (TTVideoMaskView *)bottomMaskView {
    if (!_bottomMaskView) {
        _bottomMaskView = [[TTVideoMaskView alloc] initWithType:VideoMaskViewTypeBottom];
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

        UIImage *image = [UIImage imageNamed:@"vod_shortvideo_fullscreen" bundleName:@"VodPlayer"];
        NSString *title = LocalizedStringFromBundle(@"shortvideo_fullscreen", @"VodPlayer");
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

- (TTAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[TTAvatarView alloc] init];
    }
    return _avatarView;
}

- (VEInterfaceSocialStackView *)socialView {
    if (!_socialView) {
        _socialView = [VEInterfaceSocialStackView new];
        _socialView.axis = UILayoutConstraintAxisVertical;
    }
    return _socialView;
}

- (void)dealloc {
    VOLogI(VOTTProto,@"dealloc");
}


#pragma mark----- VEInterfaceDelegate

- (void)interfaceShouldEnableSlide:(BOOL)enable {
    if ([self.delegate respondsToSelector:@selector(TTVideoController:shouldLockVerticalScroll:)]) {
        [self.delegate TTVideoController:self shouldLockVerticalScroll:enable];
    }
}

- (NSInteger)interfaceBottomHeightForSubtitle {
    return [DeviceInforTool getSafeAreaInsets].bottom + 46;
}

#pragma mark----- VEVideoDetailProtocol
- (VEVideoPlayerController *)currentPlayerController:(BaseVideoModel *)videoModel {
    if ([self willPlayCurrentSource:(TTVideoModel *)videoModel]) {
        VEVideoPlayerController *c = self.playerController;
        self.playerController = nil;
        return c;
    } else {
        return nil;
    }
}

@end
