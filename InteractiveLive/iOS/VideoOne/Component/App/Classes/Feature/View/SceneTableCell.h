// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>
#import "SceneButtonModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface SceneTableCell : UITableViewCell
@property (nonatomic, strong) SceneButtonModel *model;
@property(nonatomic, copy) void (^goAction)(SceneTableCell *cell, SceneButtonModel *model);
@end

NS_ASSUME_NONNULL_END
