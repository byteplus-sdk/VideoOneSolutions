//
//  MDPlayerLoadingModule.m
//  MDPlayerKit
//

#import "MDPlayerLoadingModule.h"
#import "MDPlayerActionViewInterface.h"
#import "MDPlayerContext.h"
#import "MDPlayerContextKeyDefine.h"
#import "MDLPlayerLoadingView.h"
#import "MDPlayerUtility.h"
#import "MDPlayFinishStatus.h"
#import <Reachability/Reachability.h>
#import "MDPlayerGestureServiceInterface.h"
#import "MDVideoPlayback.h"
#import "BTDMacros.h"


@interface MDPlayerLoadingModule () <MDPlayerLoadingViewDataSource>

@property (nonatomic, strong, readwrite) UIView<MDPlayerLoadingViewProtocol> *loadingView;

@property (nonatomic, weak) id<MDVideoPlayback> playerInterface;

@property (nonatomic, weak) id<MDPlayerActionViewInterface> actionViewService;

@property (nonatomic, weak) id<MDPlayerGestureServiceInterface> gestureService;

@property (nonatomic, assign) BOOL userPlayAction;

@property (nonatomic, assign) BOOL userSeeking;

@property (nonatomic, assign) BOOL isLoading; // 播放器是否处于loading状态

@property (nonatomic, strong) Class<MDPlayerLoadingViewProtocol> noNetworTipClass;

@property(nonatomic, strong) id<MDPlayerGestureHandlerProtocol> disableAllGestureHandler;

@end

@implementation MDPlayerLoadingModule

MDPlayerContextDILink(actionViewService, MDPlayerActionViewInterface, self.context)
MDPlayerContextDILink(playerInterface, MDVideoPlayback, self.context)
MDPlayerContextDILink(gestureService, MDPlayerGestureServiceInterface, self.context);

#pragma mark - Life Cycle
- (void)moduleDidLoad {
    [super moduleDidLoad];
    
    @weakify(self);
    [self.context addKeys:@[MDPlayerContextKeyPlayAction, MDPlayerContextKeyPauseAction] withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        self.userPlayAction = [key isEqualToString:MDPlayerContextKeyPlayAction] && object;
        [self updateLoadingState];
    }];
    
    [self.context addKey:MDPlayerContextKeyPlaybackDidFinish withObserver:self handler:^(MDPlayFinishStatus *finishStatus, NSString *key) {
        @strongify(self);
        if (finishStatus) {
            if (![finishStatus error] || !self.playerInterface.looping) {
                self.userPlayAction = NO;
            }
            [self updateLoadingState];
        }
    }];
    
    [self.context addKeys:@[MDPlayerContextKeySliderSeekBegin, MDPlayerContextKeySliderSeekEnd] withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        self.userSeeking = [key isEqualToString:MDPlayerContextKeySliderSeekBegin];
        [self updateLoadingState];
    }];
    
    [self.context addKeys:@[MDPlayerContextKeyLoadState, MDPlayerContextKeyPlaybackState] withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        [self updateLoadingState];
    }];
    
    [self.context addKeys:@[MDPlayerContextKeyShowLoadingNetWorkSpeed, MDPlayerContextKeyRotateScreen] withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        [self updateLoadingView];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateLoadingState];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
}

#pragma mark - Private Mehtod
- (void)updateLoadingView {
    BOOL isFullScreen = [[self.context objectForHandlerKey:MDPlayerContextKeyRotateScreen] isFullScreen];
    self.loadingView.isFullScreen = isFullScreen;
    self.loadingView.showNetSpeedTip = [self.context boolForHandlerKey:MDPlayerContextKeyShowLoadingNetWorkSpeed];
    self.loadingView.dataSource = self;
}

- (void)updateLoadingState {
    if (self.userSeeking) {
        [self showLoading:NO];
    } else {
        //如果播放器复用 && 使用closeAycn context中的loadstate没有被重置，直接从播放器取更准确
        MDVideoLoadState loadState = self.playerInterface.loadState;
        MDVideoPlaybackState playbackState = (MDVideoPlaybackState)[self.context integerForHandlerKey:MDPlayerContextKeyPlaybackState];
        BOOL isPlaying = (playbackState == TTVideoEnginePlaybackStatePlaying);
        BOOL isStartPlaying = (playbackState == TTVideoEnginePlaybackStateStopped && self.userPlayAction); // 正在启动播放
        BOOL showLoading = (isPlaying || isStartPlaying) && (loadState != MDVideoLoadStatePlayable);
        [self showLoading:showLoading];
    }
}

#pragma mark - TTVPlayerLoadingInterface
- (void)showLoading:(BOOL)show {
    if (self.isLoading == show) {
        return;
    }
    self.isLoading = show;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performShowLoadingView) object:nil];
    if (show) {
        // 对齐原逻辑：延迟1s显示loading视图，避免启播时闪一下loading视图
        [self performSelector:@selector(performShowLoadingView) withObject:nil afterDelay:1];
        
    } else {
        // 将播放器停止loading状态分发出去
        [self.context post:nil forKey:MDPlayerContextKeyFinishLoading];
        
        if (!self.isViewLoaded) {
            return;
        }
        [self.loadingView stopLoading];
    }
}

- (void)performShowLoadingView {
    // 将播放器开始loading状态分发出去
    [self.context post:nil forKey:MDPlayerContextKeyStartLoading];
    
    if (!self.isViewLoaded) {
        return;
    }
    if (!self.loadingView) {
        self.loadingView = [self createLoadingView];
    }
    if (!self.loadingView) {
        return;
    }
    [self.actionViewService.overlayControlView addSubview:self.loadingView];
    [self.loadingView startLoading];
}

#pragma mark - getter & setter

- (UIView<MDPlayerLoadingViewProtocol> *)createLoadingView {
    MDLPlayerLoadingView *loadingView = [[MDLPlayerLoadingView alloc] init];
    loadingView.isFullScreen = [[self.context objectForHandlerKey:MDPlayerContextKeyRotateScreen] isFullScreen];
    loadingView.showNetSpeedTip = [self.context boolForHandlerKey:MDPlayerContextKeyShowLoadingNetWorkSpeed];
    loadingView.dataSource = self;
    return loadingView;
}

#pragma mark - MDPlayerLoadingViewDataSource

- (NSString *)netWorkSpeedInfo {
    return [MDPlayerUtility netWorkSpeedStringWithKBPerSeconds:self.playerInterface.netWorkSpeed];
}

- (void)addNetworkReachabilityChangedNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkReachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}
 
- (void)removeNetworkReachabilityChangedNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)networkReachabilityChanged:(NSNotification *)notification {
    if ([[Reachability reachabilityForInternetConnection] isReachable]) {
        if (self.playerInterface.playbackState == MDVideoPlaybackStatePaused) {
            [self.playerInterface play];
        }
    }
}

@end
