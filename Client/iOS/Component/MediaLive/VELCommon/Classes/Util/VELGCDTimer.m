// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELGCDTimer.h"
typedef NS_ENUM(NSInteger,VELGCDTimerStatus) {
    VELGCDTimerStatusIng,
    VELGCDTimerStatusSuspend,
    VELGCDTimerStatusStop,
};

@interface VELGCDTimer ()
@property (nonatomic, strong) dispatch_source_t sourceTimer;
@property (nonatomic, strong) dispatch_semaphore_t timerLock;
@property (nonatomic, assign) BOOL isFiring;
@property (nonatomic, assign) VELGCDTimerStatus timerStatus;
@end
@implementation VELGCDTimer

- (instancetype)init {
    self = [super init];
    if (self) {
        _timerStatus = VELGCDTimerStatusStop;
    }
    return self;
}

- (void)start:(float)interval block:(void (^)(BOOL))block {
    if (_timerStatus != VELGCDTimerStatusStop) {
        if (block) {
            block(NO);
        }
        return;
    }
    dispatch_time_t startSec = dispatch_walltime(NULL, (int64_t)(0.0 * NSEC_PER_SEC));
    uint64_t timeInterval = (uint64_t)(interval * NSEC_PER_SEC);
    dispatch_source_set_timer(self.sourceTimer, startSec, timeInterval, 0);
    dispatch_source_set_event_handler(self.sourceTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            block(YES);
        });
    });
    [self resumeTime];
}

- (void)resume {
    if (_timerStatus != VELGCDTimerStatusSuspend) {
        return;
    }
    [self resumeTime];
}

- (void)resumeTime {
    dispatch_semaphore_wait(self.timerLock, DISPATCH_TIME_FOREVER);
    if (self.sourceTimer) {
        dispatch_resume(self.sourceTimer);
        _isFiring = YES;
        _timerStatus = VELGCDTimerStatusIng;
    }
    dispatch_semaphore_signal(self.timerLock);
}

- (void)suspend {
    if (_timerStatus != VELGCDTimerStatusIng) {
        return;
    }
    dispatch_semaphore_wait(self.timerLock, DISPATCH_TIME_FOREVER);
    if (self.sourceTimer) {
        dispatch_suspend(self.sourceTimer);
        _isFiring = NO;
        _timerStatus = VELGCDTimerStatusSuspend;
    }
    dispatch_semaphore_signal(self.timerLock);
}

- (void)stop {
    if (_timerStatus != VELGCDTimerStatusIng) {
        return;
    }
    dispatch_semaphore_wait(self.timerLock, DISPATCH_TIME_FOREVER);
    if (self.sourceTimer) {
        dispatch_source_cancel(self.sourceTimer);
        _timerStatus = VELGCDTimerStatusStop;
        _isFiring = NO;
        self.sourceTimer = NULL;
    }
    dispatch_semaphore_signal(self.timerLock);
}


- (void)dealloc {
    if (self.sourceTimer) {
        if (self.isFiring == NO) {
            dispatch_resume(self.sourceTimer);
        }
    }
    [self stop];
}


#pragma mark - Getter

- (dispatch_source_t)sourceTimer {
    if (_sourceTimer == nil) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
        _sourceTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    }
    return _sourceTimer;
}

- (dispatch_semaphore_t)timerLock {
    if (_timerLock == nil) {
        _timerLock = dispatch_semaphore_create(1);
    }
    return _timerLock;
}
@end
