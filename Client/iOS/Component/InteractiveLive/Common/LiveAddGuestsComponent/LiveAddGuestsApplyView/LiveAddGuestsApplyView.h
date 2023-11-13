//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveUserModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveAddGuestsApplyView : UIView

@property (nonatomic, strong) LiveUserModel *userModel;

@property (nonatomic, copy) void (^clickApplyBlock)(void);

@property (nonatomic, copy) void (^clickCancelBlock)(void);

- (void)updateApplying;

- (void)resetStatus;

@end

NS_ASSUME_NONNULL_END
