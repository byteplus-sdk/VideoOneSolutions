// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "BaseViewController.h"
#import "LiveRoomInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveCreateRoomViewController : BaseViewController

@property (nonatomic, copy) void (^hangUpBlock)(void);

@end

NS_ASSUME_NONNULL_END
