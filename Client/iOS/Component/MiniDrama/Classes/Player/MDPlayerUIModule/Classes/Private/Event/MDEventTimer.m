// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDEventTimer.h"
#import <objc/message.h>

@interface MDEventTimerProxy : NSObject

@property (nonatomic, weak)   id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) NSInteger interval;
@property (nonatomic, assign) NSInteger timeSpan;
@property (nonatomic, copy) void (^completion)(void);

+ (instancetype)proxyWithTarget:(id)target selector:(SEL)selector interval:(NSInteger)interval;

@end

@implementation MDEventTimerProxy

+ (instancetype)proxyWithTarget:(id)target selector:(SEL)selector interval:(NSInteger)interval {
    MDEventTimerProxy *proxy = [[MDEventTimerProxy alloc] init];
    proxy.target = target;
    proxy.selector = selector;
    proxy.interval = interval;
    proxy.timeSpan = 0;
    proxy.completion = ^{
        IMP imp = [target methodForSelector:selector];
        void (*func)(id, SEL) = (void *)imp;
        func(target, selector);
    };
    return proxy;
}

@end

@interface MDEventTimer ()

@property (nonatomic, strong) NSMutableArray *proxys;

@property (nonatomic, assign) NSInteger interval;

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation MDEventTimer

static id sharedInstance = nil;
+ (instancetype)universalTimer {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

+ (void)destroyUnit {
    [sharedInstance stop];
}


#pragma mark ----- Public Func

- (void)addTarget:(id)target action:(SEL)selector loopInterval:(NSInteger)interval {
    [sharedInstance addResponder:target selector:selector interval:interval];
}

- (void)removeTarget:(id)target ofAction:(SEL)selector {
    [sharedInstance removeResponder:target selector:selector];
}


#pragma mark ----- Private Func

- (void)addResponder:(id)responder selector:(SEL)selector interval:(NSInteger)interval {
    @synchronized(sharedInstance) {
        if (![responder respondsToSelector:selector] || interval <= 0) {
            return;
        }
        NSString *selectorStr = NSStringFromSelector(selector);
        for (MDEventTimerProxy *proxy in self.proxys) {
            NSString *proxySelectorStr = NSStringFromSelector(proxy.selector);
            if (proxy.target == responder && [proxySelectorStr isEqualToString:selectorStr] ) {
                return;
            }
        }
        [self.proxys addObject:[MDEventTimerProxy proxyWithTarget:responder selector:selector interval:interval]];
        [self restart];
    }
}

- (void)removeResponder:(id)responder selector:(SEL)selector {
    @synchronized(self) {
        NSString *selectorStr = NSStringFromSelector(selector);
        NSMutableArray *removedProxys = [NSMutableArray array];
        for (MDEventTimerProxy *proxy in self.proxys) {
            NSString *proxySelectorStr = NSStringFromSelector(proxy.selector);
            if (proxy.target == responder && [proxySelectorStr isEqualToString:selectorStr] ) {
                [removedProxys addObject:proxy];
            }
        }
        [self removeProxys:removedProxys];
    }
}

- (void)removeProxys:(NSArray *)proxys {
    @synchronized(self) {
        [self.proxys removeObjectsInArray:proxys];
        if (self.proxys.count == 0) {
            [self stop];
            return;
        }
        if (proxys.count > 0) {
            [self restart];
        }
    }
}


#pragma mark ----- Timer

- (void)restart {
    NSInteger interval = [self interval];
    if (_timer && interval == _interval) {
        return;
    }
    _interval = interval;
    [self stop];
    if (_interval <= 0) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(DISPATCH_TIME_NOW, 0), _interval, 0);
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf timerFire];
        });
    });
    dispatch_resume(_timer);
}

- (void)stop {
    if (!_timer) {
        return;
    }
    dispatch_source_cancel(_timer);
    _timer = nil;
}

- (void)timerFire {
    @synchronized(self) {
        NSMutableArray *removedProxys = [NSMutableArray array];
        for (MDEventTimerProxy *proxy in _proxys) {
            if (!proxy.target || ![proxy.target respondsToSelector:proxy.selector]) {
                [removedProxys addObject:proxy];
                continue;
            }
            if (proxy.timeSpan >= proxy.interval) {
                proxy.completion();
                proxy.timeSpan = 0;
            }
            proxy.timeSpan += _interval;
        }
        [self removeProxys:removedProxys];
    }
}


#pragma mark ----- Tool

- (NSInteger)commonDivisor:(NSInteger)num1 num2:(NSInteger)num2 {
    if (0 == num2) return num1;
    return [self commonDivisor:num2 num2:num1 % num2];
}

- (NSInteger)interval {
    NSInteger interval = -1;
    if (self.proxys.count == 1) {
        interval = ((MDEventTimerProxy *)_proxys[0]).interval;
    } else if (self.proxys.count > 1) {
        MDEventTimerProxy *proxy0 = self.proxys[0];
        MDEventTimerProxy *proxy1 = self.proxys[1];
        interval = [self commonDivisor:proxy0.interval num2:proxy1.interval];
        for (NSInteger index = 2; index < self.proxys.count; ++index) {
            MDEventTimerProxy *proxy = self.proxys[index];
            interval = [self commonDivisor:interval num2:proxy.interval];
        }
    }
    return interval;
}


#pragma mark ----- Lazy Load

- (NSMutableArray *)proxys {
    if (!_proxys) {
        _proxys = [NSMutableArray array];
    }
    return _proxys;
}

- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_queue_create("com.xiaodu.crowdsourcing.timer.service.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _queue;
}

@end

