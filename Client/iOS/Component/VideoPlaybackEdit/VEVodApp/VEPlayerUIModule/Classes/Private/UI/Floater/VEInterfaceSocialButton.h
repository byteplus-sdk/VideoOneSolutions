//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEInterfaceSocialButton : UIControl

@property (nonatomic, nullable, copy) UIImage *image;

@property (nonatomic, nullable, copy) NSString *title;

@property (nonatomic, assign, readonly) UILayoutConstraintAxis axis;

- (instancetype)initWithFrame:(CGRect)frame axis:(UILayoutConstraintAxis)axis;

@end

NS_ASSUME_NONNULL_END
