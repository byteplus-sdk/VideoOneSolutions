// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import UIKit;
#import "VEVideoPlayback.h"
#import "VEVideoPlaybackPanel.h"
#import <TTSDK/TTVideoEngineHeader.h>
#import "VEPlayerUIModule.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VEVideoPlayerType) {
    VEVideoPlayerTypeFeed,
    VEVideoPlayerTypeShort,
    VEVideoPlayerTypeLong,
};

@interface VEPreRenderVideoEngineMediatorDelegate : NSObject <TTVideoEnginePreRenderDelegate>

+ (VEPreRenderVideoEngineMediatorDelegate *)shareInstance;

@end


@interface VEVideoPlayerController : UIViewController <VEVideoPlayback>

@property (nonatomic, strong, readonly) TTVideoEngine *videoEngine;

// VEPlayCoreAbilityProtocol
@property (nonatomic, weak) id<VEPlayCoreCallBackAbilityProtocol> _Nullable receiver;

- (instancetype)initWithType:(VEVideoPlayerType)videoPlayerType;

- (void)loadBackgourdImageWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;

+ (void)cleanCache;

@end

NS_ASSUME_NONNULL_END
