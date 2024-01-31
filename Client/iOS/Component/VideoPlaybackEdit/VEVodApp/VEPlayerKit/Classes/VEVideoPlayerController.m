// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoPlayerController.h"
#import "VEDataPersistance.h"
#import "VEVideoPlayerController+DebugTool.h"
#import "VEVideoPlayerController+Observer.h"
#import "VEVideoPlayerController+Options.h"
#import "VEVideoPlayerController+Resolution.h"
#import "VEVideoPlayerController+Strategy.h"
#import "VEVideoPlayerController+VEPlayCoreAbility.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import <ToolKit/ToolKit.h>

@interface VEVideoPlayerController () <
    TTVideoEngineDelegate,
    TTVideoEngineDataSource,
    TTVideoEngineResolutionDelegate>

@property (nonatomic, strong) TTVideoEngine *videoEngine;

@property (nonatomic, strong) id<TTVideoEngineMediaSource> mediaSource;

@property (nonatomic, strong) UIImageView *posterImageView;
@property (nonatomic, strong) UIView *playerPanelContainerView;

@property (nonatomic, assign) VEPlaybackState playbackState;
@property (nonatomic, assign) VEPlaybackLoadState loadState;
@property (nonatomic, assign) VEVideoPlayerType videoPlayerType;

@end

@implementation VEVideoPlayerController

@synthesize delegate;
@synthesize playerTitle;
@synthesize duration;
@synthesize currentPlaybackTime;
@synthesize playableDuration;
@synthesize startTime;

@dynamic playbackRate;
@dynamic playbackVolume;
@dynamic muted;
@dynamic audioMode;

- (instancetype)initWithType:(VEVideoPlayerType)videoPlayerType {
    self = [super init];
    if (self) {
        self.videoPlayerType = videoPlayerType;
    }
    return self;
}

- (void)dealloc {
    [self removeObserver];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configuratoinCustomView];
}

- (void)configVideoEngine {
    if (_videoEngine == nil) {
        TTVideoEngine *engine = [[TTVideoEngine alloc] initWithOwnPlayer:YES];
        self.videoEngine = engine;
    }
    /*
     We need to change audioSession category to playBack before using video Engine, or the video will be silent.
     */
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    /*
     set audioDevice value as audioGraph so that we can manually change volume capability from videoEngine.
     */
    [self.videoEngine setOptionForKey:VEKKeyPlayerAudioDevice_ENUM value:@(TTVideoEngineDeviceAudioGraph)];
    self.videoEngine.delegate = self;
    self.videoEngine.resolutionDelegate = self;
    self.videoEngine.reportLogEnable = YES;
    self.videoEngine.dataSource = self;
    if (self.videoPlayerType == VEVideoPlayerTypeFeed) {
        self.videoEngine.looping = NO;
    } else {
        self.videoEngine.looping = [VEDataPersistance boolValueFor:VEDataCacheKeyPlayLoop defaultValue:YES];
    }
    [self.videoEngine configResolution:[VEVideoPlayerController getPlayerCurrentResolution]];
    if (@available(iOS 14.0, *)) {
        [self.videoEngine setSupportPictureInPictureMode:YES];
    }
    self.videoEngine.playerView.backgroundColor = [UIColor clearColor];
    /// add observer
    [self addObserver];

    /// config video engine option
    if (self.videoPlayerType & VEVideoPlayerTypeShort) {
        [self openVideoEngineShortDefaultOptions];
    } else {
        [self openVideoEngineFeedDefaultOptions];
    }
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor blackColor];

    [self.view addSubview:self.posterImageView];
    [self.posterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.view addSubview:self.playerPanelContainerView];
    [self.playerPanelContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)reLayoutVideoPlayerView {
    if ([self.videoEngine.playerView superview] == nil || [self.videoEngine.playerView superview] != self.view) {
        [self.view insertSubview:self.videoEngine.playerView aboveSubview:self.posterImageView];
        [self.videoEngine.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

#pragma mark - Pirvate

- (void)__setBackgroudImageForMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    /// player is running, reture
    if ([self isPlaying] && [self isPause]) {
        return;
    }
    if (self.preRenderOpen) {
        TTVideoEngine *preRenderVideoEngine = [TTVideoEngine getPreRenderFinishedVideoEngineWithVideoSource:mediaSource];
        if (preRenderVideoEngine) {
            preRenderVideoEngine.playerView.hidden = NO;
            preRenderVideoEngine.playerView.backgroundColor = [UIColor clearColor];
            self.posterImageView.hidden = YES;
            [self.view insertSubview:preRenderVideoEngine.playerView aboveSubview:self.posterImageView];
            [preRenderVideoEngine.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            NSLog(@"EngineStrategy: ===== backgroud image use pre render video engine view");
            return;
        }
    }

    self.posterImageView.hidden = NO;
    [self.posterImageView sd_setImageWithURL:[NSURL URLWithString:[self __getBackgroudImageUrl:mediaSource]] completed:nil];
}

- (NSString *)__getBackgroudImageUrl:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    NSString *url = [(NSObject *)mediaSource valueForKey:@"cover"];
    return url ?: @"";
}

- (void)__closeVideoPlayer {
    [self.videoEngine.playerView removeFromSuperview];
    [self.videoEngineDebugTool remove];
    [self.videoEngine closeAysnc];
    [self.videoEngine removeTimeObserver];
    self.videoEngine = nil;
}

- (void)__addPeriodicTimeObserver {
    @weakify(self);
    [self.videoEngine addPeriodicTimeObserverForInterval:0.3f queue:dispatch_get_main_queue() usingBlock:^{
        if ([weak_self.receiver respondsToSelector:@selector(playerCore:playTimeDidChanged:info:)]) {
            [weak_self.receiver playerCore:weak_self playTimeDidChanged:weak_self.currentPlaybackTime info:@{}];
        }
    }];
}

#pragma mark - Player control

- (void)resetVideoEngine:(TTVideoEngine *_Nonnull)videoEngine mediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    _mediaSource = mediaSource;
    self.videoEngine = nil;
    self.videoEngine = videoEngine;
    [self configVideoEngine];
    [self loadStrategyVideoModel];
}

- (void)setMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    if (self.preRenderOpen) {
        TTVideoEngine *preRenderVideoEngine = [TTVideoEngine getPreRenderVideoEngineWithVideoSource:mediaSource];
        if (preRenderVideoEngine) {
            [self resetVideoEngine:preRenderVideoEngine mediaSource:mediaSource];
            NSLog(@"EngineStrategy: ===== use pre render video engine play");
            [[BaseLoadingView sharedInstance] startLoadingIn:self.playerPanelContainerView];
            return;
        }
    }
    _mediaSource = mediaSource;
    [self configVideoEngine];
    [self.videoEngine setVideoEngineVideoSource:mediaSource];
    [self loadStrategyVideoModel];
    [[BaseLoadingView sharedInstance] startLoadingIn:self.playerPanelContainerView];
}

