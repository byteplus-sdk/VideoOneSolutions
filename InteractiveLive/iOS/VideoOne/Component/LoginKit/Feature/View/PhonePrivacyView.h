// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhonePrivacyView : UIView

@property (nonatomic, assign, readonly) BOOL isAgree;

@property (nonatomic, copy) void (^changeAgree)(BOOL isAgree);

@end

NS_ASSUME_NONNULL_END
