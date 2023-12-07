//
//  VESettingEntranceCell.h
//  VideoPlaybackEdit
//
//  Created by bytedance on 2023/11/2.
//

#import "VESettingCell.h"

@class VESettingModel;

extern NSString *VESettingEntranceCellCellReuseID;

@interface VESettingEntranceCell : VESettingCell

@property (nonatomic, strong) VESettingModel *settingModel;

@end


