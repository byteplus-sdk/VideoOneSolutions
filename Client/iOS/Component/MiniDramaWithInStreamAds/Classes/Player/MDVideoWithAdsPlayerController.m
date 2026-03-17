// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDVideoWithAdsPlayerController.h"
#import "MDVideoPlayerController+Observer.h"
#import "MDVideoPlayerController+Resolution.h"
#import "MDVideoPlayerController+DebugTool.h"
#import "MDVideoPlayerController+Tips.h"
#import "MDVideoPlayerController+Strategy.h"
#import "MDVideoPlayerController+DisRecordScreen.h"
#import "MDVideoPlayerController+MDPlayCoreAbility.h"
#import "MDTTVideoEngineSourceCategory.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "MDPlayerContext.h"
#import "MDPlayerInteraction.h"
#import "MDPlayerContextKeyDefine.h"
#import "BTDMacros.h"
#import "MiniDramaDetailPlayerModuleLoader.h"
#import "MDVideoEnginePool.h"
#import "BTDMacros.h"
#import "DramaDisrecordManager.h"
#import <AVKit/AVKit.h>
#import <TTSDKFramework/TTSDKFramework.h>
#import <ToolKit/ToolKit.h>
#import <MediaAdsToB/MediaAds.h>
#import <MediaAdsToB/AdPlaybackSession.h>
#import <MediaAdsToB/AdSchedule.h>
#import <UIKit/UIKit.h>
#import "VESettingModel.h"
#import "MDAdSettingManager.h"
#import "MDAdGlobalSettings.h"
#import <AppConfig/BuildConfig.h>

@interface MDWithAdsVideoPlayerDisplayView : UIView

@end

@implementation MDWithAdsVideoPlayerDisplayView

+ (Class)layerClass {
  return [AVSampleBufferDisplayLayer class];
}

@end

@interface MDVideoWithAdsPlayerController () <
MDVideoPlaybackDelegate,
TTVideoEngineDelegate,
TTVideoEngineDataSource,
TTVideoEngineResolutionDelegate,
TTVideoEnginePreloadDelegate,
AVPictureInPictureControllerDelegate,
AVPictureInPictureSampleBufferPlaybackDelegate,
AdPlaybackSessionDelegate>

@property (nonatomic, strong) MDVideoPlayerConfiguration *playerConfig;
@property (nonatomic, strong) TTVideoEngine *videoEngine;

@property (nonatomic, strong) AdSchedule *adSchedule;
@property (nonatomic, strong) AdPlaybackSession *adPlaybackSession;
@property (nonatomic, strong) VideoEngineDelegateProxy *delegateProxy;
@property (nonatomic, strong) UIView *statusBarView;

@property (nonatomic, assign) MDCreateEngineFrom engineFrom;

@property (nonatomic, strong) id<TTVideoEngineMediaSource> mediaSource;

@property (nonatomic, weak) UIView *playerContainerView;
@property (nonatomic, weak) UIView *socialView;
@property (nonatomic, weak) UIView *customView;

@property (nonatomic, assign) MDVideoPlaybackState playbackState;
@property (nonatomic, assign) MDVideoLoadState loadState;

@property (nonatomic, strong) MDPlayerContext *context;

@property (nonatomic, strong) MDPlayerInteraction<MDPlayerInteractionPlayerProtocol> *interaction;

// Pip
@property (nonatomic, strong) AVPictureInPictureController *pipController;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;
@property (nonatomic, strong) MDWithAdsVideoPlayerDisplayView *displayView;
@property (nonatomic, strong) UIView *adContainerView;

@property (nonatomic, assign) BOOL adPlaybackSessionStarted;
@property (nonatomic, assign) BOOL adIsPlaying;
@property (nonatomic, assign) BOOL adIsInterrupted;

@end

@implementation MDVideoWithAdsPlayerController

@synthesize delegate;
@synthesize playerTitle;
@synthesize duration;
@synthesize currentPlaybackTime;
@synthesize playableDuration;
@synthesize superResolutionEnable = _superResolutionEnable;
@synthesize videoViewMode = _videoViewMode;
@synthesize startTime = _startTime;
@synthesize netWorkSpeed = _netWorkSpeed;
@synthesize isPipOpen;

@dynamic playbackRate;
@dynamic playbackVolume;
@dynamic muted;
@dynamic audioMode;

- (instancetype)initWithConfiguration:(MDVideoPlayerConfiguration *)configuration {
    self = [super init];
    if (self) {
        self.playerConfig = configuration;
        self.adPlaybackSessionStarted = NO;
        self.adIsPlaying = NO;
        self.adIsInterrupted = NO;
    }
    return self;
}

- (instancetype)initWithConfiguration:(MDVideoPlayerConfiguration *)configuration
                         moduleLoader:(MDPlayerBaseModule *)moduleLoader {
    return [self initWithConfiguration:configuration moduleLoader:moduleLoader playerContainerView:nil];
}

- (instancetype)initWithConfiguration:(MDVideoPlayerConfiguration *)configuration
                         moduleLoader:(MDPlayerBaseModule *)moduleLoader
                  playerContainerView:(UIView * _Nullable)containerView {
    self = [self initWithConfiguration:configuration];
    if (self) {
        self.playerContainerView = containerView;
        self.playerConfig = configuration;
        
        _context = [[MDPlayerContext alloc] init];
        [_context bindOwner:self withProtocol:@protocol(MDVideoPlayback)];
        
        _interaction = [[MDPlayerInteraction alloc] initWithContext:_context];
        [_interaction addModule:moduleLoader];
    }
    return self;
}

