// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BaseVideoModel;

extern NSString *const PlayListTableCellIdentify;
extern NSString *const PlayListFloatTableCellIdentify;

@interface PlayListCell : UITableViewCell

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, strong) BaseVideoModel *model;

@end

NS_ASSUME_NONNULL_END
