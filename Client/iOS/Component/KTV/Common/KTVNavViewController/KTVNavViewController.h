// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KTVNavViewController : UIViewController

@property (nonatomic, copy) NSString *navTitle;

@property (nonatomic, strong) UIView *navView;

@property (nonatomic, strong) UIImageView *topBackgroundImageView;

@property (nonatomic, copy) NSString *rightTitle;

@property (nonatomic, strong) BaseButton *rightButton;

@property (nonatomic, strong) BaseButton *leftButton;

- (void)rightButtonAction:(BaseButton *)sender;

@end

NS_ASSUME_NONNULL_END