- (instancetype)initWithConfiguration:(MDVideoPlayerConfiguration *)configuration
                         moduleLoader:(MDPlayerBaseModule *)moduleLoader
                  playerContainerView:(UIView * _Nullable)containerView
                           socialView:(UIView *)socialView
                           customView:(UIView *)customView{
    self = [self initWithConfiguration:configuration moduleLoader:moduleLoader playerContainerView:containerView];
    if (self) {
        self.socialView = socialView;
        self.customView = customView;
    }
    return self;
}

- (void)setCustomPlayerContainerView:(UIView *)playerContainerView {
    self.playerContainerView = playerContainerView;
}

- (void)dealloc {
    [self removeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    MDPlayerContextDIUnBind(MDVideoPlayback, self.context);
    MDPlayerContext *playerContext = self.context;
    MDPlayerContextRunOnMainThread(^{
        [playerContext removeAllHandler];
    });
    [self.interaction removeAllModules];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.adIsPlaying) {
        [self.adPlaybackSession resumeSession];
        self.adIsInterrupted = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    
    if (self.adIsPlaying) {
        self.adIsInterrupted = YES;
    }
    
	[self __resetPipController];
	[self __resetDisplayView];
}

- (void)createVideoEngine:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource needPrerenderEngine:(BOOL)needPrerender {
    if (super.videoEngine == nil) {
        /*
          We need to change audioSession category to playBack before using video Engine, or the video will be silent.
        */
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        @weakify(self);
        [[MDVideoEnginePool shareInstance] createVideoEngine:mediaSource needPrerenderEngine:needPrerender block:^(TTVideoEngine * _Nullable engine, MDCreateEngineFrom engineFrom) {
            @strongify(self);
			// Pip 
			[engine setOptionForKey:VEKKeyPlayerLoopWay_NSInteger value:@1];
			[engine setSupportPictureInPictureMode:YES];

            self.videoEngine = engine;
            self.videoEngine.playerView.tag = 123456;
            self.engineFrom = engineFrom;
            if (engineFrom == MDCreateEngineFrom_Init) {
                VOLogI(VOMiniDrama, @"createVideoEngine Init");
                [self.videoEngine setVideoEngineVideoSource:mediaSource];
            } else {
                VOLogI(VOMiniDrama, @"createVideoEngine Reuse");
                self.playbackState = [self __getPlaybackState:self.videoEngine.playbackState];
                self.loadState = [self __getLoadState:self.videoEngine.loadState];
                [self.context post:@(self.playbackState) forKey:MDPlayerContextKeyPlaybackState];
            }
        }];
    }
    _mediaSource = mediaSource;
    [self configureVideoEngine];
    
    if (self.adPlaybackSession == nil) {
        self.adPlaybackSession = [self createAdPlaybackSession];
        id<TTVideoEngineDelegate> mediaAdsDelegate = self.videoEngine.delegate;
        
        VideoEngineDelegateProxy *proxy = [[VideoEngineDelegateProxy alloc] initWithMediaAdsDelegate:mediaAdsDelegate
                                                                                      adsPlayerDelegate:self];
        self.videoEngine.delegate = proxy;
        self.delegateProxy = proxy;
    }
	
	if (self.playerConfig.enablePip) {
		[self __startObserveVideoFrame];
	}
}

 - (AdPlaybackSession *)createAdPlaybackSession {
     MediaAdsInitConfig *config = [[MediaAdsInitConfig alloc] init];
     config.appID = VODAPPID;
     config.appName = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleName"];
     config.appChannel = [NSBundle.mainBundle.infoDictionary objectForKey:@"CHANNEL_NAME"];
     AdPlaybackSession *session = [[MediaAds sharedInstance] createAdSession:self.videoEngine Config:config];
     session.delegate = self;
 
     [self __setupAdContainerView];
     _adContainerView.backgroundColor = [UIColor clearColor];
     _adContainerView.userInteractionEnabled = YES;
     [self.view addSubview:_adContainerView];
     
     if (@available(iOS 11.0, *)) {
         self.statusBarView = [[UIView alloc] init];
         self.statusBarView.backgroundColor = [UIColor blackColor];
         self.statusBarView.translatesAutoresizingMaskIntoConstraints = NO;

         [self.view addSubview:self.statusBarView];

         [NSLayoutConstraint activateConstraints:@[
             [self.statusBarView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
             [self.statusBarView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
             [self.statusBarView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
             [self.statusBarView.heightAnchor constraintEqualToConstant:44.0]
         ]];
         
         self.statusBarView.hidden = YES;
     } else {
         self.statusBarView = nil;
     }
     
     [session setAdView:_adContainerView AdViewController:self];
     return session;
}

- (void)__setupDisplayerView {
	self.displayView = [[MDWithAdsVideoPlayerDisplayView alloc] init];
	self.displayView.userInteractionEnabled = NO;
	self.displayView.clipsToBounds = YES;
	self.displayLayer = (AVSampleBufferDisplayLayer *)self.displayView.layer;
	self.displayLayer.opaque = YES;
	self.displayLayer.videoGravity = AVLayerVideoGravityResizeAspect;
	[self.view insertSubview:self.displayView aboveSubview:self.posterImageView];
    [self.displayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_top).offset(44);
        } else {
            make.top.equalTo(self.view.mas_top);
        }
    }];
}

- (void)__setupAdContainerView {
    self.adContainerView = [[UIView alloc] init];
    self.adContainerView.userInteractionEnabled = NO;
    self.adContainerView.clipsToBounds = YES;
    [self.view insertSubview:self.adContainerView aboveSubview:self.displayView];
    [self.adContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_top).offset(44);
        } else {
            make.top.equalTo(self.view.mas_top);
        }
    }];
}

