//
//  MiniDramaVideoCellController.m
//  VOLCDemo
//

#import "MiniDramaVideoCellController.h"
#import "MDDramaFeedInfo.h"
#import "MDDramaEpisodeInfoModel.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>
#import <ToolKit/DeviceInforTool.h>
#import "MDPlayerKit.h"
#import "MiniDramaRecommodPlayerModuleLoader.h"
#import "MiniDramaRecommendViewList.h"
#import "MDPlayerContextKeyDefine.h"
#import "BTDMacros.h"
#import "MiniDramaSeriesView.h"
#import "MiniDramaIntroduceView.h"
#import "MiniDramaHotVideoCard.h"
#import "MiniDramaRecommendView.h"
#import "MiniDramaSocialView.h"
#import "MiniDramaLandscapeViewController.h"
#import "MDVideoPlayerController+DisRecordScreen.h"

@interface MiniDramaVideoCellController () <MDVideoPlaybackDelegate,
MiniDramaSeriesViewDelegate,
MiniDramaHotVideoCardDelegate,
MiniDramaRecommendViewDelegate,
MiniDramaRecommendViewListDelegate,
MiniDramaLandscapeViewProtocol
>

@property (nonatomic, strong, readwrite) MDDramaFeedInfo *dramaVideoInfo;
@property (nonatomic, strong) MDVideoPlayerController *playerController;
@property (nonatomic, strong) MiniDramaRecommodPlayerModuleLoader *moduleLoader;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) BaseButton *fullScreenButton;
@property (nonatomic, assign) MDVideoPlayerType currentType;
@property (nonatomic, strong) MiniDramaSeriesView *seriesView;
@property (nonatomic, strong) MiniDramaIntroduceView *introduceView;
@property (nonatomic, strong) MiniDramaHotVideoCard *cardView;
@property (nonatomic, strong) MiniDramaRecommendView *recommendView;
@property (nonatomic, strong) MiniDramaSocialView *socialView;

@end

@implementation MiniDramaVideoCellController

@synthesize reuseIdentifier;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self configuratoinCustomView];
}

#pragma mark - MiniDramaPageItem protocol

- (void)partiallyShow {
    [self loadPlayerCover];
}

- (void)completelyShow {
    [self playerStart];
}

- (void)endShow {
    [self.playerController stop];
}

- (void)itemDidRemoved {
    [self playerStop];
}

- (void)pageViewControllerVisible:(BOOL)visible {
    if (visible) {
        [self playerResume];
    }
}

- (void)dealloc
{
    [self playerStop];
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.avatar];
    [self.avatar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(48);
        make.right.equalTo(self.view).offset(-5);
        make.bottom.equalTo(self.view).offset(-210);
    }];
    
    [self.view addSubview:self.seriesView];
    [self.view addSubview:self.introduceView];
    [self.view addSubview:self.cardView];
    [self.introduceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(16);
        make.right.equalTo(self.view).with.offset(-90);
        make.bottom.equalTo(self.view).with.offset(-(MiniDramaRecommendViewHeight + 16));
        make.height.mas_equalTo(MiniDramaIntroduceViewHeight);
    }];
    [self.seriesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.introduceView.mas_top).with.offset(-12);
        make.left.equalTo(self.view).with.offset(16);
        make.right.mas_lessThanOrEqualTo(self.introduceView);
        make.height.mas_greaterThanOrEqualTo(MiniDramaSeriesViewHeight);
    }];
    
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(16);
        make.bottom.equalTo(self.view).offset(-54);
        make.width.mas_equalTo(275);
    }];
    
    [self.view addSubview:self.recommendView];
    [self.recommendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(MiniDramaRecommendViewHeight);
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-10);
    }];
    
    [self.view addSubview:self.socialView];
    [self.socialView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-6);
        make.bottom.equalTo(self.view).offset(-54);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:self.view];
    if (self.socialView) {
        [self.socialView handleDoubleClick:touchPoint];
    }
}

#pragma mark - Public

