// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "LiveUserModel.h"
#import <UIKit/UIKit.h>

@class LivePKCell;

NS_ASSUME_NONNULL_BEGIN

@protocol LivePKCellDelegate <NSObject>

- (void)LivePKCell:(LivePKCell *)LivePKCell clickButton:(LiveUserModel *)model;

@end

@interface LivePKCell : UITableViewCell

@property (nonatomic, strong) LiveUserModel *model;

@property (nonatomic, copy) NSString *indexStr;

@property (nonatomic, weak) id<LivePKCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
