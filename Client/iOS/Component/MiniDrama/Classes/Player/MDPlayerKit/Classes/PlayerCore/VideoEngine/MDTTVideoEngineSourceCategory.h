// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import Foundation;
#import <TTSDKFramework/TTSDKFramework.h>

@interface TTVideoEngineVidSource (MDVidSource)

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cover;
// Playback start time in seconds; convert to milliseconds when preloading.
@property (nonatomic, assign) NSTimeInterval startTime;

@end

@interface TTVideoEngineUrlSource (MDUrlSource)

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, assign) NSTimeInterval startTime;

@end

@interface TTVideoEngineVideoModelSource (MDVideoModelSource)
@property (nonatomic, assign) NSTimeInterval startTime;
@end

FOUNDATION_EXPORT NSTimeInterval MDSourceStartTime(id<TTVideoEngineMediaSource> source);
// Compare only in memory; never log auth data. A new start time, resolution or auth creates a new task.
FOUNDATION_EXPORT NSString *MDSourceIdentity(id<TTVideoEngineMediaSource> source);

// Each page owns its loader and cancels only the SDK items it created.
@interface MDCacheLoader : NSObject
- (BOOL)preload:(id<TTVideoEngineMediaSource>)source
         bytes:(NSInteger)bytes
    completion:(void (^ _Nullable)(NSError * _Nullable error))completion;
- (void)stopTask:(id<TTVideoEngineMediaSource>)source;
- (void)stopAll;
@end
