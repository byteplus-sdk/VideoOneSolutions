// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VELAudioRender : NSObject
+ (instancetype)rendererWithBufferTime:(NSUInteger)bufferTime;
- (instancetype)initWithBufferTime:(NSUInteger)bufferTime;
/// - Parameters:
- (BOOL)setUpWithSampleRate:(int)sampleRate channels:(int)channels bitDepth:(int)bitDepth;
- (void)tearDown;
- (void)renderBytes:(const void *)bytes length:(NSUInteger)length;
- (void)stop;
- (void)flush;
- (void)flushShouldResetTiming:(BOOL)shouldResetTiming;
@property (nonatomic, readonly) NSUInteger currentTime;
@property (nonatomic, readonly, getter=isStarted) BOOL started;
@property (nonatomic, assign, getter=isInterrupted) BOOL interrupted;
@property (nonatomic, assign) double volume;

@end

NS_ASSUME_NONNULL_END
