// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "MenuCellModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserCell : UITableViewCell

@property (nonatomic, strong) MenuCellModel *model;

@property (nonatomic, assign) UIRectCorner corner;
@end

NS_ASSUME_NONNULL_END
