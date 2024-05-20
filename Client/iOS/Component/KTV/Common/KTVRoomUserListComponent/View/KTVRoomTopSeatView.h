// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const NotificationUpdateSeatSwitch = @"NotificationUpdateSeatSwitch";
static NSString *const NotificationResultSeatSwitch = @"NotificationResultSeatSwitch";

@interface KTVRoomTopSeatView : UIView

@property (nonatomic, copy) void (^clickSwitchBlock)(BOOL isOn);

@end

NS_ASSUME_NONNULL_END