- (void)reloadData:(MDDramaFeedInfo *)dramaVideoInfo {
    self.dramaVideoInfo = dramaVideoInfo;
    BOOL isHorizontalScreen = ([dramaVideoInfo.videoInfo.videoWidth floatValue] / [dramaVideoInfo.videoInfo.videoHeight floatValue] > 1) ? YES : NO;
    self.currentType = isHorizontalScreen ? MDVideoPlayerTypeShortHorizontalScreen :
    MDVideoPlayerTypeShortVerticalScreen;
    self.avatar.image = [UIImage avatarImageForUid:dramaVideoInfo.videoInfo.authorId];
    [self.seriesView reloadData:dramaVideoInfo];
    [self.introduceView reloadData:dramaVideoInfo];
    [self.cardView reloadData:dramaVideoInfo];
    if (dramaVideoInfo.videoInfo.displayType == MDDisplayCardTypeDefault) {
        self.cardView.hidden = YES;
        self.seriesView.hidden = NO;
        self.introduceView.hidden = NO;
    } else {
        self.cardView.hidden = NO;
        self.seriesView.hidden = YES;
        self.introduceView.hidden = YES;
    }
    [self.recommendView reloadData:dramaVideoInfo];
    [self.socialView setVideoModel:dramaVideoInfo.videoInfo];
}

#pragma mark ----- Play

- (void)loadPlayerCover {
    [self createPlayer];
    self.playerController.videoViewMode = MDVideoViewModeAspectFill;
    [self.playerController loadBackgourdImageWithMediaSource:[MDDramaEpisodeInfoModel videoEngineVidSource:self.dramaVideoInfo.videoInfo]];
}

- (void)playerStart {
    if (self.playerController.isPlaying){
        return;
    }
    [self createPlayer];
    [self.playerController registerScreenCapturedDidChangeNotification];
    [self.playerController playWithMediaSource:[MDDramaEpisodeInfoModel videoEngineVidSource:self.dramaVideoInfo.videoInfo]];
    if (self.dramaVideoInfo.videoInfo.startTime > 0) {
        self.playerController.startTime = self.dramaVideoInfo.videoInfo.startTime;
        self.dramaVideoInfo.videoInfo.startTime = 0;
    }
    [self.playerController  setLooping:YES];
}

- (void)playerPause {
    [self.playerController unregisterScreenCaptureDidChangeNotification];
    [self.playerController pause];
    [self.playerController.view removeFromSuperview];
    [self.playerController removeFromParentViewController];
    self.playerController = nil;
    _moduleLoader = nil;
}

- (void)playerResume {
    [self.playerController registerScreenCapturedDidChangeNotification];;
    if (self.playerController) {
        [self.playerController play];
    } else {
        [self completelyShow];
    }
}

- (void)playerStop {
    if (self.playerController) {
        [self.playerController stop];
        [self.playerController.view removeFromSuperview];
        [self.playerController removeFromParentViewController];
        self.playerController = nil;
        _moduleLoader = nil;
    }
}


- (void)setModuleLoader:(MiniDramaRecommodPlayerModuleLoader *)moduleLoader {
    _moduleLoader = moduleLoader;
    @weakify(self);
    [moduleLoader.context addKey:MDPlayerContextKeyPlayButtonDoubleTap withObserver:self handler:^(id  _Nullable object, NSString * _Nullable key){
        @strongify(self);
        [self.socialView handleDoubleClick:[object CGPointValue] inView:self.playerController.view];
    }];
}

