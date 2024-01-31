// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEEventPoster.h"
#import "VEEventPoster+Private.h"
#import "VEInterfaceBridge.h"

@interface VEEventPoster ()

@property (nonatomic, strong) VEInterfaceBridge *bridge;

@end

@implementation VEEventPoster

- (instancetype)initWithEventMessageBus:(VEEventMessageBus *)eventMessageBus {
    self = [super init];
    if (self) {
        self.bridge = [[VEInterfaceBridge alloc] initWithEventMessageBus:eventMessageBus];
    }
    return self;
}

- (VEPlaybackState)currentPlaybackState {
    return [self.bridge currentPlaybackState];
}

- (VEPlaybackLoadState)currentLoadState {
    return [self.bridge currentLoadState];
}

- (NSTimeInterval)duration {
    return [self.bridge duration];
}

- (NSTimeInterval)playableDuration {
    return [self.bridge playableDuration];
}

- (NSTimeInterval)currentPlaybackTime {
    return [self.bridge currentPlaybackTime];
}

- (NSString *)title {
    return [self.bridge title];
}

- (BOOL)loopPlayOpen {
    return [self.bridge loopPlayOpen];
}

- (NSArray *)playSpeedSet {
    return [self.bridge playSpeedSet];
}

- (CGFloat)currentPlaySpeed {
    return [self.bridge currentPlaySpeed];
}

- (NSString *)currentPlaySpeedForDisplay {
    return [self.bridge currentPlaySpeedForDisplay];
}

- (NSArray *)resolutionSet {
    return [self.bridge resolutionSet];
}

- (NSInteger)currentResolution {
    return [self.bridge currentResolution];
}

- (NSString *)currentResolutionForDisplay {
    return [self.bridge currentResolutionForDisplay];
}

- (CGFloat)currentVolume {
    return [self.bridge currentVolume];
}

- (CGFloat)currentBrightness {
    return [self.bridge currentBrightness];
}

- (BOOL)isSeekingProgress {
    return self.bridge.seeking;
}

- (NSTimeInterval)durationWatched {
    return [self.bridge durationWatched];
}

- (BOOL)screenIsLocking {
    return [self.bridge screenIsLocking];
}

- (void)setScreenIsLocking:(BOOL)screenIsLocking {
    [self.bridge setScreenIsLocking:screenIsLocking];
}

- (BOOL)screenIsClear {
    return [self.bridge screenIsClear];
}

- (void)setScreenIsClear:(BOOL)screenIsClear {
    [self.bridge setScreenIsClear:screenIsClear];
}

- (PIPManagerStatus)pipStatus {
    return [self.bridge pipStatus];
}

- (void)updatePIPPlayUrl:(NSString *)playUrlString {
    [self.bridge updatePIPPlayUrl:playUrlString];
}

- (void)cancelPreparePIP {
    [self.bridge cancelPreparePIP];
}

- (BOOL)isEnabledPIP {
    return [self.bridge isEnabledPIP];
}

- (void)enablePIP:(void (^)(PIPManagerStatus))block {
    [self.bridge enablePIP:block];
}

- (void)disablePIP {
    [self.bridge disablePIP];
}

@end
