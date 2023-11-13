//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveInfomationModel.h"
#import "LiveInfomationUserListtCell.h"
#import <UIKit/UIKit.h>

@class LiveInfomationListsView;

NS_ASSUME_NONNULL_BEGIN

@interface LiveInfomationListsView : UIView

@property (nonatomic, copy) NSArray<LiveInfomationModel *> *dataLists;

- (void)refresh;

@end

NS_ASSUME_NONNULL_END
