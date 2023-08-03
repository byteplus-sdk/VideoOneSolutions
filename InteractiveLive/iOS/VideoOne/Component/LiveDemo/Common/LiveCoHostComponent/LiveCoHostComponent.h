// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "LivePKListsView.h"
#import <Foundation/Foundation.h>
@class LiveCoHostComponent;

NS_ASSUME_NONNULL_BEGIN

@protocol LiveCoHostComponentDelegate <NSObject>

- (void)coHostComponent:(LiveCoHostComponent *)coHostComponent
        invitePermitted:(NSArray *)userList
              rtcRoomID:(NSString *)rtcRoomID
               rtcToken:(NSString *)rtcToken;

- (void)coHostComponent:(LiveCoHostComponent *)coHostComponent
         inviteRejected:(NSArray *)userList
              rtcRoomID:(NSString *)rtcRoomID
               rtcToken:(NSString *)rtcToken;

- (void)coHostComponent:(LiveCoHostComponent *)coHostComponent
    haveSentPKRequestTo:(LiveUserModel *)userModel;

- (void)coHostComponent:(LiveCoHostComponent *)coHostComponent dealExceptionalCase:(RTSACKModel *)model;

@end

typedef NS_ENUM(NSInteger, LiveCoHostDismissState) {
    LiveCoHostDismissStateNone,
    LiveCoHostDismissStateInviteIng,
};

@interface LiveCoHostComponent : NSObject

@property (nonatomic, weak) id<LiveCoHostComponentDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL isConnect;

@property (nonatomic, copy) NSString *linkerID;

- (instancetype)initWithRoomID:(LiveRoomInfoModel *)roomInfoModel;

#pragma mark - List host

- (void)showInviteList:(void (^ __nullable)(LiveCoHostDismissState state))dismissBlock;

- (void)dismissInviteList;

- (void)updateInviteList;


#pragma mark - During PK

- (void)showDuringPK;

- (void)closeDuringPK;

#pragma mark - Invite PK

- (void)pushToInviteList:(LiveUserModel *)fromUserModel;

- (void)bindLinkerId:(NSString *)linkerId uid:(NSString *)uid;

#pragma mark - Live render room

- (void)startCoHostBattleWithUsers:(NSArray<LiveUserModel *> *)userList;

- (void)closeCoHost;

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid;

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid;

//- (void)updateLiveTime:(NSDate *)date;
- (void)updateCoHostRoomView:(UIView *)superView
               userModelList:(NSArray<LiveUserModel *> *)userModelList
              loginUserModel:(LiveUserModel *)loginUserModel;

@end

NS_ASSUME_NONNULL_END
