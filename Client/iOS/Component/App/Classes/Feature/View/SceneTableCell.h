// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <ToolKit/BaseSceneEntrance.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SceneTableCell : UITableViewCell
@property (nonatomic, strong) BaseSceneEntrance *model;
@property (nonatomic, copy) void (^goAction)(SceneTableCell *cell, BaseSceneEntrance *model);
@end

NS_ASSUME_NONNULL_END
