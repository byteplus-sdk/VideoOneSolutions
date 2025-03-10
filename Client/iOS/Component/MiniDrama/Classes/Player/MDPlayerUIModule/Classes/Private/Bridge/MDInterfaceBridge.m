// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceBridge.h"
#import "MDEventConst.h"
#import "MDPlayProtocol.h"
#import <ToolKit/ToolKit.h>


NSString *const MDPlayEventStateChanged = @"MDPlayEventStateChanged";

NSString *const MDPlayEventTimeIntervalChanged = @"MDPlayEventTimeIntervalChanged";

NSString *const MDPlayEventPiPStatusChanged = @"MDPlayEventPiPStatusChanged";

@interface MDInterfaceBridge () <MDPlayCoreCallBackAbilityProtocol>

@property (nonatomic, weak) id<MDPlayCoreAbilityProtocol> core;

@property (nonatomic, assign) BOOL stopMark;

@end

@implementation MDInterfaceBridge

static id sharedInstance = nil;
+ (instancetype)bridge {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
        [sharedInstance registEvents];
    }
    return sharedInstance;
}

+ (void)destroyUnit {
    @autoreleasepool {
        sharedInstance = nil;
    }
}


#pragma mark ----- Action / Message

- (void)registEvents {
    [[MDEventMessageBus universalBus] registEvent:MDTaskPlayCoreTransfer withAction:@selector(bindPlayerCore:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDPlayEventPlay withAction:@selector(playAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDPlayEventPause withAction:@selector(pauseAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDPlayEventSeek withAction:@selector(seekAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDPlayEventChangeLoopPlayMode withAction:@selector(changeLoopPlayModeAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDPlayEventChangeSREnable withAction:@selector(changeSREnableAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDPlayEventChangePlaySpeed withAction:@selector(changePlaySpeedAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDPlayEventChangeResolution withAction:@selector(changeResolutionAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDUIEventBrightnessIncrease withAction:@selector(changeBrightnessAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDUIEventVolumeIncrease withAction:@selector(changeVolumeAction:) ofTarget:self];
}

- (void)bindPlayerCore:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id core = paramDic.allValues.firstObject;
        if ([core conformsToProtocol:@protocol(MDPlayCoreAbilityProtocol)]) {
            self.core = core;
            self.core.receiver = self;
        }
    }
}

- (void)playAction:(id)param {
    if ([self.core respondsToSelector:@selector(play)]) {
        [self.core play];
    }
}

- (void)pauseAction:(id)param {
    if ([self.core respondsToSelector:@selector(pause)]) {
        [self.core pause];
    }
}

- (void)seekAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            NSTimeInterval interval = [((NSNumber *)value) doubleValue];
            if ([self.core respondsToSelector:@selector(seek:)]) {
                [self.core seek:interval];
            }
        }
    }
}

- (void)changeLoopPlayModeAction:(id)param {
    if ([self.core respondsToSelector:@selector(setLooping:)]) {
        [self.core setLooping:!self.core.looping];
    }
}

- (void)changeSREnableAction:(BOOL)srEnable {
    if ([self.core respondsToSelector:@selector(setSuperResolutionEnable:)]) {
        [self.core setSuperResolutionEnable:!self.core.superResolutionEnable];
    }
}

- (void)changePlaySpeedAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            CGFloat speed = [(NSNumber *)value floatValue];
            if ([self.core respondsToSelector:@selector(setPlaybackSpeed:)]) {
                [self.core setPlaybackSpeed:speed];
                [[MDEventMessageBus universalBus] postEvent:MDPlayEventPlaySpeedChanged withObject:nil rightNow:YES];
            }
        }
    }
}

- (void)changeResolutionAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            NSInteger resolutionType = [(NSNumber *)value integerValue];
            if ([self.core respondsToSelector:@selector(setCurrentResolution:)]) {
                [self.core setCurrentResolution:resolutionType];
            }
        }
    }
}

- (void)changeVolumeAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            if ([self.core respondsToSelector:@selector(setVolume:)]) {
                CGFloat changeValue = [(NSNumber *)value floatValue];
                changeValue = self.core.volume + changeValue;
                [self.core setVolume:MIN(MAX(changeValue, 0.0), 1.0)];
            }
        } else if ([value isKindOfClass:[NSValue class]]) {
            NSValue *v = (NSValue *)value;
            CGPoint p = v.CGPointValue;
            [self.core setVolume:MIN(MAX(p.x, 0.0), 1.0)];
        }
    }
}

- (void)changeBrightnessAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            CGFloat changeValue = [(NSNumber *)value floatValue];
            CGFloat currentBrightness = [[UIScreen mainScreen] brightness];
            currentBrightness = MIN(MAX(currentBrightness += changeValue, 0.0), 1.0);
            [[UIScreen mainScreen] setBrightness:currentBrightness];
        } else if ([value isKindOfClass:[NSValue class]]) {
            NSValue *v = (NSValue *)value;
            CGPoint p = v.CGPointValue;
            NSLog(@"currentBrightness: %f,", p.x);
            [[UIScreen mainScreen] setBrightness:MIN(MAX(p.x, 0.0), 1.0)];
        }
    }
}

