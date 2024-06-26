// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEPlayerUIModule.h"
#import "VEVideoPlayerController+VEPlayCoreAbility.h"
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
        VOLogI(VOVideoPlayback,@"resolution changed %@, current = %ld, param = %@", (success ? @"success" : @"fail"), completeResolution, param);
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
        VOLogI(VOVideoPlayback,@"call seek succeed %lf", [self currentPlaybackTime]);
        if (self.currentPlaybackState == VEPlaybackStatePaused && destination == self.duration) {
            [self.videoEngine stop];
        }
    } renderComplete:^{
        VOLogI(VOVideoPlayback,@"render succeed after seek");
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
        NSString *resolutionTitle = [self _transferResolutionTitleByType:originTypeNum.integerValue];
        [resolutionSet addObject:@{resolutionTitle: originTypeNum}];
    }
    return resolutionSet;
}

- (NSString *)_transferResolutionTitleByType:(NSInteger)type {
    NSString *resolutionTitle;
    switch (type) {
        case TTVideoEngineResolutionTypeSD:
            resolutionTitle = @"320";
            break;
        case TTVideoEngineResolutionTypeHD:
            resolutionTitle = @"540";
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
            resolutionTitle = LocalizedStringFromBundle(@"resolution_abr_auto", @"VEVodApp");
            break;
        case TTVideoEngineResolutionTypeAuto:
            resolutionTitle = LocalizedStringFromBundle(@"resolution_auto", @"VEVodApp");
            break;
        case TTVideoEngineResolutionTypeUnknown:
            resolutionTitle = LocalizedStringFromBundle(@"resolution_unknown", @"VEVodApp");
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
            resolutionTitle = LocalizedStringFromBundle(@"resolution_default", @"VEVodApp");
            break;
    }
    return resolutionTitle;
}

- (NSTimeInterval)durationWatched {
    return self.videoEngine.durationWatched;
}

@end