- (void)loadBackgourdImageWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    [self __setBackgroudImageForMediaSource:mediaSource];
}

- (void)playWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    [self setMediaSource:mediaSource];
    [self play];
}

- (void)prepareToPlay {
    [self.videoEngine prepareToPlay];
}

- (void)play {
    if (self.startTime > 0) {
        [self.videoEngine setOptionForKey:VEKKeyPlayerStartTime_CGFloat value:@(self.startTime)];
        self.startTime = 0;
    } else {
        [self.videoEngine setOptionForKey:VEKKeyPlayerStartTime_CGFloat value:@(0)];
    }
    [self.videoEngine play];
    [self reLayoutVideoPlayerView];
    [self __addPeriodicTimeObserver];
}

- (void)pause {
    [self.videoEngine pause];
}

- (void)seekToTime:(NSTimeInterval)time
          complete:(void (^_Nullable)(BOOL success))finised
    renderComplete:(void (^_Nullable)(void))renderComplete {
    [self.videoEngine setCurrentPlaybackTime:time complete:finised renderComplete:renderComplete];
}

- (void)stop {
    [self.videoEngine stop];
    [self __closeVideoPlayer];
}

- (void)close {
    [self.videoEngine closeAysnc];
}

- (BOOL)isPlaying {
    return (self.playbackState == VEPlaybackStatePlaying);
}

- (BOOL)isPause {
    return (self.playbackState == VEPlaybackStatePaused);
}

- (NSTimeInterval)duration {
    return self.videoEngine.duration;
}

- (NSTimeInterval)currentPlaybackTime {
    return self.videoEngine.currentPlaybackTime;
}

- (NSTimeInterval)playableDuration {
    return self.videoEngine.playableDuration;
}

- (void)setPlaybackRate:(CGFloat)playbackRate {
    self.videoEngine.playbackSpeed = playbackRate;
}

- (CGFloat)playbackRate {
    return self.videoEngine.playbackSpeed;
}

- (void)setPlaybackVolume:(CGFloat)playbackVolume {
    self.videoEngine.volume = playbackVolume;
}

