// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPopupMenuBaseItem.h"
#import "VELUIButton.h"
NS_ASSUME_NONNULL_BEGIN

@interface VELPopupMenuButtonItem : VELPopupMenuBaseItem
@property(nonatomic, strong, nullable) UIImage *image;
@property(nonatomic, strong, readonly, nonnull) VELUIButton *button;
@property(nonatomic, strong, nullable) UIColor *highlightedBackgroundColor;
@property(nonatomic, assign) CGFloat imageMarginRight;
+ (instancetype)itemWithImage:(nullable UIImage *)image title:(nullable NSString *)title handler:(nullable void (^)(__kindof VELPopupMenuButtonItem *aItem))handler;
@end

NS_ASSUME_NONNULL_END
