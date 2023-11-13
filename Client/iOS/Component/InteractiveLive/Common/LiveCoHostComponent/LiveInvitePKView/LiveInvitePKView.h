//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveUserModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveInvitePKView : UIView

@property (nonatomic, strong) LiveUserModel *fromUserModel;

@property (nonatomic, copy) void (^clickRejectBlcok)(void);

@property (nonatomic, copy) void (^clickAgreeBlcok)(void);

- (void)dismissDelayAfterTenSeconds;

@end

NS_ASSUME_NONNULL_END
