// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import UIKit;
#import "VEPlayerUIModule.h"
#import "VEVideoPlayback.h"
#import "VEVideoPlaybackPanel.h"
#import <TTSDK/TTVideoEngineHeader.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, VEVideoPlayerType) {
    VEVideoPlayerTypeFeed = 1 << 1,
    VEVideoPlayerTypeLong = 1 << 2,
    VEVideoPlayerTypeShortHorizontalScreen = 1 << 3,                                                        // 横屏短视频
    VEVideoPlayerTypeShortVerticalScreen = 1 << 4,                                                          // 竖屏短视频
    VEVideoPlayerTypeShort = VEVideoPlayerTypeShortHorizontalScreen | VEVideoPlayerTypeShortVerticalScreen, // 短视频包含横屏、竖屏
};

@interface VEVideoPlayerController : UIViewController <VEVideoPlayback>

@property (nonatomic, strong, readonly) TTVideoEngine *videoEngine;

@property (nonatomic, assign, readonly) VEVideoPlayerType videoPlayerType;

// VEPlayCoreAbilityProtocol
@property (nonatomic, weak) id<VEPlayCoreCallBackAbilityProtocol> _Nullable receiver;

- (instancetype)initWithType:(VEVideoPlayerType)videoPlayerType;

- (void)loadBackgourdImageWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;

+ (void)cleanCache;

@end

NS_ASSUME_NONNULL_END