- (void)__resetDisplayView {
	[self.displayView removeFromSuperview];
	[self.displayLayer stopRequestingMediaData];
	self.displayView = nil;
}

- (void)__setupPipController {
    if (@available(iOS 15.0, *)) {
        [self __updateAudioSession];
        AVPictureInPictureControllerContentSource *contentSource = [[AVPictureInPictureControllerContentSource alloc] initWithSampleBufferDisplayLayer:self.displayLayer playbackDelegate:self];
        self.pipController = [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
        self.pipController.canStartPictureInPictureAutomaticallyFromInline = YES;
        self.pipController.requiresLinearPlayback = YES;
        self.pipController.delegate = self;
    }
}

- (void)__resetPipController {
	if (@available(iOS 15.0, *)) {
		[self.pipController stopPictureInPicture];
		[self.pipController invalidatePlaybackState];
		self.pipController = nil;
	}
}

- (void)__updateAudioSession {
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	NSError *categoryError = nil;
	[audioSession setCategory:AVAudioSessionCategoryPlayback
						 mode:AVAudioSessionModeMoviePlayback
					  options:AVAudioSessionCategoryOptionOverrideMutedMicrophoneInterruption error:&categoryError];
	if (categoryError) {
		NSLog(@"volc--set audio session category error: %@", categoryError.localizedDescription);
	}
	NSError *activeError = nil;
	[audioSession setActive:YES error:&activeError];
	if (activeError) {
		NSLog(@"volc--set audio session active error: %@", activeError.localizedDescription);
	}
}

- (void)__startObserveVideoFrame {
	EngineVideoWrapper *wrapper = malloc(sizeof(EngineVideoWrapper));
	wrapper->process = process;
	wrapper->release = release;
	wrapper->context = (__bridge void *)self;
	[self.videoEngine setVideoWrapper:wrapper];
}

- (void)startPip:(BOOL)open {
    if (![AVPictureInPictureController isPictureInPictureSupported]) {
        self.isPipOpen = NO;
        [[ToastComponent shareToastComponent] showWithMessage:@"pip is not supported"];
        return;
    }
    if (open) {
        self.isPipOpen = YES;
        [self __setupPipController];
    } else {
        self.isPipOpen = NO;
        [self __resetPipController];
    }
    if (self.pipStatusDelegate && [self.pipStatusDelegate respondsToSelector:@selector(updatePipStatus:)]) {
        [self.pipStatusDelegate updatePipStatus:self.isPipOpen];
    }
}


- (void)__dispatchPixelBuffer:(CVPixelBufferRef)pixelBuffer {
	if (!pixelBuffer) {
		return;
	}
	CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};
	CMVideoFormatDescriptionRef videoInfo = NULL;
	OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
	NSParameterAssert(result == 0 && videoInfo != NULL);
	
	CMSampleBufferRef sampleBuffer = NULL;
	result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
	NSParameterAssert(result == 0 && sampleBuffer != NULL);
	CFRelease(videoInfo);
	CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
	CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
	CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
	[self enqueueSampleBuffer:sampleBuffer toLayer:self.displayLayer];
	CFRelease(sampleBuffer);
}

- (void)enqueueSampleBuffer:(CMSampleBufferRef)sampleBuffer toLayer:(AVSampleBufferDisplayLayer*)layer {
	if (!sampleBuffer || !layer.readyForMoreMediaData) {
		NSLog(@"volc--sampleBuffer invalid");
		return;
	}
	if (@available(iOS 16.0, *)) {
		if (layer.status == AVQueuedSampleBufferRenderingStatusFailed) {
			NSLog(@"volc--sampleBufferLayer error:%@",layer.error);
			[layer flush];
		}
	} else {
		[layer flush];
	}
	if (@available(iOS 15.0, *)) {
		[layer enqueueSampleBuffer:sampleBuffer];
	} else {
		MDPlayerContextRunOnMainThread(^{
			[layer enqueueSampleBuffer:sampleBuffer];
		});
	}
}

static void process(void *context, CVPixelBufferRef frame, int64_t timestamp) {
	NSLog(@"volc--frame=%@, ts=%.f", frame, timestamp);
	id ocContext = (__bridge id)context;
	MDVideoWithAdsPlayerController *controller = ocContext;
	[controller __dispatchPixelBuffer:frame];
}

static void release(void *context) {
	NSLog(@"volc--frame release");
}

#pragma mark - AVPictureInPictureControllerDelegate
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
	NSLog(@"volc--pictureInPictureControllerWillStartPictureInPicture");
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
	NSLog(@"volc--pictureInPictureControllerDidStartPictureInPicture");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
failedToStartPictureInPictureWithError:(NSError *)error {
	NSLog(@"volc--failedToStartPictureInPictureWithError");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
	NSLog(@"volc--restoreUserInterfaceForPictureInPictureStopWithCompletionHandler");
	completionHandler(true);
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
	NSLog(@"volc--pictureInPictureControllerWillStopPictureInPicture");
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
	NSLog(@"volc--pictureInPictureControllerDidStopPictureInPicture");
}


#pragma mark - AVPictureInPictureSampleBufferPlaybackDelegate
- (BOOL)pictureInPictureControllerIsPlaybackPaused:(nonnull AVPictureInPictureController *)pictureInPictureController {
	NSLog(@"volc--pictureInPictureControllerIsPlaybackPaused");
	return self.playbackState != MDVideoPlaybackStatePlaying;
}

- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(AVPictureInPictureController *)pictureInPictureController {
	NSLog(@"volc--pictureInPictureControllerTimeRangeForPlayback");
	return CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(10 * 60, NSEC_PER_SEC));
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
		 didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
	NSLog(@"volc--didTransitionToRenderSize");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController setPlaying:(BOOL)playing {
	NSLog(@"volc--pictureInPictureController setPlaying");
	if (playing) {
		[self.videoEngine play];
	} else {
		[self.videoEngine pause];
	}
	[self.pipController invalidatePlaybackState];
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
					skipByInterval:(CMTime)skipInterval
				 completionHandler:(void (^)(void))completionHandler {
	NSLog(@"volc--pictureInPictureController skipByInterval");
}

- (void)configureVideoEngine {
    [self __configPlayerScaleMode:self.videoEngine viewMode:self.playerConfig.videoViewMode];
    self.audioMode = self.playerConfig.audioMode;
    self.muted = self.playerConfig.muted;
    self.looping = self.playerConfig.looping;
    self.playbackRate = self.playerConfig.playbackRate;
    if (self.playerConfig.startTime > 0) {
        self.startTime = self.playerConfig.startTime;
    }
    if (@available(iOS 14.0, *)) {
        if (self.playerConfig.isSupportPictureInPictureMode) {
            [self.videoEngine setSupportPictureInPictureMode:YES];
        }
    }
    [self.videoEngine setOptionForKey:VEKKeyPlayerAudioDevice_ENUM value:@(TTVideoEngineDeviceAudioGraph)];
    [self.videoEngine setOptionForKey:VEKKeyPlayerHardwareDecode_BOOL value:@(self.playerConfig.isOpenHardware)];
    [self.videoEngine setOptionForKey:VEKKeyPlayerh265Enabled_BOOL value:@(self.playerConfig.isH265)];
    [self.videoEngine setOptionForKey:VEKKeyPlayerIdleTimerAuto_NSInteger value:@(YES)];
    [self.videoEngine setOptionForKey:VEKKeyPlayerSeekEndEnabled_BOOL value:@(YES)];
    // open super resolution
    if (self.playerConfig.isOpenSR && [self.videoEngine isSupportSR]) {
        self.superResolutionEnable = YES;
        [self.videoEngine setOptionForKey:VEKKeyPlayerEnableAllResolutionSR_BOOL value:@(YES)];
        [self.videoEngine setOptionForKey:VEKKeyPlayerEnableNNSR_BOOL value:@(YES)];
        [self.videoEngine setOptionForKey:VEKKeyIsEnableVideoBmf_BOOL value:@(YES)];
        [self.videoEngine setOptionForKey:VEKKeyIsEnableEnsureSRGetFirstFrame value:@(YES)];
    }
    
    self.videoEngine.resolutionDelegate = self;
    self.videoEngine.dataSource = self;
    [self setCurrentResolution:[MDVideoWithAdsPlayerController getPlayerCurrentResolution]];
    
    [self addObserver];
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.posterImageView];
    [self.posterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
	
	[self __setupDisplayerView];
}

- (void)reLayoutVideoPlayerView {
    self.videoEngine.playerView.clipsToBounds = YES;
    [self.videoEngine.playerView removeFromSuperview];
    [self.view insertSubview:self.videoEngine.playerView aboveSubview:self.posterImageView];
    [self.videoEngine.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Private

- (void)__setBackgroudImageForMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    /// player is running, return
    if ([self isPlaying] && [self isPause]) {
        return;
    }
    if (self.preRenderOpen) {
        TTVideoEngine *preRenderVideoEngine = [TTVideoEngine getPreRenderFinishedVideoEngineWithVideoSource:mediaSource];
        if (preRenderVideoEngine) {
            preRenderVideoEngine.playerView.hidden = NO;
            self.posterImageView.hidden = YES;
            preRenderVideoEngine.playerView.clipsToBounds = YES;
            [self __configPlayerScaleMode:preRenderVideoEngine viewMode:_videoViewMode];
            [self.view insertSubview:preRenderVideoEngine.playerView aboveSubview:self.posterImageView];
            [preRenderVideoEngine.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            VOLogI(VOMiniDrama, @"preRender works");
        } else {
            self.posterImageView.hidden = NO;
            [self.posterImageView sd_setImageWithURL:[NSURL URLWithString:[self __getBackgroudImageUrl:mediaSource]] completed:nil];
            VOLogI(VOMiniDrama, @"preRender not work");
        }
    } else {
        self.posterImageView.hidden = NO;
        [self.posterImageView sd_setImageWithURL:[NSURL URLWithString:[self __getBackgroudImageUrl:mediaSource]] completed:nil];
    }
}

- (NSString *)__getBackgroudImageUrl:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    NSString *url = [(NSObject *)mediaSource valueForKey:@"cover"];
    return url ?: @"";
}

- (void)__closeVideoPlayer {
    [[MDVideoEnginePool shareInstance] removeVideoEngine:self.mediaSource];
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

- (void)configStartTime:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    NSInteger retStartTime = 0;
    if (mediaSource.sourceType == TTVideoEngineSourceTypeVideoId) {
        retStartTime = [(TTVideoEngineVidSource *)mediaSource startTime];
    } else if (mediaSource.sourceType == TTVideoEngineSourceTypeDirectUrl) {
        retStartTime = [(TTVideoEngineUrlSource *)mediaSource startTime];
    }
    if (retStartTime > 0) {
        self.startTime = retStartTime;
    }
}

#pragma mark - Player control

- (void)setMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    _mediaSource = mediaSource;
    [self createVideoEngine:mediaSource needPrerenderEngine:NO];
}

- (void)loadBackgourdImageWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    [self __setBackgroudImageForMediaSource:mediaSource];
}

- (void)playWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    [self createVideoEngine:mediaSource needPrerenderEngine:self.preRenderOpen];
    [self reLayoutVideoPlayerView];
    [self play];
    
    [self __addPeriodicTimeObserver];
}

