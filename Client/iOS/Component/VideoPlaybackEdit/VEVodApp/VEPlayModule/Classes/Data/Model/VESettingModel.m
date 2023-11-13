// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VESettingModel.h"

extern NSString *VESettingDisplayDetailCellReuseID;
extern NSString *VESettingTypeMutilSelectorCellReuseID;
extern NSString *VESettingSwitcherCellReuseID;
extern NSString *VESettingDisplayCellReuseID;

@implementation VESettingModel

@end

@implementation VESettingModel (DisplayCell)

- (NSDictionary *)cellInfo {
    switch (self.settingType) {
        case VESettingTypeDisplay: return @{VESettingDisplayCellReuseID : @"VESettingDisplayCell"};
        case VESettingTypeSwitcher: return @{VESettingSwitcherCellReuseID : @"VESettingSwitcherCell"};
        case VESettingTypeDisplayDetail: return @{VESettingDisplayDetailCellReuseID : @"VESettingDisplayDetailCell"};
        case VESettingTypeMutilSelector: return @{VESettingTypeMutilSelectorCellReuseID : @"VESettingTypeMutilSelectorCell"};
    }
    return @{@"UITableViewCell" : @""};
}

- (CGFloat)cellHeight {
    switch (self.settingType) {
        case VESettingTypeSwitcher:
        case VESettingTypeMutilSelector:
        case VESettingTypeDisplay: return 55.0;
        case VESettingTypeDisplayDetail: return 95.0;
    }
    return 55.0;
}

@end
