// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDVideoPlayerController.h"

@interface MDVideoPlayerController (Strategy)

@property (nonatomic, assign) BOOL preRenderOpen;

@property (nonatomic, assign) BOOL preloadOpen;

+ (BOOL)enableEngineStrategy:(TTVideoEngineStrategyType)strategyType scene:(NSString *)scene;

+ (void)setStrategyVideoSources:(NSArray<id<TTVideoEngineMediaSource>> *)videoSources;

+ (void)addStrategyVideoSources:(NSArray<id<TTVideoEngineMediaSource>> *)videoSources;

+ (void)clearAllEngineStrategy;

@end

