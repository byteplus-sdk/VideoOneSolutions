// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDVideoPlayerController+MDPlayCoreAbility.h"
#import "MDPlayerUIModule.h"
#import "MDPlayerUtility.h"
#import <ToolKit/ToolKit.h>

@implementation MDVideoPlayerController (MDPlayCoreAbility)

#pragma mark ----- origin class implementated
/*
 @property (nonatomic, weak) id<MDPlayCoreCallBackAbilityProtocol> receiver;
 @property (nonatomic, assign) BOOL looping;
 - (void)play;
 - (void)pause;
 */


#pragma mark ----- implementatation

- (CGFloat)playbackSpeed {
    return [self playbackRate];
}

- (void)setPlaybackSpeed:(CGFloat)speed {
    [self setPlaybackRate:speed];
}

- (void)setCurrentResolution:(TTVideoEngineResolutionType)resolution {
    NSDictionary *param = @{};
    [self.videoEngine configResolution:resolution params:param completion:^(BOOL success, TTVideoEngineResolutionType completeResolution) {
        VOLogI(VOMiniDrama, @"---resolution changed %@, current = %ld, param = %@", (success ? @"success" : @"fail"), completeResolution, param);
    }];
}

- (TTVideoEngineResolutionType)currentResolution {
    TTVideoEngineResolutionType currentRes = self.videoEngine.currentResolution;
    return currentRes;
}

- (void)setVolume:(CGFloat)volume {
    [self setPlaybackVolume:volume];
}

- (CGFloat)volume {
    return [self playbackVolume];
}



- (void)seek:(NSTimeInterval)destination {
    if (destination > 0.00) {
        [self seekToTime:destination complete:^(BOOL success) {
            NSLog(@"call seek succeed");
        } renderComplete:^{
            NSLog(@"render succeed after seek");
        }];
    }
}

- (MDPlaybackState)currentPlaybackState {
    MDPlaybackState state = MDPlaybackStateError;
    if (self.videoEngine) {
        switch (self.videoEngine.playbackState) {
            case TTVideoEnginePlaybackStateError: {
                state = MDPlaybackStateError;
            }
                break;
            case TTVideoEnginePlaybackStateStopped: {
                state = MDPlaybackStateStopped;
            }
                break;
            case TTVideoEnginePlaybackStatePlaying: {
                state = MDPlaybackStatePlaying;
            }
                break;
            case TTVideoEnginePlaybackStatePaused: {
                state = MDPlaybackStatePause;
            }
                break;
            default: {
                state = MDPlaybackStateUnknown;
            }
                break;
        }
    }
    return state;
}

- (NSString *)title {
    return [self playerTitle];
}

- (NSArray *)playSpeedSet {
    return @[
        @{@"0.5x" : @(0.5)},
        @{@"1.0x" : @(1.0)},
        @{@"1.5x" : @(1.5)},
        @{@"2.0x" : @(2.0)},
        @{@"3.0x" : @(3.0)}
    ];
}

- (NSArray *)resolutionSet {
    NSMutableArray *resolutionSet = [NSMutableArray array];
    for (NSNumber *originTypeNum in self.videoEngine.supportedResolutionTypes) {
        NSString *resolutionTitle = [MDPlayerUtility transferResolutionTitleByType:originTypeNum.integerValue];
        [resolutionSet addObject:@{resolutionTitle : originTypeNum}];
    }
    return resolutionSet;
}

@end