- (void)prepareToPlay {
    BTDAssertMainThread();
    MDPlayerContextRunOnMainThread(^{
        [self.adPlaybackSession prepareAD];
    });
}

- (void)play {
    BTDAssertMainThread();
    MDPlayerContextRunOnMainThread(^{
        if ([DramaDisrecordManager isOpenDisrecord] && @available(iOS 11.0, *)) {
            if ([[[[UIApplication sharedApplication] keyWindow] screen] isCaptured]) {
                [[DramaDisrecordManager sharedInstance] showDisRecordView];
                return;
            }
        }
        [self __handleBeforePlayAction];
        if (self.adPlaybackSessionStarted == YES) {
            [self.adPlaybackSession resumeSession];
        } else {
            // this needs to be called to allow the videoPlayerPrepared callback to be invoked to be able to schedule ads based on video duration
            [self.videoEngine play];
        }
        [self _handleAfterPlayAction];
        [self __addPeriodicTimeObserver];
        if (self.playerConfig.enableLoadSpeed) {
            [TTVideoEngine ls_setPreloadDelegate:self];
        }
    });
}

- (void)pause {
    BTDAssertMainThread();
    MDPlayerContextRunOnMainThread(^{
        [self.context post:@(YES) forKey:MDPlayerContextKeyPauseAction];
        [self.adPlaybackSession pauseSession];
	});
}

- (void)seekToTime:(NSTimeInterval)time
          complete:(void(^ _Nullable)(BOOL success))finised
    renderComplete:(void(^ _Nullable)(void)) renderComplete {
    BTDAssertMainThread();
    MDPlayerContextRunOnMainThread(^{
        [self.videoEngine setCurrentPlaybackTime:time complete:finised renderComplete:renderComplete];
    });
}

- (void)stop {
    [self unregisterScreenCaptureDidChangeNotification];
    BTDAssertMainThread();
    MDPlayerContextRunOnMainThread(^{
        [self.context post:@(YES) forKey:MDPlayerContextKeyStopAction];
        [self.adPlaybackSession stopSession];
        [self __closeVideoPlayer];
    });
}

- (void)close {
    [self.adPlaybackSession stopSession];
    [self.videoEngine closeAysnc];
    [self __closeVideoPlayer];
}

- (BOOL)isPlaying {
    return (self.playbackState == MDVideoPlaybackStatePlaying) || (self.adIsPlaying && !self.adIsInterrupted);
}

- (BOOL)isPause {
    return (self.playbackState == MDVideoPlaybackStatePaused);
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
    VOLogI(VOMiniDrama, @"setPlaybackVolume: %f", playbackVolume);
    self.videoEngine.volume = playbackVolume;
}

- (CGFloat)playbackVolume {
    CGFloat currentVolume = self.videoEngine.volume;
    VOLogI(VOMiniDrama, @"currentVolume: %f", currentVolume);
    return currentVolume;
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

- (void)setSuperResolutionEnable:(BOOL)superResolutionEnable {
    _superResolutionEnable = superResolutionEnable;
    [self.videoEngine setOptionForKey:VEKKeyPlayerEnableNNSR_BOOL value:@(superResolutionEnable)];
    [self.videoEngine setOptionForKey:VEKKeyIsEnableVideoBmf_BOOL value:@(superResolutionEnable)];
}

#pragma mark - TTVideoEnginePreloadDelegate

- (void)localServerTestSpeedInfo:(NSTimeInterval)timeInternalMs size:(NSInteger)sizeByte {
    NSTimeInterval time = timeInternalMs / 1000;
    CGFloat dataSize = sizeByte / 1024;
    self.netWorkSpeed = dataSize / time;
}

#pragma mark - TTVideoEngineDelegate

- (void)videoEnginePrepared:(TTVideoEngine *)videoEngine {
    // video duration is set by the time this callback is called
    _adSchedule = [[AdSchedule alloc] init];
    
    MDAdSettingManager *adSettingManager = [MDAdSettingManager universalManager];

    if (adSettingManager.prerollEnabled) {
        [_adSchedule addLinearAdWithOffset:@"pre" adTagUrl:MDAdGlobalSettings.prerollTag];
    }

    if (adSettingManager.midrollEnabled) {
        [_adSchedule addLinearAdWithOffset:[self stringFromTimeInterval:[self duration] / 2] adTagUrl:MDAdGlobalSettings.midrollTag];
    }
  
    if (adSettingManager.postrollEnabled) {
        [_adSchedule addLinearAdWithOffset:@"post" adTagUrl:MDAdGlobalSettings.postrollTag];
    }

    [_adPlaybackSession setSchedule:_adSchedule];
    [self.adPlaybackSession startSession];
    self.adPlaybackSessionStarted = YES;

    if (self.delegate &&[self.delegate respondsToSelector:@selector(videoPlayerPrepared:)]) {
        [self.delegate videoPlayerPrepared:self];
    }
    if ([self.receiver respondsToSelector:@selector(playerCore:resolutionChanged:info:)]) {
        [self.receiver playerCore:self resolutionChanged:self.currentResolution info:@{}];
    }
    [self.context post:@(YES) forKey:MDPlayerContextKeyEnginePrepared];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

- (void)videoEngineReadyToDisPlay:(TTVideoEngine *)videoEngine {
    self.videoEngine.playerView.hidden = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerReadyToDisplay:)]) {
        [self.delegate videoPlayerReadyToDisplay:self];
    }
    [self.context post:@(YES) forKey:MDPlayerContextKeyReadyForDisplay];
}

- (void)videoEngineReadyToPlay:(TTVideoEngine *)videoEngine {
    [self.context post:@(YES) forKey:MDPlayerContextKeyReadyToPlay];
}

