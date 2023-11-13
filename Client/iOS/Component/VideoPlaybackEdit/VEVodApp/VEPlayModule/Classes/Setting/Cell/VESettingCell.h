// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import UIKit;

typedef enum: NSUInteger {
    SettingCellCornerStyleUp,
    SettingCellCornerStyleMiddle,
    SettingCellCornerStyleBottom,
    SettingCellCornerStyleFull
} SettingCellCornerStyle;

@interface VESettingCell : UITableViewCell

@property (nonatomic, assign) SettingCellCornerStyle cornerStyle;
@property (nonatomic, strong) UIView *bgView;

@end
