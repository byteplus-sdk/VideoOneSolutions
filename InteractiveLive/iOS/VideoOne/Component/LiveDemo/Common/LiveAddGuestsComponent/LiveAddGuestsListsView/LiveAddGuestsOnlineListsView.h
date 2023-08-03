// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "LiveAddGuestsUserListtCell.h"
#import <UIKit/UIKit.h>
@class LiveAddGuestsOnlineListsView;

NS_ASSUME_NONNULL_BEGIN

@protocol LiveAddGuestsOnlineListsViewDelegate <NSObject>

- (void)onlineListsView:(LiveAddGuestsOnlineListsView *)onlineListsView
        clickKickButton:(LiveUserModel *)model;

- (void)onlineListsView:(LiveAddGuestsOnlineListsView *)onlineListsView
           clickMicButton:(LiveUserModel *)model;

- (void)onlineListsView:(LiveAddGuestsOnlineListsView *)onlineListsView
        clickCameraButton:(LiveUserModel *)model;

@end

@interface LiveAddGuestsOnlineListsView : UIView

@property (nonatomic, copy) NSArray<LiveUserModel *> *dataLists;

@property (nonatomic, weak) id<LiveAddGuestsOnlineListsViewDelegate> delegate;

@property (nonatomic, copy) void (^clickApplicationBlock)(void);

@property (nonatomic, copy) void (^clickCloseConnectBlock)(void);

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid;

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid;

- (void)updateStartTime:(NSDate *)time;

@end

NS_ASSUME_NONNULL_END
