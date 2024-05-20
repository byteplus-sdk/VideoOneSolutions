// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushBaseNewViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class VELPushImageUtils;
@interface VELPushInnerNewViewController : VELPushBaseNewViewController
#ifdef VEL_PUSH_MODULE_NEW_API_ENABLE
@property (nonatomic, strong, readonly) VeLivePusher *pusher;
@property (nonatomic, strong, readonly) VELPushImageUtils *imageUtils;
@property (nonatomic, assign) VeLiveVideoCaptureType lastVideoCaptureType;
@property (nonatomic, assign) VeLiveAudioCaptureType lastAudioCaptureType;
#endif
@end

NS_ASSUME_NONNULL_END
