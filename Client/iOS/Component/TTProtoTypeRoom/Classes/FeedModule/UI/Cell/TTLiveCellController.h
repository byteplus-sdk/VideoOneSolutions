// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "TTPageViewController.h"
#import "TTLivePlayerManager.h"

@class TTMixModel;
@class TTLiveCellController;

NS_ASSUME_NONNULL_BEGIN

@interface TTLiveCellController : UIViewController <TTPageItem, TTLiveCellProtocol>

@property (nonatomic, strong) TTMixModel *mixModel;


@end

NS_ASSUME_NONNULL_END
