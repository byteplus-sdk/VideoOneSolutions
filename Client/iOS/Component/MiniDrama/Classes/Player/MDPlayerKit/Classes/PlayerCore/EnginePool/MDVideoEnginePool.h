// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <TTSDKFramework/TTSDKFramework.h>
#import "MDVideoPlayerConfiguration.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MDCreateEngineFrom) {
    MDCreateEngineFrom_Init,
    MDCreateEngineFrom_Cache,
    MDCreateEngineFrom_Prerender,
    MDCreateEngineFrom_Prepared,
};

typedef void(^MDEnginePoolBlock)(TTVideoEngine * _Nullable engine, MDCreateEngineFrom engineFrom);

@interface MDVideoEnginePool : NSObject

+ (MDVideoEnginePool *)shareInstance;

- (void)createVideoEngine:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource needPrerenderEngine:(BOOL)needPrerender configuration:(nullable MDVideoPlayerConfiguration *)configuration abr:(BOOL)abr block:(MDEnginePoolBlock)block;
// Keep the legacy API for callers such as ad players; it does not take over the page's prepared player.
- (void)createVideoEngine:(id<TTVideoEngineMediaSource>)mediaSource needPrerenderEngine:(BOOL)needPrerender block:(MDEnginePoolBlock)block;

- (void)removeVideoEngine:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;
@end

FOUNDATION_EXPORT void MDConfigureEngineBeforeSource(TTVideoEngine *engine, id<TTVideoEngineMediaSource> source, MDVideoPlayerConfiguration *configuration, BOOL abr);


// Use NSNull for unplayable episodes to preserve indices and avoid extending the window past paid episodes.
@interface MDPlaybackPreloader : NSObject
@property (nonatomic, assign) BOOL prepareEnabled; // Defaults to YES; pages disable it for ad playback.
- (void)willPlayAtIndex:(NSUInteger)index sources:(NSArray *)sources;
- (void)stop;
@end

// One-time home page warmup, enabled by default; not added to the player reuse pool.
@interface MDPlaybackWarmup : NSObject
- (void)startWithSource:(id<TTVideoEngineMediaSource>)source;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
