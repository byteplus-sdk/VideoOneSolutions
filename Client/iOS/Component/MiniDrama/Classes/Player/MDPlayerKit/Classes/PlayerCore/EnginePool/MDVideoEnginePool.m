// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDVideoEnginePool.h"
#import "BTDMacros.h"
#import <TTSDKFramework/TTSDKFramework.h>
#import "MDTTVideoEngineSourceCategory.h"
#import "MDVideoPlayerController+Resolution.h"
#import "VESettingManager.h"
#import <AVFoundation/AVFoundation.h>


static NSString *MDPreparationConfiguration(MDVideoPlayerConfiguration *config, BOOL abr) {
    return [NSString stringWithFormat:@"%d/%d/%d/%d/%d/%.3f",
            abr, config.isOpenHardware, config.isH265, config.isOpenSR, config.audioMode, config.startTime];
}

void MDConfigureEngineBeforeSource(TTVideoEngine *engine, id<TTVideoEngineMediaSource> source, MDVideoPlayerConfiguration *config, BOOL abr) {
    [engine setOptionForKey:VEKKeyPlayerHardwareDecode_BOOL value:@(config.isOpenHardware)];
    [engine setOptionForKey:VEKKeyPlayerh265Enabled_BOOL value:@(config.isH265)];
    [engine setOptionForKey:VEKKeyPlayerAudioDevice_ENUM value:@(TTVideoEngineDeviceAudioGraph)];
    [engine setOptionForKey:VEKKeyMasterm3u8OptimizeEnable_BOOL value:@YES];
    [engine setOptionForKey:VEKKeyEnterBufferingDirectly_BOOL value:@NO];
    [engine setOptionForKey:VEKKeyPlayerHLSSeamlessSwitchEnable_BOOL value:@(abr)];
    [engine configResolution:abr ? TTVideoEngineResolutionTypeABRAuto : [MDVideoPlayerController getPlayerCurrentResolution]];
    NSTimeInterval start = config.startTime > 0 ? config.startTime : MAX(0, MDSourceStartTime(source));
    if (start > 0) [engine setOptionForKey:VEKKeyPlayerEnableStartTimeSkipAVSkipSerial value:@YES];
    [engine setOptionForKey:VEKKeyPlayerStartTime_CGFloat value:@(start)];
    [engine setOptionForKey:VEKKeyPlayerIdleTimerAuto_NSInteger value:@YES];
    [engine setOptionForKey:VEKKeyPlayerSeekEndEnabled_BOOL value:@YES];
    [engine setTag:@"mini_drama"];
}

@interface MDPlaybackPreloader () <TTVideoEngineDelegate, TTVideoEngineABRDelegate>
@property (nonatomic, strong) MDCacheLoader *loader;
@property (nonatomic, copy) NSArray *sources;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<TTVideoEngineMediaSource>> *dataSources;
@property (nonatomic, strong) TTVideoEngine *preparedEngine;
@property (nonatomic, strong) id<TTVideoEngineMediaSource> preparedSource;
@property (nonatomic, copy) NSString *preparedIdentity;
@property (nonatomic, copy) NSString *preparedConfiguration;
@property (nonatomic, assign) BOOL preparedFailed;
@property (nonatomic, assign) BOOL suspended;
- (TTVideoEngine *)takeSource:(id<TTVideoEngineMediaSource>)source configuration:(MDVideoPlayerConfiguration *)configuration abr:(BOOL)abr;
@end

@interface MDVideoEnginePool ()

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMapTable<NSString *, TTVideoEngine *> *videoEngines;;
@property (nonatomic, strong) NSMapTable<NSString *, MDPlaybackPreloader *> *preparedOwners;

@end

@implementation MDVideoEnginePool

+ (MDVideoEnginePool *)shareInstance {
    static MDVideoEnginePool *enginePoolShareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (enginePoolShareInstance == nil) {
            enginePoolShareInstance = [[MDVideoEnginePool alloc] init];
        }
    });
    return enginePoolShareInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc] init];
        self.videoEngines = [NSMapTable weakToWeakObjectsMapTable];
        self.preparedOwners = [NSMapTable strongToWeakObjectsMapTable];
    }
    return self;
}

