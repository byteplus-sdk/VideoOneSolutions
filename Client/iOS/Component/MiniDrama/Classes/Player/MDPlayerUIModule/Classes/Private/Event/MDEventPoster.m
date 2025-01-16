//
//  MDEventPoster.m
//  MDPlayerUIModule
//
//  Created by real on 2021/9/7.
//

#import "MDEventPoster.h"
#import "MDEventPoster+Private.h"
#import "MDInterfaceBridge.h"

@interface MDEventPoster ()

/**
 * 这些比较特殊，暂时提供setter & getter，寄存状态,
 * 命名/含义 与BOOL默认值相同
 */
@property (nonatomic, assign) BOOL screenIsLocking;

@property (nonatomic, assign) BOOL screenIsClear;

@end

@implementation MDEventPoster

static id sharedInstance = nil;
+ (instancetype)currentPoster {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

+ (void)destroyUnit {
    @autoreleasepool {
        sharedInstance = nil;
    }
}

- (MDPlaybackState)currentPlaybackState {
    return [[MDInterfaceBridge bridge] currentPlaybackState];
}

- (NSTimeInterval)duration {
    return [[MDInterfaceBridge bridge] duration];
}

- (NSTimeInterval)playableDuration {
    return [[MDInterfaceBridge bridge] playableDuration];
}

- (NSString *)title {
    return [[MDInterfaceBridge bridge] title];
}

- (BOOL)loopPlayOpen {
    return [[MDInterfaceBridge bridge] loopPlayOpen];
}

- (BOOL)srOpen {
    return [[MDInterfaceBridge bridge] srOpen];
}

- (NSArray *)playSpeedSet {
    return [[MDInterfaceBridge bridge] playSpeedSet];
}

- (CGFloat)currentPlaySpeed {
    return [[MDInterfaceBridge bridge] currentPlaySpeed];
}

- (NSString *)currentPlaySpeedForDisplay {
    return [[MDInterfaceBridge bridge] currentPlaySpeedForDisplay];
}

- (NSArray *)resolutionSet {
    return [[MDInterfaceBridge bridge] resolutionSet];
}

- (NSInteger)currentResolution {
    return [[MDInterfaceBridge bridge] currentResolution];
}

- (NSString *)currentResolutionForDisplay {
    return [[MDInterfaceBridge bridge] currentResolutionForDisplay];
}

- (CGFloat)currentVolume {
    return [[MDInterfaceBridge bridge] currentVolume];
}

- (CGFloat)currentBrightness {
    return [[MDInterfaceBridge bridge] currentBrightness];
}

- (BOOL)isPipOpen {
    return [[MDInterfaceBridge bridge] isPipOpen];
}

- (void)enablePIP:(void (^)(BOOL ))block {
    [[MDInterfaceBridge bridge] enablePIP:block];
}

- (void)disablePIP {
    [[MDInterfaceBridge bridge] disablePIP];
}

@end
