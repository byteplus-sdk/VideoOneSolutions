// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELScrollableLabel_h
#define VELScrollableLabel_h

#import <UIKit/UIKit.h>

@interface VELScrollableLabel : UIView

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) BOOL scrollable;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@end

#endif /* VELScrollableLabel_h */
