// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEEventPoster.h"
#import "VEEventPoster+Private.h"
#import "VEInterfaceBridge.h"

@interface VEEventPoster ()

@property (nonatomic, assign) BOOL screenIsLocking;

@property (nonatomic, assign) BOOL screenIsClear;

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

@end
