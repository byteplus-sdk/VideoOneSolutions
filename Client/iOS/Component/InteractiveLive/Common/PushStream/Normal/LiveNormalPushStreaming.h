//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#ifndef LiveNormalPushStreaming_h
#define LiveNormalPushStreaming_h

#import "LiveNormalStreamConfig.h"

@protocol ByteRTCVideoSinkDelegate;
@protocol ByteRTCAudioFrameObserver;

@protocol LiveNormalPushStreaming

@property (nonatomic, copy) void (^streamLogCallback)(NSInteger bitrate, NSDictionary *log, NSDictionary *extra);

/**
 * @brief start single live streaming without pushing rtc.
 */

- (void)startNormalStreaming;

/**
 * @brief stop single live streaming.
 */

- (void)stopNormalStreaming;

- (void)cameraStateChanged:(BOOL)cameraOn;

/**
 * @brief When the anchor starts linking, we should turn off livecore's reconnect logic in case of livecore fails to
 * push stream to CDN and trigger this logic, and then retake the priority.
 * @param turnOn when YES, we should config maxReconnectTime = 9, and zero for NO.
 */

- (void)toggleReconnectCapability:(BOOL)turnOn;



@end

#endif /* LiveNormalPushStreaming_h */