- (void)createVideoEngine:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource needPrerenderEngine:(BOOL)needPrerender configuration:(nullable MDVideoPlayerConfiguration *)configuration abr:(BOOL)abr block:(MDEnginePoolBlock)block {
    NSString *identity = MDSourceIdentity(mediaSource);
    MDPlaybackPreloader *owner = configuration ? [self.preparedOwners objectForKey:identity] : nil;
    TTVideoEngine *prepared = [owner takeSource:mediaSource configuration:configuration abr:abr];
    if (prepared) {
        [self.videoEngines setObject:prepared forKey:mediaSource.uniqueId];
        BTD_BLOCK_INVOKE(block, prepared, MDCreateEngineFrom_Prepared);
        return;
    }
    [self.lock lock];
    if (mediaSource.uniqueId == nil || mediaSource.uniqueId.length == 0) {
        NSAssert(mediaSource.uniqueId, @"source uniqueId is nil");
        
        BTDLog(@"EnginePool: %@ ===== init video engine play", mediaSource.uniqueId);
        TTVideoEngine *videoEngine = [[TTVideoEngine alloc] init];
        [self.videoEngines setObject:videoEngine forKey:mediaSource.uniqueId];
        BTD_BLOCK_INVOKE(block, videoEngine, MDCreateEngineFrom_Init);
    } else {
        TTVideoEngine *prerenderVideoEngine = nil;
        if (needPrerender) {
            prerenderVideoEngine = [TTVideoEngine getPreRenderVideoEngineWithVideoSource:mediaSource];
        }
        if (prerenderVideoEngine) {
            BTDLog(@"EnginePool: %@ ===== use pre render video engine play", mediaSource.uniqueId);
            [self.videoEngines setObject:prerenderVideoEngine forKey:mediaSource.uniqueId];
            BTD_BLOCK_INVOKE(block, prerenderVideoEngine, MDCreateEngineFrom_Prerender);
        } else {
            TTVideoEngine *videoEngine = [self.videoEngines objectForKey:mediaSource.uniqueId];
            if (videoEngine == nil) {
                BTDLog(@"EnginePool: %@ ===== init video engine play", mediaSource.uniqueId);
                videoEngine = [[TTVideoEngine alloc] init];
                [self.videoEngines setObject:videoEngine forKey:mediaSource.uniqueId];
                BTD_BLOCK_INVOKE(block, videoEngine, MDCreateEngineFrom_Init);
                
            } else {
                BTDLog(@"EnginePool: %@ ===== use cahce video engine play", mediaSource.uniqueId);
                [self.videoEngines setObject:videoEngine forKey:mediaSource.uniqueId];
                BTD_BLOCK_INVOKE(block, videoEngine, MDCreateEngineFrom_Cache);
            }
        }
    }
    BTDLog(@"EnginePool: %@ ===== engine count %@", mediaSource.uniqueId, @(self.videoEngines.count));
    [self.lock unlock];
}

- (void)createVideoEngine:(id<TTVideoEngineMediaSource>)mediaSource needPrerenderEngine:(BOOL)needPrerender block:(MDEnginePoolBlock)block {
    // Pass nil only to distinguish the legacy API; normal playback always supplies a configuration.
    [self createVideoEngine:mediaSource needPrerenderEngine:needPrerender configuration:nil abr:NO block:block];
}

- (void)removeVideoEngine:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    [self.lock lock];
    if (mediaSource.uniqueId) {
        [self.videoEngines removeObjectForKey:mediaSource.uniqueId];
    }
    [self.lock unlock];
}

@end

