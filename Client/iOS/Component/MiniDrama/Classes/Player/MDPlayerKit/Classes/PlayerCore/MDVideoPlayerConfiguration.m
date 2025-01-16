//
//  MDVideoPlayerConfiguration.m
//  MDPlayerKit
//
//  Created by zyw on 2024/7/16.
//

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
        self.isH265 = NO; // 默认设置为 NO；
        self.isOpenHardware = YES; // 默认设置为 YES；
        self.isOpenSR = NO; // 默认设置 NO；
    }
    return self;
}

@end
