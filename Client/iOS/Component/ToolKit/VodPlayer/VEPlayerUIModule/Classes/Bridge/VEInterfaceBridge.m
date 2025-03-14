// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceBridge.h"
#import "PIPManager.h"
#import "VEEventConst.h"
#import "VEPlayProtocol.h"
#import "VEVideoPlayerController.h"
#import <ToolKit/ToolKit.h>

NSString *const VEPlayEventStateChanged = @"VEPlayEventStateChanged";

NSString *const VEPlayEventLoadStateChanged = @"VEPlayEventLoadStateChanged";

NSString *const VEPlayEventTimeIntervalChanged = @"VEPlayEventTimeIntervalChanged";

NSString *const VEPlayEventPiPStatusChanged = @"VEPlayEventPiPStatusChanged";

@interface VEInterfaceBridge () <VEPlayCoreCallBackAbilityProtocol, PIPManagerDataSourceDelegate>

@property (nonatomic, strong) PIPManager *pipManager;

@property (nonatomic, weak) id<VEPlayCoreAbilityProtocol> core;

@property (nonatomic, assign) BOOL stopMark;

@property (nonatomic, assign) BOOL screenIsLocking;

@property (nonatomic, assign) BOOL screenIsClear;

@property (nonatomic, weak) VEEventMessageBus *eventMessageBus;

@property (nonatomic, strong) NSString *playUrlString;

@property (nonatomic, assign) BOOL isActivePlayLoop;

@end

@implementation VEInterfaceBridge

@synthesize seeking;

- (instancetype)initWithEventMessageBus:(VEEventMessageBus *)eventMessageBus {
    self = [super init];
    if (self) {
        self.eventMessageBus = eventMessageBus;
        [self registEvents];
        [self configPIP];
    }
    return self;
}

