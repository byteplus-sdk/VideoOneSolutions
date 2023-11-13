// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "LiveRoomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveRoomViewController (Report)

- (void)showBlockAndReportUser:(NSString *)userID;

- (void)showBlockAndReportLiveRoom:(NSString *)roomID;

@end

NS_ASSUME_NONNULL_END
