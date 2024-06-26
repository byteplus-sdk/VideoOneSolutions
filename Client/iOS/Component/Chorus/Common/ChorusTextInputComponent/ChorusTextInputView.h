// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChorusTextInputView : UIView

@property (nonatomic, copy) void (^clickSenderBlock)(NSString *text);

- (instancetype)initWithMessage:(NSString *)message;

- (void)show;

- (void)dismiss:(void (^)(NSString *text))block;

@end

NS_ASSUME_NONNULL_END
