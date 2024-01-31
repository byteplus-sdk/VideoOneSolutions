// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Fillet)

- (void)filletWithRadius:(CGFloat)radius corner:(UIRectCorner)corner;

- (void)removeAllAutoLayout;

@end

NS_ASSUME_NONNULL_END
