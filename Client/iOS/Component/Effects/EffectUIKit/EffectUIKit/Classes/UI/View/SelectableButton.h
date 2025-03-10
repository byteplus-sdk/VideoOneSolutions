// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef SelectableButton_h
#define SelectableButton_h

#import "BaseSelectableView.h"

@class SelectableButton;
@protocol SelectableButtonDelegate <NSObject>

- (void)selectableButton:(SelectableButton *)button didTap:(UITapGestureRecognizer *)sender;

@end

@interface SelectableButton : UIView

- (instancetype)initWithSelectableConfig:(id<SelectableConfig>)config;

@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, weak) id<SelectableButtonDelegate> delegate;

@property (nonatomic, strong) id<SelectableConfig> selectableConfig;

@property (nonatomic, assign) BOOL isSelected;


@property (nonatomic, assign) BOOL isPointOn;


@property (nonatomic, copy) NSString *title;

@end

#endif /* SelectableButton_h */
