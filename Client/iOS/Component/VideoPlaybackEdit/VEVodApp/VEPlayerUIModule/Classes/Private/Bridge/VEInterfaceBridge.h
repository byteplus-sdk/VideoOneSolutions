// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEEventMessageBus.h"

@protocol VEPlayInfoProtocol <NSObject>

@required
- (NSInteger)currentPlaybackState;
 
- (NSTimeInterval)duration;

- (NSTimeInterval)playableDuration;

- (NSTimeInterval)currentPlaybackTime;

- (NSString *)title;
    
- (BOOL)loopPlayOpen;

- (CGFloat)currentPlaySpeed;

- (NSString *)currentPlaySpeedForDisplay;

- (NSArray *)playSpeedSet;

- (NSInteger)currentResolution;

- (NSArray *)resolutionSet;

- (NSString *)currentResolutionForDisplay;

- (CGFloat)currentVolume;

- (CGFloat)currentBrightness;

- (NSTimeInterval)durationWatched;

@property(nonatomic, assign, readonly) BOOL seeking;

@end

/**
 * @brief Bridge for real player, we can visit and modify basic properties or interfaces for current player.
 * Still, we use VEEventPoster to manage this bridge without directly access. Because we need some more properties
 * about player, so we use combination design mode.
 * We use eventMessageBus to deliver message and take actions.
 */


@interface VEInterfaceBridge : NSObject <VEPlayInfoProtocol>

@property (nonatomic, weak, readonly) VEEventMessageBus *eventMessageBus;

- (instancetype)initWithEventMessageBus:(VEEventMessageBus *)eventMessageBus;

- (void)destroyUnit;

@end