- (void)videoEngine:(TTVideoEngine *)videoEngine playbackStateDidChanged:(TTVideoEnginePlaybackState)playbackState {
    [self __handlePlaybackStateChanged:[self __getPlaybackState:playbackState]];
    if ([self.receiver respondsToSelector:@selector(playerCore:playbackStateDidChanged:info:)]) {
        [self.receiver playerCore:self playbackStateDidChanged:self.currentPlaybackState info:@{}];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine loadStateDidChanged:(TTVideoEngineLoadState)loadState {
    [self __handleLoadStateChanged:[self __getLoadState:loadState]];
}

- (void)videoEngine:(TTVideoEngine *)videoEngine fetchedVideoModel:(TTVideoEngineModel *)videoModel {
    if ([self.delegate respondsToSelector:@selector(videoPlayer:fetchedVideoModel:)]) {
        [self.delegate videoPlayer:self fetchedVideoModel:videoModel];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine loadStateDidChanged:(TTVideoEngineLoadState)loadState extra:(nullable NSDictionary<NSString *,id> *)extraInfo {
    [self __handleLoadStateChanged:[self __getLoadState:loadState]];
}

- (void)videoEngine:(TTVideoEngine *)videoEngine mdlKey:(NSString *)key hitCacheSze:(NSInteger)cacheSize {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:key:hitVideoPreloadDataSize:)]) {
        [self.delegate videoPlayer:self key:key hitVideoPreloadDataSize:cacheSize];
    }
    BTDLog(@"EngineStrategy: ===== hitCacheSze %@, vid = %@", @(cacheSize), [self.mediaSource getUniqueId]);
}

- (void)videoEngineUserStopped:(TTVideoEngine *)videoEngine {
    [self __handlePlayFinishStateChange:MDVideoPlayFinishStatusType_UserFinish error:nil];
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine error:(nullable NSError *)error {
    [self __handlePlayFinishStateChange:MDVideoPlayFinishStatusType_SystemFinish error:error];
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine videoStatusException:(NSInteger)status {
    NSError *error = [NSError errorWithDomain:@"MDPlayerSourceException" code:status userInfo:nil];
    [self __handlePlayFinishStateChange:MDVideoPlayFinishStatusType_SystemFinish error:error];
}

- (void)videoEngineCloseAysncFinish:(TTVideoEngine *)videoEngine {
    if (![self.videoEngine isEqual:videoEngine]) {
        return;
    }
    [self __handlePlayFinishStateChange:MDVideoPlayFinishStatusType_CloseAnsync error:nil];
}

- (void)videoEngineStalledExcludeSeek:(TTVideoEngine *)videoEngine {
    
}

- (void)videoEngineBeforeViewRemove:(TTVideoEngine *)videoEngine {
    
}

- (void)videoBitrateDidChange:(TTVideoEngine *)videoEngine resolution:(TTVideoEngineResolutionType)resolution bitrate:(NSInteger)bitrate {
    VOLogI(VOMiniDrama, @"resolution: %ld", resolution);
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerBitrateDidChange:resolution:bitrate:)]) {
        [self.delegate videoPlayerBitrateDidChange:self resolution:resolution bitrate:bitrate];
    }
    // MDUIModule
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

- (void)__handleBeforePlayAction {
    [self.context post:@(YES) forKey:MDPlayerContextKeyBeforePlayAction];
}

- (void)_handleAfterPlayAction {
    [self.context post:@(YES) forKey:MDPlayerContextKeyPlayAction];
}

- (void)__handlePlaybackStateChanged:(MDVideoPlaybackState)state {
    self.playbackState = state;
    switch (state) {
        case MDVideoPlaybackStatePlaying: {
			NSLog(@"volc--state MDVideoPlaybackStatePlaying");
            self.videoEngine.playerView.hidden = NO;
        }
            break;
        case MDVideoPlaybackStatePaused: {
			NSLog(@"volc--state MDVideoPlaybackStatePaused");
        }
            break;
        case MDVideoPlaybackStateStopped: {
			NSLog(@"volc--state MDVideoPlaybackStateStopped");
        }
            break;
        case MDVideoPlaybackStateError: {
			NSLog(@"volc--state MDVideoPlaybackStateError");
            [self showTips:NSLocalizedStringFromTable(@"tip_play_error_normal", @"VodLocalizable", nil)];
        }
            break;
        default:
            break;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:playbackStateDidChange:)]) {
        [self.delegate videoPlayer:self playbackStateDidChange:self.playbackState];
    }
    [self.context post:@(self.playbackState) forKey:MDPlayerContextKeyPlaybackState];
	if (self.playerConfig.enablePip) {
		[self.pipController invalidatePlaybackState];
	}
}

- (void) __handleLoadStateChanged:(MDVideoLoadState)state {
    self.loadState = state;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:loadStateDidChange:)]) {
        [self.delegate videoPlayer:self loadStateDidChange:self.loadState];
    }
    [self.context post:@(state) forKey:MDPlayerContextKeyLoadState];
}

- (void)__handlePlayFinishStateChange:(MDVideoPlayFinishStatusType)finishState error:(NSError *)error {
    MDPlayFinishStatus *finishStatus = [[MDPlayFinishStatus alloc] init];
    finishStatus.finishState = finishState;
    finishStatus.error = error;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:didFinishedWithStatus:)]) {
        [self.delegate videoPlayer:self didFinishedWithStatus:finishStatus];
    }
    [self.context post:finishStatus forKey:MDPlayerContextKeyPlaybackDidFinish];
}