- (void)destroyUnit {
    [self.eventMessageBus destroyUnit];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark----- Action / Message

- (void)registEvents {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    [self.eventMessageBus registEvent:VETaskPlayCoreTransfer withAction:@selector(bindPlayerCore:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayEventPlay withAction:@selector(playAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayEventPause withAction:@selector(pauseAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayEventSeek withAction:@selector(seekAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayEventChangeLoopPlayMode withAction:@selector(changeLoopPlayModeAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayEventChangePlaySpeed withAction:@selector(changePlaySpeedAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayEventChangeSubtitle withAction:@selector(changeSubtitleAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayEventChangeResolution withAction:@selector(changeResolutionAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEUIEventBrightnessIncrease withAction:@selector(changeBrightnessAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEUIEventVolumeIncrease withAction:@selector(changeVolumeAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEUIEventSeeking withAction:@selector(seekingAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEUIEventLockScreen withAction:@selector(lockScreenAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEUIEventClearScreen withAction:@selector(clearScreenAction:) ofTarget:self];
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
                [self.pipManager setRate:speed];
                [self.eventMessageBus postEvent:VEPlayEventPlaySpeedChanged withObject:nil rightNow:YES];
            }
        }
    }
}

- (void)changeSubtitleAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id subtitle = paramDic.allValues.firstObject;
        [self.eventMessageBus postEvent:VEPlayEventSmartSubtitleChanged withObject:subtitle rightNow:YES];
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
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.core play];
                });
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

- (void)lockScreenAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            self.screenIsLocking = [value boolValue];
        }
    }
}

- (void)clearScreenAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            self.screenIsClear = [value boolValue];
        }
    }
}

- (void)didBecomeActiveNotification {
    if ([self.core respondsToSelector:@selector(setLooping:)]) {
        [self.core setLooping:self.isActivePlayLoop];
    }
}

- (void)willResignActiveNotification {
    self.isActivePlayLoop = self.core.looping;
    if (self.isActivePlayLoop) {
        if ([self.core respondsToSelector:@selector(setLooping:)]) {
            [self.core setLooping:NO];
        }
    }
}

#pragma mark----- VEInfoProtocol, Static Info / Poster

- (NSInteger)currentPlaybackState {
    if ([self.core respondsToSelector:@selector(currentPlaybackState)]) {
        return [self.core currentPlaybackState];
    } else {
        return NSNotFound;
    }
}

- (NSInteger)currentLoadState {
    if ([self.core respondsToSelector:@selector(currentLoadState)]) {
        return [self.core currentLoadState];
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

- (NSTimeInterval)durationWatched {
    if ([self.core respondsToSelector:@selector(durationWatched)]) {
        return [self.core durationWatched];
    }
    return 0.0;
}

- (void)setScreenIsLocking:(BOOL)screenIsLocking {
    _screenIsLocking = screenIsLocking;
    [self.eventMessageBus postEvent:VEUIEventScreenLockStateChanged withObject:@(screenIsLocking) rightNow:YES];
}

- (void)setScreenIsClear:(BOOL)screenIsClear {
    _screenIsClear = screenIsClear;
    [self.eventMessageBus postEvent:VEUIEventScreenClearStateChanged withObject:@(screenIsClear) rightNow:YES];
}

#pragma mark----- VEPlayCoreCallBackAbilityProtocol

- (void)playerCoreReadyToPlay:(id<VEPlayCoreAbilityProtocol>)core {
    if (core == self.core) {
        [self.pipManager updatePlaybackStatus:YES atRate:[self currentPlaySpeed]];
    }
}

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core playbackStateDidChanged:(VEPlaybackState)currentState info:(NSDictionary *)info {
    if (core == self.core) {
        [self.eventMessageBus postEvent:VEPlayEventStateChanged withObject:@[@(currentState), info] rightNow:YES];
        [self.pipManager updatePlaybackStatus:(currentState == VEPlaybackStatePlaying) atRate:[self currentPlaySpeed]];
        if (currentState == VEPlaybackStateFinished) {
            self.screenIsClear = NO;
        }
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

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core loadStateDidChange:(VEPlaybackLoadState)state {
    if (core == self.core) {
        [self.eventMessageBus postEvent:VEPlayEventLoadStateChanged withObject:@(state) rightNow:YES];
    }
}

#pragma mark - PIP
- (void)configPIP {
    self.pipManager = [[PIPManager alloc] init];
    __weak __typeof(self) wself = self;
    self.pipManager.restoreCompletionBlock = ^(CGFloat progress, BOOL isPlaying) {
        [wself.core seek:progress];
        wself.core.muted = NO;
        if (!isPlaying) {
            [wself.core pause];
        }
    };
    self.pipManager.closeCompletionBlock = ^(CGFloat progress) {
        [wself.core seek:progress];
        wself.core.muted = NO;
        if (progress >= (NSInteger)[wself duration]) {
            [wself.core play];
        } else {
            [wself.core pause];
        }
    };
    self.pipManager.startCompletionBlock = ^{
        wself.core.muted = YES;
    };
}

- (NSInteger)pipStatus {
    return [self.pipManager status];
}

- (void)updatePIPPlayUrl:(NSString *)playUrlString {
    self.playUrlString = playUrlString;
    [self autoEnablePIP:nil];
}

- (void)cancelPreparePIP {
    [self.pipManager cancelPrepare];
    [self.eventMessageBus postEvent:VEPlayEventPiPStatusChanged withObject:@(self.pipManager.status) rightNow:YES];
}

- (BOOL)isEnabledPIP {
    return self.pipManager.enablePictureInPicture;
}

- (void)enablePIP:(void (^)(NSInteger))block {
    [[ToastComponent shareToastComponent] showLoadingWithMessage:LocalizedStringFromBundle(@"vod_pip_toast", @"VodPlayer")];
    self.pipManager.enablePictureInPicture = YES;
    __weak __typeof(self) wself = self;
    [self autoEnablePIP:^(PIPManagerStatus status) {
        [[ToastComponent shareToastComponent] dismiss];
        if (status == PIPManagerStatusStartSuccess) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"vod_pip_toast_successfully", @"VodPlayer")];
        } else {
            wself.pipManager.enablePictureInPicture = NO;
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"vod_pip_toast_failed", @"VodPlayer")];
        }
        if (block) {
            block(status);
        }
    }];
}

- (void)disablePIP {
    [self.core setCloseResumePlay:NO];
    [self.pipManager cancelPrepare];
    self.pipManager.enablePictureInPicture = NO;
    [self.eventMessageBus postEvent:VEPlayEventPiPStatusChanged withObject:@(self.pipManager.status) rightNow:YES];
}

- (void)autoEnablePIP:(void (^)(PIPManagerStatus status))block {
    if (self.pipManager.enablePictureInPicture && self.playUrlString) {
        CGFloat interval = [self.core currentPlaybackTime];
        __weak __typeof(self) wself = self;
        self.pipManager.dataSource = self;
        [self.pipManager prepare:[self.core.playerView superview]
                        videoURL:self.playUrlString
                        interval:interval
                      completion:^(PIPManagerStatus status) {
            if (status == PIPManagerStatusStartSuccess) {
                [wself.core setCloseResumePlay:YES];
            }
            if (block) {
                block(status);
            }
            [wself.eventMessageBus postEvent:VEPlayEventPiPStatusChanged withObject:@(status) rightNow:YES];
        }];
    } else {
        if (block) {
            block(PIPManagerStatusNone);
        }
        [self.eventMessageBus postEvent:VEPlayEventPiPStatusChanged withObject:@(PIPManagerStatusNone) rightNow:YES];
    }
}

#pragma mark - PIPManagerDataSourceDelegate

- (NSTimeInterval)currentVideoPlaybackProgress:(PIPManager *)manager {
    return [self.core currentPlaybackTime];
}

@end
