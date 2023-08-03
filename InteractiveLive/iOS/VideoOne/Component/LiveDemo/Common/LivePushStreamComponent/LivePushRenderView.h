// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "LiveRTCManager.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LivePushRenderView : UIView

- (void)updateHostMic:(BOOL)mic camera:(BOOL)camera;

- (void)updateNetworkQuality:(LiveNetworkQualityStatus)status;

- (void)updateLiveTime:(NSDate *)time;

- (void)updateUserModel:(LiveUserModel *)userModel;

@end

NS_ASSUME_NONNULL_END
