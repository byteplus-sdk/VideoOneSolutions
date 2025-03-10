// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef EffectColorItem_h
#define EffectColorItem_h

#import <UIKit/UIKit.h>

@interface EffectColorItem : NSObject

- (instancetype)initWithTitle:(NSString *)title color:(UIColor *)color;
- (instancetype)initWithTitle:(NSString *)title red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat red;
@property (nonatomic, assign) CGFloat green;
@property (nonatomic, assign) CGFloat blue;
@property (nonatomic, assign) CGFloat alpha;

@end

#endif /* EffectColorItem_h */
