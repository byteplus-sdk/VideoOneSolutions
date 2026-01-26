// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@class VESettingModel;
#import "VESettingCell.h"

extern NSString *VESettingDisplayCellReuseID;

@interface VESettingDisplayCell : VESettingCell

@property (nonatomic, strong) VESettingModel *settingModel;

@end
