//
//  MiniDramaDetailVideoCellController.m
//  MDPlayModule
//

#import "MiniDramaDetailVideoCellController.h"
#import "MiniDramaDetailFeedViewController.h"
#import "MDDramaEpisodeInfoModel.h"
#import <Masonry/Masonry.h>
#import "MDPlayerKit.h"
#import "MiniDramaDetailPlayerModuleLoader.h"
#import "MDPlayerContextKeyDefine.h"
#import "MDPlayerUtility.h"
#import <ToolKit/ToolKit.h>
#import "BTDMacros.h"
#import "MiniDramaSocialView.h"
#import "MiniDramaLandscapeViewController.h"
#import "MDVideoPlayerController+DisRecordScreen.h"


static NSInteger MiniDramaDetailVideoCellBottomOffset = 0;

@interface MiniDramaDetailVideoCellController () 
<MDVideoPlaybackDelegate>

@property (nonatomic, strong, readwrite) MDDramaEpisodeInfoModel *dramaVideoInfo;
@property (nonatomic, strong) MiniDramaDetailPlayerModuleLoader *moduleLoader;
@property (nonatomic, strong) MDVideoPlayerController *playerController;
@property (nonatomic, strong) MiniDramaSocialView *socialView;
@end

@implementation MiniDramaDetailVideoCellController

@synthesize reuseIdentifier;

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (void)resetAdjacentCell {
    [self.playerController stop];
}

- (void)pageViewControllerDealloc {
    VOLogI(VOMiniDrama, @"pageViewControllerDealloc");
    [self playerStop];
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.socialView];
    [self.socialView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-6);
        make.bottom.equalTo(self.view).offset(-54);
    }];
}

#pragma mark - Public

- (void)updateForUnlock {
    [self playerStart];
}

- (void)reloadData:(MDDramaEpisodeInfoModel *)dramaVideoInfo {
    self.dramaVideoInfo = dramaVideoInfo;
    [self.socialView setVideoModel:dramaVideoInfo];
}

- (void)updatePlaybackSeed:(CGFloat)speed {
    CGFloat value = speed;
    if (speed > 3) {
        value = 3;
    } else if (speed <= 0) {
        value = 1;
    }
    self.playerController.playbackRate = value;
}

- (void)setModuleLoader:(MiniDramaDetailPlayerModuleLoader *)moduleLoader {
    _moduleLoader = moduleLoader;
    @weakify(self);
    [moduleLoader.context addKey:MDPlayerContextKeyPlayButtonSingleTap withObserver:self handler:^(id  _Nullable object, NSString * _Nullable key) {
        @strongify(self);
        if (self.dramaVideoInfo && self.dramaVideoInfo.vip) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayNeedPayDramaVideo:)]) {
                [self.delegate onPlayNeedPayDramaVideo:self.dramaVideoInfo];
            }
        }
    }];
    [moduleLoader.context addKey:MDPlayerContextKeyPlayButtonDoubleTap withObserver:self handler:^(id  _Nullable object, NSString * _Nullable key){
        @strongify(self);
        [self.socialView handleDoubleClick:[object CGPointValue]];
    }];
}

#pragma mark ----- Play
- (void)createPlayer {
    if (self.playerController == nil) {
        MiniDramaDetailPlayerModuleLoader *_tempModule = [[MiniDramaDetailPlayerModuleLoader alloc] init];
        MDVideoPlayerConfiguration *playerConfig = [MDVideoPlayerConfiguration defaultPlayerConfiguration];
        self.playerController = [[MDVideoPlayerController alloc] initWithConfiguration:playerConfig moduleLoader:_tempModule playerContainerView:self.view];
        self.playerController.delegate = self;
        [self.view insertSubview:self.playerController.view atIndex:0];
        [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).with.offset(-MiniDramaDetailVideoCellBottomOffset);
        }];
        [self playerOptions];
        self.moduleLoader = _tempModule;
    }
    
    [self.moduleLoader.context post:self.dramaVideoInfo forKey:MDPlayerContextKeyMiniDramaDataModelChanged];
}

- (void)loadPlayerCover {
    [self createPlayer];
    self.playerController.videoViewMode = MDVideoViewModeAspectFill;
    [self.playerController loadBackgourdImageWithMediaSource:[MDDramaEpisodeInfoModel videoEngineVidSource:self.dramaVideoInfo]];
}

- (void)playerStart {
    if (self.playerController.isPlaying){
        return;
    }
    if (self.playerController.isPause) {
        [self.playerController play];
        return;
    }
    [self createPlayer];
    if (self.dramaVideoInfo.vip == NO) {
        [self.playerController registerScreenCapturedDidChangeNotification];
        [self.playerController playWithMediaSource:[MDDramaEpisodeInfoModel videoEngineVidSource:self.dramaVideoInfo]];
        if (self.delegate && [self.delegate respondsToSelector:@selector(onCurrentPlaybackSpeed:)]) {
            [self.delegate onCurrentPlaybackSpeed:self.playerController.playbackRate];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayNeedPayDramaVideo:)]) {
            [self.delegate onPlayNeedPayDramaVideo:self.dramaVideoInfo];
        }
    }
    self.playerController.videoViewMode = MDVideoViewModeAspectFill;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDramaDetailVideoPlayStart:)]) {
        [self.delegate onDramaDetailVideoPlayStart:self.dramaVideoInfo];
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

- (void)playerOptions {
    self.playerController.preRenderOpen = YES;
    self.playerController.preloadOpen = YES;
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


#pragma mark - MDVideoPlaybackDelegate
- (void)videoPlayer:(id<MDVideoPlayback> _Nullable)player playbackStateDidChange:(MDVideoPlaybackState)state {
    VOLogI(VOMiniDrama, @"playbackStateDidChange %@ %@", @(state), @(self.dramaVideoInfo.order));
}

- (void)videoPlayer:(id<MDVideoPlayback> _Nullable)player didFinishedWithStatus:(MDPlayFinishStatus *_Nullable)finishStatus {
    if (finishStatus.error) {
        VOLogE(VOMiniDrama, @"play error::%@", finishStatus.error);
    } else {
        VOLogE(VOMiniDrama, @"finishStatus: %@", @(finishStatus.finishState));
    }
}
#pragma mark -Getter
- (MiniDramaSocialView *)socialView {
    if (!_socialView) {
        _socialView = [MiniDramaSocialView new];
        _socialView.axis = UILayoutConstraintAxisVertical;
        _socialView.userInteractionEnabled = YES;
    }
    return _socialView;
}
@end
