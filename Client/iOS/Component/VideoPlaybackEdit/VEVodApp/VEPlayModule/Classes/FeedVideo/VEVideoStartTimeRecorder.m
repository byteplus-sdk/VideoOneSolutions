// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoStartTimeRecorder.h"

@interface VEVideoStartTimeRecorder()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *startTimeDictionary;

@end

@implementation VEVideoStartTimeRecorder

+ (instancetype)sharedInstance {
    static VEVideoStartTimeRecorder *recorder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recorder = [VEVideoStartTimeRecorder new];
    });
    return recorder;
}

- (instancetype)init {
    if (self = [super init]) {
        _startTimeDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)record:(NSString *)key startTime:(NSTimeInterval)time {
    if (key.length) {
        [self.startTimeDictionary setValue:[NSNumber numberWithLongLong:time] forKey:key];
    }
}

- (NSTimeInterval)startTimeFor:(NSString *)key {
    if (key) {
        id obj = [self.startTimeDictionary valueForKey:key];
        if ([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *value = (NSNumber *)obj;
            return [value longLongValue];
        }
    }
    return 0;
}

- (void)removeRecord:(NSString *)key {
    if (key) {
        [self.startTimeDictionary removeObjectForKey:key];
    }
}

- (void)cleanCache {
    [self.startTimeDictionary removeAllObjects];
}

@end
