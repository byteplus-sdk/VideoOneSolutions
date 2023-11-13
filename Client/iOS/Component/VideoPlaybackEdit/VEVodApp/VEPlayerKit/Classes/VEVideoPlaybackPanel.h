// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import Foundation;
#import "VEVideoPlayback.h"


@protocol VEVideoPlaybackPanelPotocol <NSObject>

- (instancetype)initWithVideoPlayer:(id<VEVideoPlayback>)videoPlayer;

- (void)videoPlayerPlaybackStateChanged:(VEVideoPlaybackState)oldState
                               newState:(VEVideoPlaybackState)newState;

- (void)videoPlayerLoadStateChanged:(VEVideoLoadState)oldState
                           newState:(VEVideoLoadState)newState;

- (void)videoPlayerTimeTrigger:(NSTimeInterval)duration
           currentPlaybackTime:(NSTimeInterval)currentPlaybackTime
              playableDuration:(NSTimeInterval)playableDuration;

@end
