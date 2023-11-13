//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddGuestsOnlineListsView.h"
#import "LiveUserModel.h"
#import <Foundation/Foundation.h>
@class LiveAddGuestsComponent, LiveRtcLinkSession;

typedef NS_ENUM(NSInteger, LiveAddGuestsDismissState) {
    LiveAddGuestsDismissStateNone,
    LiveAddGuestsDismissStateInvite,
    LiveAddGuestsDismissStateCloseConnect,
};

FOUNDATION_EXTERN NSTimeInterval const LiveApplyOvertimeInterval;

NS_ASSUME_NONNULL_BEGIN

@protocol LiveAddGuestsComponentDelegate <NSObject>

- (void)guestsComponent:(LiveAddGuestsComponent *)guestsComponent
        clickMoreButton:(LiveUserModel *)model;

- (void)guestsComponent:(LiveAddGuestsComponent *)guestsComponent
       updateUserStatus:(LiveInteractStatus)status;

- (void)guestsComponent:(LiveAddGuestsComponent *)guestsComponent
             clickAgree:(LiveUserModel *)model;
@end

@interface LiveAddGuestsComponent : NSObject

@property (nonatomic, weak) id<LiveAddGuestsComponentDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL isConnect;

- (instancetype)initWithRoomID:(LiveRoomInfoModel *)roomInfoModel;

- (void)bindLinkerId:(NSString *)linkerId uid:(NSString *)uid;

- (NSString *)getLinkerIdWithUid:(NSString *)uid;

#pragma mark - List

- (void)showListWithSwitch:(BOOL)isSwitch
                     block:(void (^)(LiveAddGuestsDismissState state))dismissBlock;

- (void)dismissList;

- (void)updateList;

- (void)updateApplicationList;

- (void)updateFirstGuestLinkMicTime:(NSDate *)time;
- (BOOL)IsDisplayApplyList;

- (void)updateListUnread:(BOOL)isUnread;

#pragma mark - Apply

- (void)showApply:(LiveUserModel *)loginUserModel hostID:(NSString *)hostID;

- (void)closeApply;

#pragma mark - Pending

- (void)showPending;

- (void)closePending;

#pragma mark - Live Room Render

- (void)showAddGuests:(UIView *)superView
              hostUid:(NSString *)hostUid
             userList:(NSArray<LiveUserModel *> *)userList;

- (void)closeAddGuests;

- (nullable NSString *)removeAddGuestsUid:(NSString *)uid
                                 userList:(NSArray<LiveUserModel *> *)userList;

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid;

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
