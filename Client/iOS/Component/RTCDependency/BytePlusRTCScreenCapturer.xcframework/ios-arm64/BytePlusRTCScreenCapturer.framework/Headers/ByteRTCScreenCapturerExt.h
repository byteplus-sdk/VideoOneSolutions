/*
 * Copyright (c) 2022 The BytePlusRTC project authors. All Rights Reserved.
*/

#pragma once

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <ReplayKit/ReplayKit.h>

NS_ASSUME_NONNULL_BEGIN
#define BYTE_RTC_EXPORT __attribute__((visibility("default")))

/**
 * 
 * @type callback
 * @brief Screen capture related extension delegate, used for SDK internal capture only. <br>
 *        The SampleHandler generated after the user creates the extension needs to inherit this delegate to implement screen sharing related capabilities. <br>
 * Note: Callback functions are thrown synchronously in a non-UI thread within the SDK. Therefore, you must not perform any time-consuming operations or direct UI operations within the callback function, as this may cause the app to crash.
 */
BYTE_RTC_EXPORT @protocol ByteRtcScreenCapturerExtDelegate <NSObject>

/**
 * 
 * @type api
 * @region Video Management
 * @brief Notify Broadcast Upload Extension to stop capturing and exit.
 * @note After the user calls stopScreenCapture{@link #ByteRTCVideo#stopScreenCapture} on iOS or stopScreenVideoCapture{@link #ByteRTCVideo#stopScreenVideoCapture} on macOS, this method will be triggered to notify the SDK on the Extension side to stop the screen capture.
 */
- (void)onQuitFromApp;

/**
 * 
 * @type api
 * @region Video Management
 * @brief The callback is triggered when the socket receives a message from the App side
 * @param message Message received from the App side
 */
- (void)onReceiveMessageFromApp:(NSData *)message;

/**
 * 
 * @type api
 * @region Video Management
 * @brief This callback is triggered when the socket is disconnected
 */
- (void)onSocketDisconnect;

/**
 * 
 * @type api
 * @region Video Management
 * @brief This callback is triggered when the socket is successfully connected
 */
- (void)onSocketConnect;

/**
 * 
 * @type api
 * @region Video Management
 * @brief This callback is triggered when the App is detected to be making an audio/video call.
 */
- (void)onNotifyAppRunning;
@end


/**
 * 
 * @type keytype
 * @brief Screen capture related extension examples, for SDK internal capture only. <br>
 *        The SampleHandler generated by the user after creating the extesion needs to implement screen sharing related capabilities through this instance.
 */
BYTE_RTC_EXPORT @interface ByteRtcScreenCapturerExt : NSObject

@property (readonly, class) ByteRtcScreenCapturerExt *shared; 

@property (nonatomic, weak, nullable) NSObject<ByteRtcScreenCapturerExtDelegate> *delegate; 

/**
 * 
 * @type api
 * @region Video Management
 * @brief Start screen capture <br>
 *        After the Extension is started, the system will automatically call this method to enable screen capture.
 * @param delegate Callback agent, see ByteRtcScreenCapturerExtDelegate{@link #ByteRtcScreenCapturerExtDelegate}
 * @param groupId The group ID set in App groups
 */
- (void)startWithDelegate:(NSObject<ByteRtcScreenCapturerExtDelegate> *)delegate groupId:(NSString *)groupId;

/**
 * 
 * @type api
 * @region Video Management
 * @brief Stop screen capture <br>
 *        After the Extension is closed, the system will automatically call this method to stop screen capture.
 */
- (void)stop;

/**
 * 
 * @type api
 * @region Video Management
 * @brief Push data captured by Extension
 * @param sampleBuffer Captured data
 * @param sampleBufferType Data type
 */
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType API_AVAILABLE(ios(10));
@end

NS_ASSUME_NONNULL_END