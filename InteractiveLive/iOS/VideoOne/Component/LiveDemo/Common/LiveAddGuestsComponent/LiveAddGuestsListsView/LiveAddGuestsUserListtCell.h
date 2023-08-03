// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "LiveUserModel.h"
#import <UIKit/UIKit.h>

@class LiveAddGuestsUserListtCell;

NS_ASSUME_NONNULL_BEGIN

@protocol LiveAddGuestsUserListtCellDelegate <NSObject>

@optional

- (void)liveAddGuestsCell:(LiveAddGuestsUserListtCell *)liveAddGuestsCell
         clickAgreeButton:(LiveUserModel *)model;

- (void)liveAddGuestsCell:(LiveAddGuestsUserListtCell *)liveAddGuestsCell
         clickRejectButton:(LiveUserModel *)model;

- (void)liveAddGuestsCell:(LiveAddGuestsUserListtCell *)liveAddGuestsCell
    clickDisconnectButton:(LiveUserModel *)model;

- (void)liveAddGuestsCell:(LiveAddGuestsUserListtCell *)liveAddGuestsCell
           clickMicButton:(LiveUserModel *)model;

- (void)liveAddGuestsCell:(LiveAddGuestsUserListtCell *)liveAddGuestsCell
        clickCameraButton:(LiveUserModel *)model;

@end

@interface LiveAddGuestsUserListtCell : UITableViewCell

@property (nonatomic, strong) LiveUserModel *onlineUserModel;

@property (nonatomic, strong) LiveUserModel *applicationUserModel;

@property (nonatomic, copy) NSString *indexStr;

@property (nonatomic, assign) BOOL isApplyDisable;

@property (nonatomic, weak) id<LiveAddGuestsUserListtCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
