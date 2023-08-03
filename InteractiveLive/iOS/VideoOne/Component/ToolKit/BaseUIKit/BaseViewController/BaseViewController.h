// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>
#import "ToolKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

@property (nonatomic, strong) UIView *navView;

@property (nonatomic, copy) NSString *navTitle;

@property (nonatomic, strong) UIColor *navTitleColor;

@property (nonatomic, copy) NSString *navRightTitle;


@property (nonatomic, strong) UIImage *navLeftImage;

@property (nonatomic, strong) UIImage *navRightImage;

@property (nonatomic, strong) UIView *bgView;

-(void)leftButtonOtherAction;

- (void)rightButtonAction:(BaseButton *)sender;

@end

NS_ASSUME_NONNULL_END
