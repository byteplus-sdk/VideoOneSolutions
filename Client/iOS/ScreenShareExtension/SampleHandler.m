// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "SampleHandler.h"
#import <Appconfig/BuildConfig.h>
#import <BytePlusRTCScreenCapturer/ByteRTCScreenCapturerExt.h>

@interface SampleHandler()<ByteRtcScreenCapturerExtDelegate>

@property (nonatomic, copy) NSString* stopMessage;

@property (nonatomic, copy) NSString* shareType;

@end

@implementation SampleHandler

- (instancetype)init {
    NSLog(@"[ScreenShare] init");
    self = [super init];
    if (self) {
        _stopMessage = @"stopShare";
        _shareType = @"";
    }
    return self;
}

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    NSLog(@"[ScreenShare] broadcastStartedWithSetupInfo setupInfo:%@", setupInfo);  
    NSUserDefaults  *screenShareUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
    _shareType = [screenShareUserDefaults stringForKey:@"shareType"];
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    [[ByteRtcScreenCapturerExt shared] startWithDelegate:self groupId:APP_GROUP_ID];
    [screenShareUserDefaults setValue:@"" forKey:@"shareType"];
    [screenShareUserDefaults synchronize];
}

- (void)broadcastPaused {
    NSLog(@"[ScreenShare] broadcastPaused");
    if (self.shareType && [self.shareType isEqualToString:@"rtc"]) {
        return;
    }
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    NSLog(@"[ScreenShare] broadcastResumed");
    if (self.shareType && [self.shareType isEqualToString:@"rtc"]) {
        return;
    }
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    NSLog(@"[ScreenShare] broadcastFinished");
    // User has requested to finish the broadcast.
    [[ByteRtcScreenCapturerExt shared] stop];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    [[ByteRtcScreenCapturerExt shared] processSampleBuffer:sampleBuffer withType:sampleBufferType];
}

#pragma mark- ByteRtcScreenCapturerExtDelegate

- (void)onNotifyAppRunning {
    NSLog(@"[ScreenShare] onNotifyAppRunning");
    
}

- (void)onQuitFromApp {
    [self finishBroadcastWithError:[NSError errorWithDomain:RPRecordingErrorDomain
                                                       code:RPRecordingErrorUserDeclined
                                                   userInfo:@{
        NSLocalizedFailureReasonErrorKey : self.stopMessage,
    }]];
}

- (void)onReceiveMessageFromApp:(nonnull NSData *)message {
    NSLog(@"[ScreenShare] onReceiveMessageFromApp message:%@", message);
    self.stopMessage = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
}

- (void)onSocketConnect {
    NSLog(@"[ScreenShare] onSocketConnect");
}

- (void)onSocketDisconnect {
    NSLog(@"[ScreenShare] onSocketDisconnect");
    [[ByteRtcScreenCapturerExt shared] stop];
    [self onQuitFromApp];
}

@end
