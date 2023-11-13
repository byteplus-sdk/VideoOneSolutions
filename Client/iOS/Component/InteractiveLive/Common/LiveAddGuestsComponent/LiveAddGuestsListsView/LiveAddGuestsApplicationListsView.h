//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddGuestsUserListtCell.h"
#import <UIKit/UIKit.h>
@class LiveAddGuestsApplicationListsView;

NS_ASSUME_NONNULL_BEGIN

@protocol LiveAddGuestsApplicationListsViewDelegate <NSObject>

- (void)applicationListsView:(LiveAddGuestsApplicationListsView *)applicationListsView clickAgreeButton:(LiveUserModel *)model;

- (void)applicationListsView:(LiveAddGuestsApplicationListsView *)applicationListsView clickRejectButton:(LiveUserModel *)model;

@end

@interface LiveAddGuestsApplicationListsView : UIView

@property (nonatomic, copy) NSArray<LiveUserModel *> *dataLists;

@property (nonatomic, assign) BOOL isApplyDisable;

@property (nonatomic, weak) id<LiveAddGuestsApplicationListsViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
