// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef CircleProgressView_h
#define CircleProgressView_h

#import <GLKit/GLKit.h>

@interface CircleProgressView : UIView


- (instancetype)initWithColor:(UIColor *)tintColor size:(CGFloat)size;

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic) CGFloat size;

- (void)startAnimating;
- (void)stopAnimating;

@end

#endif /* CircleProgressView_h */
