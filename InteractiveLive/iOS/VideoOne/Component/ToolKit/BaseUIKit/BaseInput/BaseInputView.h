// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class BaseInputView;

@protocol BaseInputViewDelegate <NSObject>
@optional
- (void)baseInputView:(BaseInputView *)inputView inputDidChange:(NSString *)newText userInfo:(NSDictionary *_Nullable)userInfo;

- (BOOL)baseInputViewShouldBeginEditing:(BaseInputView *)inputView;

@end
@interface BaseInputView : UIView <UITextFieldDelegate>

@property (nonatomic, weak) id<BaseInputViewDelegate> delegate;

@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, strong, readonly) UIButton *clearBtn;
@property (nonatomic, strong, readonly) UIView *bottomLineView;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, copy) NSString *placeHolder;

- (void)loadSubViews;

- (void)clearInput;

- (NSString *)input;

- (void)setInput:(NSString *)input;

@end

NS_ASSUME_NONNULL_END