#pragma mark ----- MDInfoProtocol, Static Info / Poster

- (NSInteger)currentPlaybackState {
    if ([self.core respondsToSelector:@selector(currentPlaybackState)]) {
        return [self.core currentPlaybackState];
    } else {
        return NSNotFound;
    }
}

- (NSTimeInterval)duration {
    if ([self.core respondsToSelector:@selector(duration)]) {
        return [self.core duration];
    } else {
        return 0.0;
    }
}

- (NSTimeInterval)playableDuration {
    if ([self.core respondsToSelector:@selector(playableDuration)]) {
        return [self.core playableDuration];
    } else {
        return 0.0;
    }
}

- (NSString *)title {
    if ([self.core respondsToSelector:@selector(title)]) {
        return [self.core title];
    } else {
        return @"";
    }
}

- (BOOL)loopPlayOpen {
    if ([self.core respondsToSelector:@selector(looping)]) {
        return [self.core looping];
    }
    return NO;
}

- (BOOL)srOpen {
    if ([self.core respondsToSelector:@selector(superResolutionEnable)]) {
        return [self.core superResolutionEnable];
    }
    return NO;
}

- (CGFloat)currentPlaySpeed {
    if ([self.core respondsToSelector:@selector(playbackSpeed)]) {
        return [self.core playbackSpeed];
    }
    return 1.0;
}

- (NSString *)currentPlaySpeedForDisplay {
    for (NSDictionary *playSpeedDic in [self playSpeedSet]) {
        if ([playSpeedDic.allValues.firstObject floatValue] == [self currentPlaySpeed]) {
            return playSpeedDic.allKeys.firstObject;
        }
    }
    return @"";
}

- (NSArray *)playSpeedSet {
    if ([self.core respondsToSelector:@selector(playSpeedSet)]) {
        return [self.core playSpeedSet];
    }
    return @[];
}

- (NSInteger)currentResolution {
    if ([self.core respondsToSelector:@selector(currentResolution)]) {
        return [self.core currentResolution];
    }
    return 6; // TTVideoEngineResolutionTypeUnknown == 6
}

- (NSString *)currentResolutionForDisplay {
    for (NSDictionary *resolutionDic in [self resolutionSet]) {
        if ([resolutionDic.allValues.firstObject integerValue] == [self currentResolution]) {
            return resolutionDic.allKeys.firstObject;
        }
    }
    return @"";
}

- (NSArray *)resolutionSet {
    if ([self.core respondsToSelector:@selector(resolutionSet)]) {
        return [self.core resolutionSet];
    }
    return @[];
}

- (CGFloat)currentVolume {
    if ([self.core respondsToSelector:@selector(volume)]) {
        return [self.core volume];
    }
    return 0.0;
}

- (CGFloat)currentBrightness {
    return [[UIScreen mainScreen] brightness];
}
#pragma mark - PIP

- (BOOL)isPipOpen {
    return [self.core isPipOpen];
}

- (void)enablePIP:(void (^)(BOOL))block {
    [self.core startPip:YES];
    if (block) {
        block(self.core.isPipOpen);
    }
}

- (void)disablePIP {
    [self.core startPip:NO];
}

#pragma mark ----- MDPlayCoreCallBackAbilityProtocol

- (void)playerCore:(id<MDPlayCoreAbilityProtocol>)core playbackStateDidChanged:(MDPlaybackState)currentState info:(NSDictionary *)info {
    if (core == self.core) {
        [[MDEventMessageBus universalBus] postEvent:MDPlayEventStateChanged withObject:@[@(currentState), info] rightNow:YES];
    }
}

- (void)playerCore:(id<MDPlayCoreAbilityProtocol>)core playTimeDidChanged:(NSTimeInterval)interval info:(NSDictionary *)info {
    if (core == self.core) {
        if (!self.stopMark) {
            [[MDEventMessageBus universalBus] postEvent:MDPlayEventTimeIntervalChanged withObject:@(interval) rightNow:YES];
        }
        MDPlaybackState state = [[MDEventPoster currentPoster] currentPlaybackState];
        if (state == MDPlaybackStatePlaying) {
            self.stopMark = NO;
        } else {
            self.stopMark = YES;
        }
    }
}

- (void)playerCore:(id<MDPlayCoreAbilityProtocol>)core resolutionChanged:(NSInteger)currentResolution info:(NSDictionary *)info {
    if (core == self.core) {
        [[MDEventMessageBus universalBus] postEvent:MDPlayEventResolutionChanged withObject:@[@(currentResolution), info] rightNow:YES];
    }
}

@end
