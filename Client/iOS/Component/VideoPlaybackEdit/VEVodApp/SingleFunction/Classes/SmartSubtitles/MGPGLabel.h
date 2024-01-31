// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MGPGLabel : UILabel

/// 外描边颜色

@property (strong,nonatomic) UIColor *strokeColor;

/// 外描边宽度

@property (assign,nonatomic) CGFloat strokeWidth;


@end

NS_ASSUME_NONNULL_END
