// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChorusEmptyComponent : NSObject

- (instancetype)initWithView:(UIView *)view
                        rect:(CGRect)rect
                       image:(UIImage *)image
                     message:(NSString *)message;

- (void)updateMessageLabelTextColor:(UIColor *)color;

- (void)show;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
