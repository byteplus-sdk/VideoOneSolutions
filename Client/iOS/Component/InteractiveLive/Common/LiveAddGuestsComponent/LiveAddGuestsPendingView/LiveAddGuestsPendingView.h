//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveAddGuestsPendingView : UIView

@property (nonatomic, copy) void (^clickCancelBlock)(BOOL isCancel);

@end

NS_ASSUME_NONNULL_END
