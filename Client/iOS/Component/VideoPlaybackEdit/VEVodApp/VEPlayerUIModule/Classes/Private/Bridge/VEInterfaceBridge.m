// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceBridge.h"
#import "VEEventConst.h"
#import "VEPlayProtocol.h"

NSString *const VEPlayEventStateChanged = @"VEPlayEventStateChanged";

NSString *const VEPlayEventTimeIntervalChanged = @"VEPlayEventTimeIntervalChanged";

@interface VEInterfaceBridge () <VEPlayCoreCallBackAbilityProtocol>

@property (nonatomic, weak) id<VEPlayCoreAbilityProtocol> core;

@property (nonatomic, assign) BOOL stopMark;

@property (nonatomic, weak) VEEventMessageBus *eventMessageBus;

@end

@implementation VEInterfaceBridge

@synthesize seeking;

- (instancetype)initWithEventMessageBus:(VEEventMessageBus *)eventMessageBus {
    self = [super init];
    if (self) {
        self.eventMessageBus = eventMessageBus;
        [self registEvents];
    }
    return self;
}

- (void)destroyUnit {
    [self.eventMessageBus destroyUnit];
}

#pragma mark ----- Action / Message

- (void)registEvents {
    [self.eventMessageBus registEvent:VETaskPlayCoreTransfer withAction:@selector(bindPlayerCore:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayEventPlay withAction:@selector(playAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayEventPause withAction:@selector(pauseAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayEventSeek withAction:@selector(seekAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayEventChangeLoopPlayMode withAction:@selector(changeLoopPlayModeAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayEventChangePlaySpeed withAction:@selector(changePlaySpeedAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayEventChangeResolution withAction:@selector(changeResolutionAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEUIEventBrightnessIncrease withAction:@selector(changeBrightnessAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEUIEventVolumeIncrease withAction:@selector(changeVolumeAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayEventSeeking withAction:@selector(seekingAction:) ofTarget:self];
}

- (void)bindPlayerCore:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id core = paramDic.allValues.firstObject;
        if ([core conformsToProtocol:@protocol(VEPlayCoreAbilityProtocol)]) {
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

- (void)seekingAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            seeking = ((NSNumber *)value).boolValue;
        }
    }
}

- (void)changeLoopPlayModeAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)param;
        NSNumber *num = dic.allValues.firstObject;
        BOOL loop = num.boolValue;
        if ([self.core respondsToSelector:@selector(setLooping:)]) {
            [self.core setLooping:loop];
        }
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
                [self.eventMessageBus postEvent:VEPlayEventPlaySpeedChanged withObject:nil rightNow:YES];
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
            CGFloat changeValue = [(NSNumber *)value floatValue] + [UIScreen mainScreen].brightness;
            [[UIScreen mainScreen] setBrightness:MIN(MAX(changeValue, 0.0), 1.0)];
        } else if ([value isKindOfClass:[NSValue class]]) {
            NSValue *v = (NSValue *)value;
            CGPoint p = v.CGPointValue;
            [[UIScreen mainScreen] setBrightness:MIN(MAX(p.x, 0.0), 1.0)];
        }
    }
}


#pragma mark ----- VEInfoProtocol, Static Info / Poster

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

- (NSTimeInterval)currentPlaybackTime {
    if ([self.core respondsToSelector:@selector(currentPlaybackTime)]) {
        return [self.core currentPlaybackTime];
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

#pragma mark ----- VEPlayCoreCallBackAbilityProtocol

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core playbackStateDidChanged:(VEPlaybackState)currentState info:(NSDictionary *)info {
    if (core == self.core) {
        [self.eventMessageBus postEvent:VEPlayEventStateChanged withObject:@[@(currentState), info] rightNow:YES];
    }
}

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core playTimeDidChanged:(NSTimeInterval)interval info:(NSDictionary *)info {
    if (core == self.core) {
        if (!self.stopMark && !self.seeking) {
            [self.eventMessageBus postEvent:VEPlayEventTimeIntervalChanged withObject:@(interval) rightNow:YES];
        }
        VEPlaybackState state = [self currentPlaybackState];
        if (state == VEPlaybackStatePlaying) {
            self.stopMark = NO;
        } else {
            self.stopMark = YES;
        }
    }
}

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core resolutionChanged:(NSInteger)currentResolution info:(NSDictionary *)info {
    if (core == self.core) {
        [self.eventMessageBus postEvent:VEPlayEventResolutionChanged withObject:@[@(currentResolution), info] rightNow:YES];
    }
}

@end
