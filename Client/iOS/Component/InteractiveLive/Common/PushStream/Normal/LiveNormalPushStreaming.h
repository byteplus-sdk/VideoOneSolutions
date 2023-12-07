//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#ifndef LiveNormalPushStreaming_h
#define LiveNormalPushStreaming_h

#import "LiveNormalStreamConfig.h"

@protocol ByteRTCVideoSinkDelegate;
@protocol ByteRTCAudioFrameObserver;

@protocol LiveNormalPushStreaming <NSObject, ByteRTCVideoSinkDelegate, ByteRTCAudioFrameObserver>

@property (nonatomic, copy) void (^streamLogCallback)(NSInteger bitrate, NSDictionary *log, NSDictionary *extra);

- (void)startNormalStreaming;

- (void)stopNormalStreaming;

- (void)cameraStateChanged:(BOOL)cameraOn;

@end

#endif /* LiveNormalPushStreaming_h */