- (CGFloat)playbackVolume {
    return self.videoEngine.volume;
}

- (void)setMuted:(BOOL)muted {
    [self.videoEngine setMuted:muted];
}

- (BOOL)muted {
    return self.videoEngine.muted;
}

- (void)setAudioMode:(BOOL)audioMode {
    self.videoEngine.radioMode = audioMode;
}

- (BOOL)audioMode {
    return self.videoEngine.radioMode;
}

#pragma mark - TTVideoEngineDelegate

- (void)videoEngine:(TTVideoEngine *)videoEngine retryForError:(NSError *)error {
    NSLog(@"retryForError %@", error);
}

- (void)videoEnginePrepared:(TTVideoEngine *)videoEngine {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerPrepared:)]) {
        [self.delegate videoPlayerPrepared:self];
    }
    if ([self.receiver respondsToSelector:@selector(playerCore:resolutionChanged:info:)]) {
        [self.receiver playerCore:self resolutionChanged:self.currentResolution info:@{}];
    }
}

- (void)videoEngineReadyToDisPlay:(TTVideoEngine *)videoEngine {
    [[BaseLoadingView sharedInstance] stopLoading];
    self.videoEngine.playerView.hidden = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerReadyToDisplay:)]) {
        [self.delegate videoPlayerReadyToDisplay:self];
    }
}

- (void)videoEngineReadyToPlay:(TTVideoEngine *)videoEngine {
    if ([self.receiver respondsToSelector:@selector(playerCoreReadyToPlay:)]) {
        [self.receiver playerCoreReadyToPlay:self];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine playbackStateDidChanged:(TTVideoEnginePlaybackState)playbackState {
    if (playbackState == TTVideoEnginePlaybackStatePaused) {
        [[BaseLoadingView sharedInstance] stopLoading];
    }
    [self __handlePlaybackStateChanged:[self __getPlaybackState:playbackState]];
}

- (void)videoEngine:(TTVideoEngine *)videoEngine loadStateDidChanged:(TTVideoEngineLoadState)loadState {
    [self __handleLoadStateChanged:[self __getLoadState:loadState]];
}

- (void)videoEngine:(TTVideoEngine *)videoEngine loadStateDidChanged:(TTVideoEngineLoadState)loadState extra:(nullable NSDictionary<NSString *, id> *)extraInfo {
    [self __handleLoadStateChanged:[self __getLoadState:loadState]];
}

- (void)videoEngine:(TTVideoEngine *)videoEngine fetchedVideoModel:(TTVideoEngineModel *)videoModel {
    [VEVideoPlayerController addStrategyVideoModel:videoModel forSource:self.mediaSource];

    if ([self.delegate respondsToSelector:@selector(videoPlayer:fetchedVideoModel:)]) {
        [self.delegate videoPlayer:self fetchedVideoModel:videoModel];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine mdlKey:(NSString *)key hitCacheSze:(NSInteger)cacheSize {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:key:hitVideoPreloadDataSize:)]) {
        [self.delegate videoPlayer:self key:key hitVideoPreloadDataSize:cacheSize];
    }
    NSLog(@"EngineStrategy: ===== hitCacheSze %@, vid = %@", @(cacheSize), [self.mediaSource getUniqueId]);
}

- (void)videoEngineUserStopped:(TTVideoEngine *)videoEngine {
    [self __handlePlaybackStateChanged:VEPlaybackStateFinishedBecauseUser];
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine error:(nullable NSError *)error {
    if (error) {
        NSLog(@"videoEngineDidFinish with error : %@", [error description]);
        [self __handlePlaybackStateChanged:VEPlaybackStateError];
        return;
    }
    [self __handlePlaybackStateChanged:VEPlaybackStateFinished];
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine videoStatusException:(NSInteger)status {
    NSLog(@"videoEngineDidFinish with exception : %lu", status);
    [self __handlePlaybackStateChanged:VEPlaybackStateError];
}

- (void)videoEngineCloseAysncFinish:(TTVideoEngine *)videoEngine {
    [self __handlePlaybackStateChanged:VEPlaybackStateFinished];
}

- (void)videoBitrateDidChange:(TTVideoEngine *)videoEngine resolution:(TTVideoEngineResolutionType)resolution bitrate:(NSInteger)bitrate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerBitrateDidChange:resolution:bitrate:)]) {
        [self.delegate videoPlayerBitrateDidChange:self resolution:resolution bitrate:bitrate];
    }
    // VEUIModule
    if ([self.receiver respondsToSelector:@selector(playerCore:resolutionChanged:info:)]) {
        [self.receiver playerCore:self resolutionChanged:self.currentResolution info:@{}];
    }
}

