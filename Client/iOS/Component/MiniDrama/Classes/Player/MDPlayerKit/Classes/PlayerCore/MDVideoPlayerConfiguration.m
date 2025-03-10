// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDVideoPlayerConfiguration.h"
@implementation MDVideoPlayerConfiguration

+ (MDVideoPlayerConfiguration *)defaultPlayerConfiguration {
    MDVideoPlayerConfiguration *playerConfigration = [[MDVideoPlayerConfiguration alloc] init];
    return playerConfigration;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.videoViewMode = MDVideoViewModeAspectFill;
        self.audioMode = NO;
        self.muted = NO;
        self.looping = YES;
        self.playbackRate = 1.0;
        self.startTime = 0;
        self.isSupportPictureInPictureMode = NO;
        self.enableLoadSpeed = YES;
        self.isH265 = NO;
        self.isOpenHardware = YES;
        self.isOpenSR = NO;
    }
    return self;
}

@end
