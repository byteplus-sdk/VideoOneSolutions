// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEPlayerUIModule.h"
#import "VEVideoPlayerController+VEPlayCoreAbility.h"
#import "VEPlayerUtility.h"
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>

@implementation VEVideoPlayerController (VEPlayCoreAbility)

#pragma mark----- origin class implementated
/*
 @property (nonatomic, weak) id<VEPlayCoreCallBackAbilityProtocol> receiver;
 @property (nonatomic, assign) BOOL looping;
 - (void)play;
 - (void)pause;
 */

#pragma mark----- implementatation

- (CGFloat)playbackSpeed {
    return [self playbackRate];
}

- (void)setPlaybackSpeed:(CGFloat)speed {
    [self setPlaybackRate:speed];
}

- (void)setCurrentResolution:(TTVideoEngineResolutionType)resolution {
    NSDictionary *param = @{};
    [self.videoEngine configResolution:resolution params:param completion:^(BOOL success, TTVideoEngineResolutionType completeResolution) {
        VOLogI(VOToolKit,@"resolution changed %@, current = %ld, param = %@", (success ? @"success" : @"fail"), completeResolution, param);
    }];
}

- (TTVideoEngineResolutionType)currentResolution {
    return self.videoEngine.currentResolution;
}

- (void)setVolume:(CGFloat)volume {
    [self setPlaybackVolume:volume];
}

- (CGFloat)volume {
    return [self playbackVolume];
}

- (void)seek:(NSTimeInterval)destination {
    if (destination < 0.00) {
        return;
    }
    if (self.currentPlaybackState != VEPlaybackStatePaused && self.currentPlaybackState != VEPlaybackStatePlaying) {
        [self setStartTime:destination];
        return;
    }
    [self seekToTime:destination complete:^(BOOL success) {
        VOLogI(VOToolKit,@"call seek succeed %lf", [self currentPlaybackTime]);
        if (self.currentPlaybackState == VEPlaybackStatePaused && destination == self.duration) {
            [self.videoEngine stop];
        }
    } renderComplete:^{
        VOLogI(VOToolKit,@"render succeed after seek");
    }];
}

- (VEPlaybackState)currentPlaybackState {
    return self.playbackState;
}

- (VEPlaybackLoadState)currentLoadState {
    return self.loadState;
}

- (NSString *)title {
    return [self playerTitle];
}

- (NSArray *)playSpeedSet {
    return @[
        @{@"0.5x": @(0.5)},
        @{@"1.0x": @(1.0)},
        @{@"1.5x": @(1.5)},
        @{@"2.0x": @(2.0)},
        @{@"3.0x": @(3.0)}
    ];
}

- (NSArray *)resolutionSet {
    NSMutableArray *resolutionSet = [NSMutableArray array];
    for (NSNumber *originTypeNum in self.videoEngine.supportedResolutionTypes) {
        NSString *resolutionTitle = [VEPlayerUtility transferResolutionTitleByType:originTypeNum.integerValue];
        [resolutionSet addObject:@{resolutionTitle: originTypeNum}];
    }
    return resolutionSet;
}

- (NSTimeInterval)durationWatched {
    return self.videoEngine.durationWatched;
}

@end
