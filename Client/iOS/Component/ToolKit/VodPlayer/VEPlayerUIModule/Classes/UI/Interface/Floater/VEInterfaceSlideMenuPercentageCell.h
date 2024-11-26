// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEInterfaceSlideMenuPercentageCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImgView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) CGFloat percentage;

- (void)updateCellWidth;

@end

NS_ASSUME_NONNULL_END