@implementation MDPlaybackPreloader
- (instancetype)init {
    if ((self = [super init])) {
        _loader = [MDCacheLoader new];
        _dataSources = [NSMutableDictionary dictionary];
        _currentIndex = NSNotFound;
        _prepareEnabled = YES;
        _suspended = UIApplication.sharedApplication.applicationState == UIApplicationStateBackground;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (id<TTVideoEngineMediaSource>)sourceAtIndex:(NSUInteger)index {
    id source = index < self.sources.count ? self.sources[index] : nil;
    return [source conformsToProtocol:@protocol(TTVideoEngineMediaSource)] ? source : nil;
}

- (void)willPlayAtIndex:(NSUInteger)index sources:(NSArray *)sources {
    NSAssert(NSThread.isMainThread, @"Playback window must be updated on main thread");
    self.sources = sources;
    self.currentIndex = index;
    if (self.suspended) return;
    id<TTVideoEngineMediaSource> current = [self sourceAtIndex:index];
    id<TTVideoEngineMediaSource> next = index < sources.count ? [self sourceAtIndex:index + 1] : nil;
    NSString *currentIdentity = current ? MDSourceIdentity(current) : nil;
    NSString *nextIdentity = next ? MDSourceIdentity(next) : nil;
    NSMutableDictionary *desired = [NSMutableDictionary dictionary];
    // Preload +2...+6 normally; with ads, download +1...+5 and leave preparation to the ad session.
    if (index < sources.count) {
        NSUInteger first = index + (self.prepareEnabled ? 2 : 1);
        for (NSUInteger i = first; i < MIN(sources.count, first + 5); i++) {
            id<TTVideoEngineMediaSource> source = [self sourceAtIndex:i];
            if (source && ![MDSourceIdentity(source) isEqual:currentIdentity] &&
                (!self.prepareEnabled || ![MDSourceIdentity(source) isEqual:nextIdentity])) desired[MDSourceIdentity(source)] = source;
        }
    }
    // Cancel tasks for the current episode, next episode and items outside the window before adding new ones to avoid duplicate playback/prepare downloads.
    for (NSString *key in self.dataSources.allKeys) {
        if (!desired[key]) {
            [self.loader stopTask:self.dataSources[key]];
            [self.dataSources removeObjectForKey:key];
        }
    }
    if (self.preparedEngine &&
        ![self.preparedIdentity isEqual:currentIdentity] &&
        ![self.preparedIdentity isEqual:nextIdentity]) {
        [self releasePreparedEngine];
    }
    for (NSString *key in desired) {
        if (!self.dataSources[key]) {
            self.dataSources[key] = desired[key];
            [self.loader preload:desired[key] bytes:500 * 1024 completion:nil];
        }
    }
    // When the prepared next episode becomes current, keep it until playback takes over; then prepare the new next episode.
    if (!self.preparedEngine) [self prepareNext];
}

- (void)prepareNext {
    if (!self.prepareEnabled || self.suspended || self.currentIndex == NSNotFound || self.preparedEngine) return;
    id<TTVideoEngineMediaSource> source = [self sourceAtIndex:self.currentIndex + 1];
    if (!source.uniqueId.length) return;
    MDVideoPlayerConfiguration *config = [MDVideoPlayerConfiguration defaultPlayerConfiguration];
    BOOL abr = [[[VESettingManager universalManager] settingForKey:VESettingKeyUniversalABRConfig] open];
    self.preparedSource = source;
    self.preparedIdentity = MDSourceIdentity(source);
    self.preparedConfiguration = MDPreparationConfiguration(config, abr);
    self.preparedFailed = NO;
    TTVideoEngine *engine = [[TTVideoEngine alloc] init];
    self.preparedEngine = engine; // Hold a strong reference here; the weak pool alone cannot keep the player alive.
    engine.delegate = self;
    engine.abrDelegate = abr ? self : nil;
    engine.muted = YES;
    MDConfigureEngineBeforeSource(engine, source, config, abr);
    [engine setVideoEngineVideoSource:source];
    [[MDVideoEnginePool shareInstance].preparedOwners setObject:self forKey:self.preparedIdentity];
    [engine prepareToPlay]; // prepareToPlay is not limited by the 500 KiB preload budget.
    NSLog(@"[MDPrepare] source=%@ engine=%p", source.uniqueId, engine);
}

- (TTVideoEngine *)takeSource:(id<TTVideoEngineMediaSource>)source configuration:(MDVideoPlayerConfiguration *)configuration abr:(BOOL)abr {
    if (![self.preparedIdentity isEqual:MDSourceIdentity(source)]) return nil;
    if (self.preparedFailed || ![self.preparedConfiguration isEqual:MDPreparationConfiguration(configuration, abr)] || configuration.isOpenSR) {
        [self releasePreparedEngine];
        dispatch_async(dispatch_get_main_queue(), ^{ [self prepareNext]; });
        return nil;
    }
    TTVideoEngine *engine = self.preparedEngine;
    [[MDVideoEnginePool shareInstance].preparedOwners removeObjectForKey:self.preparedIdentity];
    self.preparedEngine = nil;
    self.preparedSource = nil;
    self.preparedIdentity = nil;
    engine.delegate = nil;
    engine.abrDelegate = nil;
    NSLog(@"[MDPrepare] handoff source=%@ engine=%p", source.uniqueId, engine);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{ [weakSelf prepareNext]; });
    return engine;
}

- (void)releasePreparedEngine {
    if (self.preparedIdentity &&
        [[MDVideoEnginePool shareInstance].preparedOwners objectForKey:self.preparedIdentity] == self) {
        [[MDVideoEnginePool shareInstance].preparedOwners removeObjectForKey:self.preparedIdentity];
    }
    self.preparedEngine.delegate = nil;
    self.preparedEngine.abrDelegate = nil;
    [self.preparedEngine closeAysnc];
    self.preparedEngine = nil;
    self.preparedSource = nil;
    self.preparedIdentity = nil;
}

- (TTVideoEngineStrategyABRConfig *)videoEngineAbrConfig:(TTVideoEngine *)videoEngine {
    return [TTVideoEngineStrategyABRConfig abrConfigWithWifiMaxResolution:TTVideoEngineResolutionType1080P mobileMaxResolution:TTVideoEngineResolutionType1080P];
}


- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine error:(NSError *)error {
    if (videoEngine == self.preparedEngine && error) self.preparedFailed = YES;
}
- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine videoStatusException:(NSInteger)status {
    if (videoEngine == self.preparedEngine) self.preparedFailed = YES;
}
- (void)videoEngineUserStopped:(TTVideoEngine *)videoEngine {}
- (void)videoEngineCloseAysncFinish:(TTVideoEngine *)videoEngine {}
- (void)enterBackground {
    self.suspended = YES;
    [self.loader stopAll];
    [self.dataSources removeAllObjects];
    [self releasePreparedEngine];
}
- (void)becomeActive {
    self.suspended = NO;
    if (self.currentIndex != NSNotFound) [self willPlayAtIndex:self.currentIndex sources:self.sources];
}

- (void)stop {
    self.currentIndex = NSNotFound;
    self.sources = nil;
    [self.loader stopAll];
    [self.dataSources removeAllObjects];
    [self releasePreparedEngine];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stop];
}
@end