- (MDVideoPlaybackState)__getPlaybackState:(TTVideoEnginePlaybackState)state {
    switch (state) {
        case TTVideoEnginePlaybackStatePlaying:
            return MDVideoPlaybackStatePlaying;
        case TTVideoEnginePlaybackStatePaused:
            return MDVideoPlaybackStatePaused;
        case TTVideoEnginePlaybackStateStopped:
            return MDVideoPlaybackStateStopped;
        case TTVideoEnginePlaybackStateError:
            return MDVideoPlaybackStateError;
        default:
            return MDVideoPlaybackStateUnkown;
    }
}

- (MDVideoLoadState)__getLoadState:(TTVideoEngineLoadState)state {
    switch (state) {
        case TTVideoEngineLoadStateUnknown:
            return MDVideoLoadStateUnkown;
        case TTVideoEngineLoadStateStalled:
            return MDVideoLoadStateStalled;
        case TTVideoEngineLoadStatePlayable:
            return MDVideoLoadStatePlayable;
        case TTVideoEngineLoadStateError:
            return MDVideoLoadStateError;
        default:
            return MDVideoLoadStateUnkown;
    }
}

- (void)__configPlayerScaleMode:(TTVideoEngine *)videoEngine viewMode:(MDVideoViewMode)videoViewMode {
    switch (videoViewMode) {
        case MDVideoViewModeAspectFit: {
            [videoEngine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeAspectFit)];
            self.posterImageView.contentMode = UIViewContentModeScaleAspectFit;
        }
            break;
        case MDVideoViewModeAspectFill: {
            [videoEngine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeAspectFill)];
            self.posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        }
            break;
        case MDVideoViewModeModeFill: {
            [videoEngine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeFill)];
            self.posterImageView.contentMode = UIViewContentModeScaleToFill;
        }
            break;
        default: {
            [videoEngine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeNone)];
            self.posterImageView.contentMode = UIViewContentModeScaleAspectFit;
        }
            break;
    }
}

+ (void)cleanCache {
    [TTVideoEngine ls_clearAllCaches:YES];
}

- (void)setLooping:(BOOL)looping {
    [self.videoEngine setLooping:looping];
}

- (BOOL)looping {
    return self.videoEngine.looping;
}

- (void)setVideoViewMode:(MDVideoViewMode)videoViewMode {
    _videoViewMode = videoViewMode;
    [self __configPlayerScaleMode:self.videoEngine viewMode:_videoViewMode];
}

- (void)setStartTime:(NSTimeInterval)startTime {
    _startTime = startTime;
    if (self.engineFrom == MDCreateEngineFrom_Init) {
        [self.videoEngine setOptionForKey:VEKKeyPlayerStartTime_CGFloat value:@(startTime)];
    } else {
        [self seekToTime:startTime complete:nil renderComplete:nil];
    }
}

#pragma mark - lazy load

- (UIView *)playerView {
    self.videoEngine.playerView.backgroundColor = [UIColor blackColor];
    return self.videoEngine.playerView;
}

- (UIImageView *)posterImageView {
    if (!super.posterImageView) {
        super.posterImageView = [[UIImageView alloc] init];
        super.posterImageView.backgroundColor = [UIColor clearColor];
        super.posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        super.posterImageView.clipsToBounds = YES;
    }
    return super.posterImageView;
}

#pragma mark - AdPlaybackSessionDelegate

- (void)sessionContentPause {
    self.adIsPlaying = YES;
    if (self.isLandscape) {
        self.playerContainerView.hidden = YES;
    } else {
        self.socialView.hidden = YES;
        for (UIView *subview in [self.customView subviews]) {
            if (subview.tag == MDAdGlobalSettings.hideDuringAdTag) {
                subview.hidden = YES;
            }
        }
    }
    if (self.statusBarView != nil) {
        self.statusBarView.hidden = NO;
    }
}

- (void)sessionContentResume {
    self.adIsPlaying = NO;
    if (self.isLandscape) {
        self.playerContainerView.hidden = NO;
    } else {
        self.socialView.hidden = NO;
        for (UIView *subview in [self.customView subviews]) {
            if (subview.tag == MDAdGlobalSettings.hideDuringAdTag) {
                subview.hidden = NO;
            }
        }
    }
    if (self.statusBarView != nil) {
        self.statusBarView.hidden = YES;
    }
}

@end

@implementation VideoEngineDelegateProxy

- (instancetype)initWithMediaAdsDelegate:(id<TTVideoEngineDelegate>)mediaAdsDelegate
                       adsPlayerDelegate:(id<TTVideoEngineDelegate>)adsPlayerDelegate {
    self = [super init];
    if (self) {
        _mediaAdsDelegate = mediaAdsDelegate;
        _adsPlayerDelegate = adsPlayerDelegate;
    }
    return self;
}

#pragma mark - TTVideoEngineDelegate forwarding
- (void)videoEnginePrepared:(TTVideoEngine *)videoEngine {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoEnginePrepared:)]) {
        [self.mediaAdsDelegate videoEnginePrepared:videoEngine];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoEnginePrepared:)]) {
        [self.adsPlayerDelegate videoEnginePrepared:videoEngine];
    }
}

- (void)videoEngineReadyToDisPlay:(TTVideoEngine *)videoEngine {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoEngineReadyToDisPlay:)]) {
        [self.mediaAdsDelegate videoEngineReadyToDisPlay:videoEngine];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoEngineReadyToDisPlay:)]) {
        [self.adsPlayerDelegate videoEngineReadyToDisPlay:videoEngine];
    }
}

