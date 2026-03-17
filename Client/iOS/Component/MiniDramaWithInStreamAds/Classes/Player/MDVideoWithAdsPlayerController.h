// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import UIKit;
#import "MDVideoPlayerController.h"
#import "MDVideoPlayback.h"
#import "MDPlayerUIModule.h"
#import "MDPlayerBaseModule.h"
#import "MDVideoPlayerConfiguration.h"
#import <TTSDKFramework/TTSDKFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoWithAdsPlayerController : MDVideoPlayerController

- (instancetype)initWithConfiguration:(MDVideoPlayerConfiguration *)configuration;

- (instancetype)initWithConfiguration:(MDVideoPlayerConfiguration *)configuration 
                         moduleLoader:(MDPlayerBaseModule *)moduleLoader;

- (instancetype)initWithConfiguration:(MDVideoPlayerConfiguration *)configuration 
                         moduleLoader:(MDPlayerBaseModule *)moduleLoader
                  playerContainerView:(UIView * _Nullable)containerView;

- (instancetype)initWithConfiguration:(MDVideoPlayerConfiguration *)configuration
                         moduleLoader:(MDPlayerBaseModule *)moduleLoader
                  playerContainerView:(UIView * _Nullable)containerView
                           socialView:(UIView *)socialView
                           customView:(UIView *)customView;

- (void)loadBackgourdImageWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;

- (void)startPip:(BOOL)open;

+ (void)cleanCache;

- (void)setCustomPlayerContainerView:(UIView *)playerContainerView;

@end

@interface VideoEngineDelegateProxy : NSObject <TTVideoEngineDelegate>

@property (nonatomic, weak) id<TTVideoEngineDelegate> mediaAdsDelegate;
@property (nonatomic, weak) id<TTVideoEngineDelegate> adsPlayerDelegate;

- (instancetype)initWithMediaAdsDelegate:(id<TTVideoEngineDelegate>)mediaAdsDelegate
                       adsPlayerDelegate:(id<TTVideoEngineDelegate>)adsPlayerDelegate;

@end

NS_ASSUME_NONNULL_END
