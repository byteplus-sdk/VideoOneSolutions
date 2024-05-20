// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (VELAdd)

@property(nonatomic, assign) UIEdgeInsets hitEdgeInsets;
@property(nonatomic, assign) CGFloat hitScale;
@property(nonatomic, assign) CGFloat hitWidthScale;

@property(nonatomic, assign) CGFloat hitHeightScale;
@property (nonatomic, assign) BOOL preventsTouchEvent;
@end

NS_ASSUME_NONNULL_END
