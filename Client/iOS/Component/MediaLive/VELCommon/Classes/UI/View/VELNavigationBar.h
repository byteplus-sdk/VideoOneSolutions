// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "VELUIButton.h"
#import "VELUILabel.h"
NS_ASSUME_NONNULL_BEGIN

@interface VELNavigationBar : UIView
@property (nonatomic, assign) CGFloat topSafeMargin;
@property (nonatomic, strong, readonly) VELUIButton *leftButton;
@property (nonatomic, strong, readonly) VELUIButton *rightButton;
@property (nonatomic, strong, readonly) VELUILabel *titleLabel;
@property (nonatomic, strong, readonly) UIView *wrapperView;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, copy) void(^leftEventBlock)(void);
@property (nonatomic, copy) void(^rightEventBlock)(void);
+ (instancetype)navigationBarWithTitle:(NSString *)title;
- (void)onlyShowTitle;
- (void)onlyShowLeftBtn;
@end

NS_ASSUME_NONNULL_END
