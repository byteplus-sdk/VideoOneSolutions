// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceFactory.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEMaskView : UIView <VEInterfaceFactoryProduction>

@property (nonatomic, readonly, strong) CALayer *fullMask;
@property (nonatomic, readonly, strong) CAGradientLayer *topMask;
@property (nonatomic, readonly, strong) CAGradientLayer *bottomMask;

@property (nonatomic, assign) CGFloat topHeight;
@property (nonatomic, assign) CGFloat bottomHeight;

@end

NS_ASSUME_NONNULL_END
