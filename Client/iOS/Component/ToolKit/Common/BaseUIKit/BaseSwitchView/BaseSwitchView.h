// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BaseSwitchViewState) {
    BaseSwitchViewStateLeft,
    BaseSwitchViewStateRight,
};

@interface BaseSwitchView : UIView

- (instancetype)initWithOn:(BOOL)isOn;

@property (nonatomic, copy) void (^didChangeBlock)(BaseSwitchViewState state);

@property (nonatomic, assign, readonly) BaseSwitchViewState state;

@property (nonatomic, strong) UIColor *selectColor;

@property (nonatomic, strong) UIColor *defaultColor;

@end
