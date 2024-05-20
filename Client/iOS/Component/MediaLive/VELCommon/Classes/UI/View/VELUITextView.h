// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class VELUITextView;

@interface VELUITextView : UITextView

@property(nonatomic, copy) NSString *placeholder;

@property(nonatomic, strong) UIColor *placeholderColor;

@property(nonatomic, assign) UIEdgeInsets placeholderMargins;

@end

NS_ASSUME_NONNULL_END
