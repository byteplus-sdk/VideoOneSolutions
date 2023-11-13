//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRTCManager.h"
#import "LiveUserModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveCoHostRoomItemView : UIView

@property (nonatomic, strong) LiveUserModel *userModel;

- (instancetype)initWithIsOwn:(BOOL)isOwn;

@end

NS_ASSUME_NONNULL_END
