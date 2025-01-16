//
//  MDVideoPlayerController+MDPlayCoreAbility.m
//  VOLCDemo
//
//  Created by real on 2022/1/11.
//

#import "MDVideoPlayerController+MDPlayCoreAbility.h"
#import "MDPlayerUIModule.h"
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
        NSString *resolutionTitle = [self _transferResolutionTitleByType:originTypeNum.integerValue];
        [resolutionSet addObject:@{resolutionTitle : originTypeNum}];
    }
    return resolutionSet;
}

- (NSString *)_transferResolutionTitleByType:(NSInteger)type {
    NSString *resolutionTitle;
    switch (type) {
        case TTVideoEngineResolutionTypeSD:
            resolutionTitle = @"360";
            break;
        case TTVideoEngineResolutionTypeHD:
            resolutionTitle = @"480";
            break;
        case TTVideoEngineResolutionTypeFullHD:
            resolutionTitle = @"720";
            break;
        case TTVideoEngineResolutionType1080P:
            resolutionTitle = @"1080";
            break;
        case TTVideoEngineResolutionType4K:
            resolutionTitle = @"4K";
            break;
        case TTVideoEngineResolutionTypeABRAuto:
            resolutionTitle = @"ABR自动";
            break;
        case TTVideoEngineResolutionTypeAuto:
            resolutionTitle = @"自动";
            break;
        case TTVideoEngineResolutionTypeUnknown:
            resolutionTitle = @"未知";
            break;
        case TTVideoEngineResolutionTypeHDR:
            resolutionTitle = @"HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_240P:
            resolutionTitle = @"240p HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_360P:
            resolutionTitle = @"360p HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_480P:
            resolutionTitle = @"480p HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_540P:
            resolutionTitle = @"540p HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_720P:
            resolutionTitle = @"720p HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_1080P:
            resolutionTitle = @"1080p HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_2K:
            resolutionTitle = @"2k HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_4K:
            resolutionTitle = @"4k HDR";
            break;
        case TTVideoEngineResolutionType2K:
            resolutionTitle = @"2k";
            break;
        case TTVideoEngineResolutionType1080P_120F:
            resolutionTitle = @"1080P_120F";
            break;
        case TTVideoEngineResolutionType2K_120F:
            resolutionTitle = @"2K_120F";
            break;
        case TTVideoEngineResolutionType4K_120F:
            resolutionTitle = @"4K_120F";
            break;
        default:
            resolutionTitle = @"默认";
            break;
    }
    return resolutionTitle;
}

@end