- (void)videoSizeDidChange:(TTVideoEngine *)videoEngine videoWidth:(NSInteger)videoWidth videoHeight:(NSInteger)videoHeight {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerViewSizeDidChange:videoWidth:videoHeight:)]) {
        [self.delegate videoPlayerViewSizeDidChange:self videoWidth:videoWidth videoHeight:videoHeight];
    }
}

#pragma mark - Private

- (void)__handlePlaybackStateChanged:(VEPlaybackState)state {
    self.playbackState = state;
    switch (state) {
        case VEPlaybackStatePlaying: {
            self.videoEngine.playerView.hidden = NO;
        } break;
        case VEPlaybackStatePaused: {
        } break;
        case VEPlaybackStateStopped: {
        } break;
        case VEPlaybackStateError: {
        } break;
        case VEPlaybackStateFinished: {
        } break;
        case VEPlaybackStateFinishedBecauseUser: {
        } break;
        default:
            break;
    }
    if ([self.receiver respondsToSelector:@selector(playerCore:playbackStateDidChanged:info:)]) {
        [self.receiver playerCore:self playbackStateDidChanged:self.playbackState info:@{}];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:playbackStateDidChange:uniqueId:)]) {
        [self.delegate videoPlayer:self playbackStateDidChange:self.playbackState uniqueId:self.mediaSource.uniqueId];
    }
}

- (void)__handleLoadStateChanged:(VEPlaybackLoadState)state {
    self.loadState = state;
    switch (state) {
        case VEPlaybackLoadStateStalled: {
            [[BaseLoadingView sharedInstance] startLoadingIn:self.playerPanelContainerView];
        } break;
        case VEPlaybackLoadStatePlayable: {
            [[BaseLoadingView sharedInstance] stopLoading];
        } break;
        case VEPlaybackLoadStateError: {
            [[BaseLoadingView sharedInstance] stopLoading];
        } break;
        default:
            [[BaseLoadingView sharedInstance] stopLoading];
            break;
    }
    if ([self.receiver respondsToSelector:@selector(playerCore:loadStateDidChange:)]) {
        [self.receiver playerCore:self loadStateDidChange:self.loadState];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:loadStateDidChange:)]) {
        [self.delegate videoPlayer:self loadStateDidChange:self.loadState];
    }
}

- (VEPlaybackState)__getPlaybackState:(TTVideoEnginePlaybackState)state {
    switch (state) {
        case TTVideoEnginePlaybackStatePlaying:
            return VEPlaybackStatePlaying;
        case TTVideoEnginePlaybackStatePaused:
            return VEPlaybackStatePaused;
        case TTVideoEnginePlaybackStateStopped:
            return VEPlaybackStateStopped;
        case TTVideoEnginePlaybackStateError:
            return VEPlaybackStateError;
        default:
            return VEPlaybackStateUnknown;
    }
}

- (VEPlaybackLoadState)__getLoadState:(TTVideoEngineLoadState)state {
    switch (state) {
        case TTVideoEngineLoadStateUnknown:
            return VEPlaybackLoadStateUnkown;
        case TTVideoEngineLoadStateStalled:
            return VEPlaybackLoadStateStalled;
        case TTVideoEngineLoadStatePlayable:
            return VEPlaybackLoadStatePlayable;
        case TTVideoEngineLoadStateError:
            return VEPlaybackLoadStateError;
        default:
            return VEPlaybackLoadStateUnkown;
    }
}

+ (void)cleanCache {
    [self clearAllVideoModelStrategy];
    [TTVideoEngine ls_clearAllCaches:YES];
}

- (void)setLooping:(BOOL)looping {
    [self.videoEngine setLooping:looping];
}

- (BOOL)looping {
    return self.videoEngine.looping;
}

#pragma mark - lazy load

- (UIView *)playerView {
    return self.videoEngine.playerView;
}

- (UIImageView *)posterImageView {
    if (!_posterImageView) {
        _posterImageView = [[UIImageView alloc] init];
        _posterImageView.backgroundColor = [UIColor clearColor];
        _posterImageView.clipsToBounds = YES;
        if (self.videoPlayerType & VEVideoPlayerTypeShortVerticalScreen) {
            _posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        } else {
            _posterImageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
    return _posterImageView;
}

- (UIView *)playerPanelContainerView {
    if (!_playerPanelContainerView) {
        _playerPanelContainerView = [[UIView alloc] init];
    }
    return _playerPanelContainerView;
}

@end
