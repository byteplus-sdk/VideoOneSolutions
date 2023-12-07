//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextInputView : UIView

@property (nullable, nonatomic, copy) UIColor *borderColor;

@property (nonatomic, strong, readonly) UITextField *textField;

@property (nonatomic, assign) UIEdgeInsets contentInsets;

@property (nonatomic, nonnull, copy) void (^didBeginEditing)(void);

@property (nonatomic, nonnull, copy) void (^didEndEditing)(void);

@property (nonatomic, nonnull, copy) void (^clickSenderBlock)(NSString *text);

- (instancetype)initWithMessage:(NSString *)message;

- (void)show;

- (void)dismiss:(void (^_Nullable)(NSString *text))block;

@end

NS_ASSUME_NONNULL_END