- (void)createPlayer {
    if (self.playerController == nil) {
        MiniDramaRecommodPlayerModuleLoader *_tempModule = [[MiniDramaRecommodPlayerModuleLoader alloc] init];
        
        MDVideoPlayerConfiguration *playerConfig = [MDVideoPlayerConfiguration defaultPlayerConfiguration];
        self.playerController = [[MDVideoPlayerController alloc] initWithConfiguration:playerConfig moduleLoader:_tempModule playerContainerView:self.view];
        self.playerController.delegate = self;
        self.playerController.videoViewMode = MDVideoViewModeAspectFill;
        [self.view insertSubview:self.playerController.view atIndex:0];
        if (self.currentType == MDVideoPlayerTypeShortHorizontalScreen) {
            CGFloat videoModelWidth = MAX([self.dramaVideoInfo.videoInfo.videoWidth floatValue], 1);
            CGFloat width = MAX(self.view.frame.size.width, 1);
            CGFloat height = width * [self.dramaVideoInfo.videoInfo.videoHeight floatValue] / videoModelWidth;
            [self.playerController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(height));
                make.leading.trailing.equalTo(self.view);
                make.center.equalTo(self.view);
            }];
            UIView *view = [self.playerController.view viewWithTag:11111];
            if (view) {
                [view removeFromSuperview];
                [self.view addSubview:view];
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.left.right.equalTo(self.view);
                    make.height.mas_equalTo(10);
                }];
            }
            self.fullScreenButton.hidden = NO;
        } else {
            [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            self.fullScreenButton.hidden = YES;
        }
        
        [self.view addSubview:self.fullScreenButton];
        [self.fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(@0);
            make.top.equalTo(self.playerController.view.mas_bottom).offset(12);
            make.width.equalTo(@98);
            make.height.equalTo(@32);
        }];
        [self playerOptions];
        self.moduleLoader = _tempModule;
    }
    [self.moduleLoader.context post:self.dramaVideoInfo forKey:MDPlayerContextKeyMiniDramaDataModelChanged];
}

- (void)playerOptions {
    self.playerController.preRenderOpen = YES;
    self.playerController.preloadOpen = YES;
}

#pragma mark - fullScreenButtonAction
- (void)fullScreenButtonAction {
    [MDVideoPlayerController clearAllEngineStrategy];
    [self playerPause];
    MiniDramaLandscapeViewController *detailViewController = [[MiniDramaLandscapeViewController alloc]
                                                              initWithVideoInfo:self.dramaVideoInfo];
    detailViewController.delegate = self;
    detailViewController.landscapeMode = YES;
    [self.navigationController pushViewController:detailViewController animated:NO];
    @weakify(self);
    detailViewController.closeCallback = ^(BOOL landscapeMode, MDVideoPlayerController * _Nonnull playerController) {
//        VOLogI(VOMiniDrama, @"closeCallback");
//        self.isReturnPortrait = YES;
//        self.playerController = playerController;
//        [self.view insertSubview:self.playerController.view atIndex:0];
//        CGFloat videoModelWidth = MAX([self.dramaVideoInfo.videoWidth floatValue], 1);
//        CGFloat width = MAX(self.view.frame.size.width, 1);
//        CGFloat height = width * [self.dramaVideoInfo.videoHeight floatValue] / videoModelWidth;
//        [self.playerController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.height.equalTo(@(height));
//            make.leading.trailing.equalTo(self.view);
//            make.center.equalTo(self.view);
//        }];
//        [self.fullScreenButton mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(@0);
//            make.top.equalTo(self.playerController.view.mas_bottom).offset(12);
//            make.width.equalTo(@98);
//            make.height.equalTo(@32);
//        }];
    };
}

- (BOOL)willPlayCurrentSource:(MiniDramaBaseVideoModel *)videoModel {
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

#pragma mark - MiniDramaLandscapeViewProtocol
- (MDVideoPlayerController *)currentPlayerController:(MiniDramaBaseVideoModel *)videoModel {
    if ([self willPlayCurrentSource:(MiniDramaBaseVideoModel *)videoModel]) {
        MDVideoPlayerController *c = self.playerController;
        self.playerController = nil;
        return c;
    } else {
        return nil;
    }
}

#pragma mark - MiniDramaSeriesViewDelegate
- (void)onClickSeriesViewCallback {
    BOOL isHorizontalScreen = ([self.dramaVideoInfo.videoInfo.videoWidth floatValue] / [self.dramaVideoInfo.videoInfo.videoHeight floatValue] > 1) ? YES : NO;
    if (isHorizontalScreen) {
        [self fullScreenButtonAction];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(dramaVideoWatchDetail:)]) {
            [self.delegate dramaVideoWatchDetail:self.dramaVideoInfo];
        }
    }
}