- (void)videoEngineReadyToPlay:(TTVideoEngine *)videoEngine {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoEngineReadyToPlay:)]) {
        [self.mediaAdsDelegate videoEngineReadyToPlay:videoEngine];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoEngineReadyToPlay:)]) {
        [self.adsPlayerDelegate videoEngineReadyToPlay:videoEngine];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine playbackStateDidChanged:(TTVideoEnginePlaybackState)playbackState {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoEngine:playbackStateDidChanged:)]) {
        [self.mediaAdsDelegate videoEngine:videoEngine playbackStateDidChanged:playbackState];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoEngine:playbackStateDidChanged:)]) {
        [self.adsPlayerDelegate videoEngine:videoEngine playbackStateDidChanged:playbackState];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine loadStateDidChanged:(TTVideoEngineLoadState)loadState {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoEngine:loadStateDidChanged:)]) {
        [self.mediaAdsDelegate videoEngine:videoEngine loadStateDidChanged:loadState];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoEngine:loadStateDidChanged:)]) {
        [self.adsPlayerDelegate videoEngine:videoEngine loadStateDidChanged:loadState];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine fetchedVideoModel:(TTVideoEngineModel *)videoModel {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoEngine:fetchedVideoModel:)]) {
        [self.mediaAdsDelegate videoEngine:videoEngine fetchedVideoModel:videoModel];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoEngine:fetchedVideoModel:)]) {
        [self.adsPlayerDelegate videoEngine:videoEngine fetchedVideoModel:videoModel];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine loadStateDidChanged:(TTVideoEngineLoadState)loadState extra:(nullable NSDictionary<NSString *,id> *)extraInfo {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoEngine:loadStateDidChanged:extra:)]) {
        [self.mediaAdsDelegate videoEngine:videoEngine loadStateDidChanged:loadState extra:extraInfo];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoEngine:loadStateDidChanged:extra:)]) {
        [self.adsPlayerDelegate videoEngine:videoEngine loadStateDidChanged:loadState extra:extraInfo];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine mdlKey:(NSString *)key hitCacheSze:(NSInteger)cacheSize {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoEngine:mdlKey:hitCacheSze:)]) {
        [self.mediaAdsDelegate videoEngine:videoEngine mdlKey:key hitCacheSze:cacheSize];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoEngine:mdlKey:hitCacheSze:)]) {
        [self.adsPlayerDelegate videoEngine:videoEngine mdlKey:key hitCacheSze:cacheSize];
    }
}

- (void)videoEngineUserStopped:(TTVideoEngine *)videoEngine {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoEngineUserStopped:)]) {
        [self.mediaAdsDelegate videoEngineUserStopped:videoEngine];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoEngineUserStopped:)]) {
        [self.adsPlayerDelegate videoEngineUserStopped:videoEngine];
    }
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine error:(nullable NSError *)error {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoEngineDidFinish:error:)]) {
        [self.mediaAdsDelegate videoEngineDidFinish:videoEngine error:error];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoEngineDidFinish:error:)]) {
        [self.adsPlayerDelegate videoEngineDidFinish:videoEngine error:error];
    }
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine videoStatusException:(NSInteger)status {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoEngineDidFinish:videoStatusException:)]) {
        [self.mediaAdsDelegate videoEngineDidFinish:videoEngine videoStatusException:status];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoEngineDidFinish:videoStatusException:)]) {
        [self.adsPlayerDelegate videoEngineDidFinish:videoEngine videoStatusException:status];
    }
}

- (void)videoEngineCloseAysncFinish:(TTVideoEngine *)videoEngine {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoEngineCloseAysncFinish:)]) {
        [self.mediaAdsDelegate videoEngineCloseAysncFinish:videoEngine];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoEngineCloseAysncFinish:)]) {
        [self.adsPlayerDelegate videoEngineCloseAysncFinish:videoEngine];
    }
}

- (void)videoEngineStalledExcludeSeek:(TTVideoEngine *)videoEngine {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoEngineStalledExcludeSeek:)]) {
        [self.mediaAdsDelegate videoEngineStalledExcludeSeek:videoEngine];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoEngineStalledExcludeSeek:)]) {
        [self.adsPlayerDelegate videoEngineStalledExcludeSeek:videoEngine];
    }
}

- (void)videoEngineBeforeViewRemove:(TTVideoEngine *)videoEngine {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoEngineBeforeViewRemove:)]) {
        [self.mediaAdsDelegate videoEngineBeforeViewRemove:videoEngine];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoEngineBeforeViewRemove:)]) {
        [self.adsPlayerDelegate videoEngineBeforeViewRemove:videoEngine];
    }
}

- (void)videoBitrateDidChange:(TTVideoEngine *)videoEngine resolution:(TTVideoEngineResolutionType)resolution bitrate:(NSInteger)bitrate {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoBitrateDidChange:resolution:bitrate:)]) {
        [(id)self.mediaAdsDelegate videoBitrateDidChange:videoEngine resolution:resolution bitrate:bitrate];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoBitrateDidChange:resolution:bitrate:)]) {
        [(id)self.adsPlayerDelegate videoBitrateDidChange:videoEngine resolution:resolution bitrate:bitrate];
    }
}

- (void)videoSizeDidChange:(TTVideoEngine *)videoEngine videoWidth:(NSInteger)videoWidth videoHeight:(NSInteger)videoHeight {
    if ([self.mediaAdsDelegate respondsToSelector:@selector(videoSizeDidChange:videoWidth:videoHeight:)]) {
        [(id)self.mediaAdsDelegate videoSizeDidChange:videoEngine videoWidth:videoWidth videoHeight:videoHeight];
    }
    if ([self.adsPlayerDelegate respondsToSelector:@selector(videoSizeDidChange:videoWidth:videoHeight:)]) {
        [(id)self.adsPlayerDelegate videoSizeDidChange:videoEngine videoWidth:videoWidth videoHeight:videoHeight];
    }
}
@end
