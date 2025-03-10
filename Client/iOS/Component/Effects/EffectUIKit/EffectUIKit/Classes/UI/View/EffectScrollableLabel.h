// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef EffectScrollableLabel_h
#define EffectScrollableLabel_h

#import <UIKit/UIKit.h>

@interface EffectScrollableLabel : UIView

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) BOOL scrollable;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@end

#endif /* EffectScrollableLabel_h */