#pragma mark - MiniDramaHotVideoCardDelegate
- (void)onClickCardPlayButton {
    BOOL isHorizontalScreen = ([self.dramaVideoInfo.videoInfo.videoWidth floatValue] / [self.dramaVideoInfo.videoInfo.videoHeight floatValue] > 1) ? YES : NO;
    if (isHorizontalScreen) {
        [self fullScreenButtonAction];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(dramaVideoWatchDetail:)]) {
            [self.delegate dramaVideoWatchDetail:self.dramaVideoInfo];
        }
    }
}

- (void)onClickCloseCard {
    self.cardView.hidden = YES;
    self.seriesView.hidden = NO;
    self.introduceView.hidden = NO;
}

#pragma mark - MiniDramaRecommendViewDelegate
- (void)onShowRecommentList {
    MiniDramaRecommendViewList *listView = [[MiniDramaRecommendViewList alloc] init];
    listView.delegate = self;
    [listView showInView:[DeviceInforTool topViewController].view];
}

#pragma mark -MiniDramaRecommendViewListDelegate
- (void)onClickRecommendVideoCallback:(MDDramaFeedInfo *)videoModel {
    BOOL isHorizontalScreen = ([videoModel.videoInfo.videoWidth floatValue] / [videoModel.videoInfo.videoHeight floatValue] > 1) ? YES : NO;
    if (isHorizontalScreen) {
        [MDVideoPlayerController clearAllEngineStrategy];
        [self playerPause];
        MiniDramaLandscapeViewController *detailViewController = [[MiniDramaLandscapeViewController alloc]
                                                                  initWithVideoInfo:videoModel];
        detailViewController.delegate = self;
        detailViewController.landscapeMode = YES;
        [self.navigationController pushViewController:detailViewController animated:NO];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(dramaVideoWatchDetail:)]) {
            [self.delegate dramaVideoWatchDetail:videoModel];
        }
    }
}

#pragma mark - MDVideoPlaybackDelegate

- (void)videoPlayer:(id<MDVideoPlayback> _Nullable)player playbackStateDidChange:(MDVideoPlaybackState)state {
    
}

- (void)videoPlayer:(id<MDVideoPlayback> _Nullable)player didFinishedWithStatus:(MDPlayFinishStatus *_Nullable)finishStatus {
    if (finishStatus.error) {
        BTDLog(@"paly error %@", finishStatus.error);
    } else {
        if (finishStatus.finishState == MDVideoPlayFinishStatusType_SystemFinish) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onDramaDetailVideoPlayFinish:)]) {
                [self.delegate onDramaDetailVideoPlayFinish:self.dramaVideoInfo];
            }
        }
    }
}

#pragma mark - Getter
- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [UIImageView new];
        _avatar.clipsToBounds = YES;
        _avatar.layer.borderColor = [UIColor whiteColor].CGColor;
        _avatar.layer.borderWidth = 2;
        _avatar.layer.cornerRadius = 24;
        _avatar.userInteractionEnabled = NO;
    }
    return _avatar;
}

- (MiniDramaSeriesView *)seriesView {
    if (_seriesView == nil) {
        _seriesView = [[MiniDramaSeriesView alloc] init];
        _seriesView.delegate = self;
    }
    return _seriesView;
}

- (MiniDramaIntroduceView *)introduceView {
    if (_introduceView == nil) {
        _introduceView = [[MiniDramaIntroduceView alloc] init];
    }
    return _introduceView;
}

- (MiniDramaHotVideoCard *)cardView {
    if (!_cardView) {
        _cardView = [[MiniDramaHotVideoCard alloc] init];
        _cardView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.2 * 255];
        _cardView.layer.cornerRadius = 12;
        _cardView.layer.masksToBounds = YES;
        _cardView.delegate = self;
    }
    return _cardView;
}

- (MiniDramaRecommendView *)recommendView {
    if (!_recommendView) {
        _recommendView  = [[MiniDramaRecommendView alloc] init];
        _recommendView.delegate = self;
    }
    return _recommendView;
}

- (MiniDramaSocialView *)socialView {
    if (!_socialView) {
        _socialView = [MiniDramaSocialView new];
        _socialView.axis = UILayoutConstraintAxisVertical;
        _socialView.userInteractionEnabled = YES;
    }
    return _socialView;
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
@end
