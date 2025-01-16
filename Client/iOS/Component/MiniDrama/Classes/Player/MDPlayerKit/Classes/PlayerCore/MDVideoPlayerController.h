//
//  MDVideoPlayerController.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/11/11.
//  Copyright © 2021 ByteDance. All rights reserved.
//

@import UIKit;
#import "MDVideoPlayback.h"
#import "MDPlayerUIModule.h"
#import "MDPlayerBaseModule.h"
#import "MDVideoPlayerConfiguration.h"
#import <TTSDK/TTVideoEngine+Strategy.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, MDVideoPlayerType) {
    MDVideoPlayerTypeFeed = 1 << 1,
    MDVideoPlayerTypeLong = 1 << 2,
    MDVideoPlayerTypeShortHorizontalScreen = 1 << 3,
    MDVideoPlayerTypeShortVerticalScreen = 1 << 4,
    MDVideoPlayerTypeShort = MDVideoPlayerTypeShortHorizontalScreen | MDVideoPlayerTypeShortVerticalScreen,
};


@interface MDPreRenderVideoEngineMediatorDelegate : NSObject <TTVideoEnginePreRenderDelegate>

+ (MDPreRenderVideoEngineMediatorDelegate *)shareInstance;

@end



@protocol MDPlayCorePipStatusDelegate <NSObject>

- (void)updatePipStatus:(BOOL)isPipOpen;

@end

@interface MDVideoPlayerController : UIViewController <MDPlayCoreAbilityProtocol, MDVideoPlayback>

@property (nonatomic, strong, readonly) TTVideoEngine *videoEngine;

@property (nonatomic, readonly) MDVideoPlayerConfiguration *playerConfig;

@property (nonatomic, strong) UIImageView *posterImageView;

@property (nonatomic, weak) id<MDPlayCorePipStatusDelegate> pipStatusDelegate;

// MDPlayCoreAbilityProtocol
@property (nonatomic, weak) id<MDPlayCoreCallBackAbilityProtocol> _Nullable receiver;

- (instancetype)initWithConfiguration:(MDVideoPlayerConfiguration *)configuration;

- (instancetype)initWithConfiguration:(MDVideoPlayerConfiguration *)configuration 
                         moduleLoader:(MDPlayerBaseModule *)moduleLoader;

- (instancetype)initWithConfiguration:(MDVideoPlayerConfiguration *)configuration 
                         moduleLoader:(MDPlayerBaseModule *)moduleLoader
                  playerContainerView:(UIView * _Nullable)containerView;

- (void)loadBackgourdImageWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;

- (void)startPip:(BOOL)open;

+ (void)cleanCache;

@end

NS_ASSUME_NONNULL_END
