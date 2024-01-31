// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>



@interface VEVideoStartTimeRecorder : NSObject

+ (instancetype)sharedInstance;

- (void)record:(NSString *)key startTime:(NSTimeInterval)time;

- (NSTimeInterval)startTimeFor:(NSString *)key;

- (void)removeRecord:(NSString *)key;

- (void)cleanCache;


@end


