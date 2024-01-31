// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "VEVideoDetailCell.h"
@class VEVideoDetailTableView;

NS_ASSUME_NONNULL_BEGIN

@protocol VEVideoDetailTableViewDelegate <NSObject>

- (void)tableView:(VEVideoDetailTableView *)tableView didSelectRowAtModel:(VEVideoModel *)model;

- (void)tableView:(VEVideoDetailTableView *)tableView loadDataWithMore:(BOOL)result;

@end

@interface VEVideoDetailTableView : UIView

@property (nonatomic, copy) NSArray<VEVideoModel *> *dataLists;

@property (nonatomic, weak) id<VEVideoDetailTableViewDelegate> delegate;

- (void)endRefreshingWithNoMoreData;

- (void)endRefresh;

@end

NS_ASSUME_NONNULL_END
