// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoPlayerController.h"

@interface VEVideoPlayerController (Strategy)

@property (nonatomic, assign) BOOL preRenderOpen;

@property (nonatomic, assign) BOOL preloadOpen;

+ (BOOL)enableEngineStrategy:(TTVideoEngineStrategyType)strategyType scene:(NSString *)scene;

+ (void)setStrategyVideoSources:(NSArray<id<TTVideoEngineMediaSource>> *)videoSources;

+ (void)addStrategyVideoSources:(NSArray<id<TTVideoEngineMediaSource>> *)videoSources;

+ (void)clearAllEngineStrategy;

+ (void)preloadVideoSource:(id<TTVideoEngineMediaSource>)videoSource;

+ (void)cancelPreloadVideoSources;

+ (void)addStrategyVideoModel:(TTVideoEngineModel *)videoModel forSource:(id<TTVideoEngineMediaSource>)videoSource;

+ (void)clearAllVideoModelStrategy;

- (void)loadStrategyVideoModel;

@end

