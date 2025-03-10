// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>


@class ButtonView;
@protocol ButtonViewDelegate <NSObject>

- (void)buttonViewDidTap:(ButtonView *)view;

@end

@interface ButtonView : UIView

@property (nonatomic, weak) id<ButtonViewDelegate> delegate;
@property (nonatomic, assign) BOOL selected;

- (void)setSelectImg:(UIImage *)selectImg unselectImg:(UIImage *)unselectImg title:(NSString *)title expand:(BOOL)expand withPoint:(BOOL)withPoint;

- (void)setSelectImg:(UIImage *)selectImg unselectImg:(UIImage *)unselectImg;

- (void)setPointOn:(BOOL)isOn;

@end
