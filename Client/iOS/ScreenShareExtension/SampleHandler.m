// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "SampleHandler.h"
#import <Appconfig/BuildConfig.h>
#import <VeLiveReplayKitExtension/VeLiveReplayKitExtension.h>
@interface SampleHandler()<VeLiveReplayKitExtensionDelegate>

@end

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    [[VeLiveReplayKitExtension sharedInstance] startWithAppGroup:APP_GROUP_ID delegate:self];
}

- (void)broadcastPaused {
    [[VeLiveReplayKitExtension sharedInstance] broadcastPaused];
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    [[VeLiveReplayKitExtension sharedInstance] broadcastResumed];
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    [[VeLiveReplayKitExtension sharedInstance] broadcastFinished];
    // User has requested to finish the broadcast.
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    [[VeLiveReplayKitExtension sharedInstance] processSampleBuffer:sampleBuffer withType:sampleBufferType];
}


- (void)broadcastFinished:(VeLiveReplayKitExtension *)broadcast reason:(VeLiveReplayKitExtensionReason)reason {
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

@end