@interface MDPlaybackWarmup () <TTVideoEngineDelegate>
@property (nonatomic, strong) TTVideoEngine *engine;
@end

@implementation MDPlaybackWarmup
- (void)startWithSource:(id<TTVideoEngineMediaSource>)source {
    static BOOL attempted = NO;
    if (attempted || !source.uniqueId.length) {
        return;
    }
    attempted = YES; // Try only once per process, even if the attempt is canceled or fails.
    TTVideoEngine *engine = [[TTVideoEngine alloc] init];
    self.engine = engine;
    engine.delegate = self;
    engine.muted = YES;
    MDVideoPlayerConfiguration *config = [MDVideoPlayerConfiguration defaultPlayerConfiguration];
    MDConfigureEngineBeforeSource(engine, source, config, NO);
    [engine setOptionForKey:VEKKeyPlayerStartTime_CGFloat value:@0];
    [engine setVideoEngineVideoSource:source];
    [engine play];
    __weak typeof(self) weakSelf = self;
    __weak TTVideoEngine *weakEngine = engine;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (weakEngine && weakSelf.engine == weakEngine) [weakSelf stop];
    });
}
- (void)videoEngineReadyToDisPlay:(TTVideoEngine *)engine {
    [self stop];
}
- (void)videoEngineDidFinish:(TTVideoEngine *)engine error:(NSError *)error {
    [self stop];
}
- (void)videoEngineDidFinish:(TTVideoEngine *)engine videoStatusException:(NSInteger)status {
    [self stop];
}
- (void)videoEngineUserStopped:(TTVideoEngine *)engine {}
- (void)videoEngineCloseAysncFinish:(TTVideoEngine *)engine {}
- (void)stop {
    self.engine.delegate = nil;
    [self.engine closeAysnc];
    self.engine = nil;
}
- (void)dealloc { [self stop]; }
@end
