// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoPlayerController+Observer.h"
#import <objc/runtime.h>

@implementation VEVideoPlayerController (Observer)

@dynamic needResumePlay;


#pragma mark - Observer

- (void)addObserver {
    [self removeObserver];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification) name: UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification) name: UIApplicationWillResignActiveNotification object:nil];
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationEnterBackground {
    if (self.closeResumePlay) {
        return;
    }
    if ([self isPlaying]) {
        self.needResumePlay = YES;
    }
    [self.videoEngine pause];
}

- (void)willResignActiveNotification {
    if (self.closeResumePlay) {
        return;
    }
    if ([self isPlaying]) {
        self.needResumePlay = YES;
    }
    [self.videoEngine pause];
}

- (void)didBecomeActiveNotification {
    if (self.closeResumePlay) {
        return;
    }
    if (self.needResumePlay) {
        [self.videoEngine play];
    }
    self.needResumePlay = NO;
}

#pragma mark - Setter && Getter

- (BOOL)needResumePlay {
    return [objc_getAssociatedObject(self, @selector(needResumePlay)) boolValue];
}

- (void)setNeedResumePlay:(BOOL)needResumePlay {
    objc_setAssociatedObject(self, @selector(needResumePlay), @(needResumePlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)closeResumePlay {
    return [objc_getAssociatedObject(self, @selector(closeResumePlay)) boolValue];
}

- (void)setCloseResumePlay:(BOOL)closeResumePlay {
    objc_setAssociatedObject(self, @selector(closeResumePlay), @(closeResumePlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
