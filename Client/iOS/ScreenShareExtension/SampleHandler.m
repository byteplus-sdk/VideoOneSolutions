// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "SampleHandler.h"
#import <Appconfig/BuildConfig.h>
#import <VeLiveReplayKitExtension/VeLiveReplayKitExtension.h>
#import <BytePlusRTCScreenCapturer/ByteRTCScreenCapturerExt.h>

@interface SampleHandler()<VeLiveReplayKitExtensionDelegate, ByteRtcScreenCapturerExtDelegate>

@property (nonatomic, copy) NSString* stopMessage;

@property (nonatomic, copy) NSString* shareType;

@end

@implementation SampleHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        _stopMessage = @"stopShare";
        _shareType = @"";
    }
    return self;
}

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    NSUserDefaults  *screenShareUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
    _shareType = [screenShareUserDefaults stringForKey:@"shareType"];
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    if (self.shareType && [self.shareType isEqualToString:@"rtc"]) {
        [[ByteRtcScreenCapturerExt shared] startWithDelegate:self groupId:APP_GROUP_ID];
        [screenShareUserDefaults setValue:@"" forKey:@"shareType"];
        [screenShareUserDefaults synchronize];
    } else {
        [[VeLiveReplayKitExtension sharedInstance] startWithAppGroup:APP_GROUP_ID delegate:self];
    }
}

- (void)broadcastPaused {
    if (self.shareType && [self.shareType isEqualToString:@"rtc"]) {
        return;
    }
    [[VeLiveReplayKitExtension sharedInstance] broadcastPaused];
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    if (self.shareType && [self.shareType isEqualToString:@"rtc"]) {
        return;
    }
    [[VeLiveReplayKitExtension sharedInstance] broadcastResumed];
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    if (self.shareType && [self.shareType isEqualToString:@"rtc"]) {
        [[ByteRtcScreenCapturerExt shared] stop];
    } else {
        [[VeLiveReplayKitExtension sharedInstance] broadcastFinished];
    }
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    if (self.shareType && [self.shareType isEqualToString:@"rtc"]) {
        [[ByteRtcScreenCapturerExt shared] processSampleBuffer:sampleBuffer withType:sampleBufferType];
    } else {
        [[VeLiveReplayKitExtension sharedInstance] processSampleBuffer:sampleBuffer withType:sampleBufferType];
    }
}


- (void)broadcastFinished:(VeLiveReplayKitExtension *)broadcast reason:(VeLiveReplayKitExtensionReason)reason {
    if (self.shareType && [self.shareType isEqualToString:@"rtc"]) {
        return;
    }
    NSString *tip = @"";
    switch (reason) {
        case VeLiveReplayKitExtensionReasonMainStop:
            tip = @"main app stop screen capture";
            break;
    }

    NSError *error = [NSError errorWithDomain:NSStringFromClass(self.class)
                                             code:0
                                         userInfo:@{
                                             NSLocalizedFailureReasonErrorKey:tip
                                         }];
    [self finishBroadcastWithError:error];

}

#pragma mark- ByteRtcScreenCapturerExtDelegate

- (void)onNotifyAppRunning {
    
}

- (void)onQuitFromApp {
    [self finishBroadcastWithError:[NSError errorWithDomain:RPRecordingErrorDomain
                                                       code:RPRecordingErrorUserDeclined
                                                   userInfo:@{
        NSLocalizedFailureReasonErrorKey : self.stopMessage,
    }]];
}

- (void)onReceiveMessageFromApp:(nonnull NSData *)message {
    self.stopMessage = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
}

- (void)onSocketConnect {
    
}

- (void)onSocketDisconnect {
    [[ByteRtcScreenCapturerExt shared] stop];
    [self onQuitFromApp];
}

@end
