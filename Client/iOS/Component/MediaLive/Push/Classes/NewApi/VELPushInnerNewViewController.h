// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushBaseNewViewController.h"
#import <BytePlusRTC/BytePlusRTC.h>

NS_ASSUME_NONNULL_BEGIN
@class VELPushImageUtils;
@interface VELPushInnerNewViewController : VELPushBaseNewViewController
@property (nonatomic, strong, readonly) ByteRTCEngine *rtcEngine;
@property (nonatomic, strong, readonly) ByteRTCRoom *rtcRoom;
@property (nonatomic, strong, readonly) VELPushImageUtils *imageUtils;
@property (nonatomic, assign) ByteRTCCameraID lastCameraId;
@end

NS_ASSUME_NONNULL_END
