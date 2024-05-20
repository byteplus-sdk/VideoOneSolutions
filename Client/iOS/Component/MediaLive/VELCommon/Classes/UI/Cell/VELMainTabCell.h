// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "UICollectionViewCell+VELAdd.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELMainTabCell : UICollectionViewCell
@property (nonatomic, strong) UIColor *hightlightTextColor;
@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, assign) BOOL textScrollable;
- (void)renderWithTitle:(NSString *)title;
- (void)setTitleLabelFont:(UIFont *)font;
@end

NS_ASSUME_NONNULL_END
