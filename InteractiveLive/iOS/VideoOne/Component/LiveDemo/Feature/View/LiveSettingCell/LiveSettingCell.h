// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LiveSettingCellType) {
    LiveSettingRTMPullStreaming          = 2,
    LiveSettingRTMPushStreaming  = 1,
    LiveSettingABR        = 3,
};



@protocol LiveSettingCellDelegate <NSObject>

- (void) saveSettingInfo:(LiveSettingCellType) cellType isOn:(BOOL)isOn;

@end

@interface LiveSettingCell : UITableViewCell

@property (nonatomic, assign) LiveSettingCellType cellType;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, weak) id<LiveSettingCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
