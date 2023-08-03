// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "LiveReconnectModel.h"
#import "LiveRoomInfoModel.h"
#import "LiveUserModel.h"
#import "RoomStatusModel.h"
#import <UIKit/UIKit.h>
#import "BytedEffectProtocol.h"

@interface LiveRoomViewController : UIViewController

@property (nonatomic, copy) void (^hangUpBlock)(BOOL result);

- (instancetype)initWithRoomModel:(LiveRoomInfoModel *)liveRoomModel
                    streamPushUrl:(NSString *)streamPushUrl;

#pragma mark - Listener

/**
 * @brief Received the user joined the room
 * @param userModel user model
 * @param audienceCount current number of users in the room
 */

- (void)addUser:(LiveUserModel *)userModel
  audienceCount:(NSInteger)audienceCount;

/**
 * @brief Received when the user left the room
 * @param userModel user model
 * @param audienceCount current number of users in the room
 */

- (void)removeUser:(LiveUserModel *)userModel
     audienceCount:(NSInteger)audienceCount;

/**
 * @brief IM message received
 * @param message message content
 * @param sendUserModel sender user model
 */

- (void)receivedIMMessage:(LiveMessageModel *)message
            sendUserModel:(LiveUserModel *)sendUserModel;

/**
 * @brief Received the status change of the make Guests
 * @param status mic status
 */

- (void)receivedRoomStatus:(LiveInteractStatus)status;

/**
 * @brief Received guest or host camera and microphone status changes
 * @param uid The user ID of the device change
 * @param operatorUid User ID for operating device changes
 * @param camera camera state
 * @param mic Microphone status
 */

- (void)receivedAddGuestsMediaChangeWithUser:(NSString *)uid
                                 operatorUid:(NSString *)operatorUid
                                      camera:(BOOL)camera
                                         mic:(BOOL)mic;

/**
 * @brief Received news that the host or guest temporarily cut to the background
 * @param uid user ID
 * @param userName user nickname
 * @param userRole user role
 */

- (void)receivedLeaveTemporary:(NSString *)uid
                      userName:(NSString *)userName
                      userRole:(NSString *)userRole;

/**
 * @brief Received the message that the live broadcast ended
 * @param type The end type of the live broadcast. 2: Closed due to timeout, 3: Closed due to violation.
 */

- (void)receivedLiveEnd:(NSString *)type endLiveInfo:(LiveEndLiveModel *)info;

#pragma mark - Listener Cohost

/**
 * @brief Received an invitation from cohost
 * @param inviter User model for invitation
 * @param linkerID invitation ID
 * @param extra extended transparent transmission data
 */

- (void)receivedCoHostInviteWithUser:(LiveUserModel *)inviter
                            linkerID:(NSString *)linkerID
                               extra:(NSString *)extra;

/**
 * @brief Rejected by cohost
 * @param invitee the invited user model
 */

- (void)receivedCoHostRefuseWithUser:(LiveUserModel *)invitee;

/**
 * @brief Received make cohost success
 * @param invitee the invited user model
 * @param linkerID invitation ID
 */

- (void)receivedCoHostSucceedWithUser:(LiveUserModel *)invitee
                             linkerID:(NSString *)linkerID;

/**
 * @brief Received cohost message, remote host.
 * @param userlList make cohost user list data
 * @param otherRoomId The other room ID
 * @param otherToken The RTC Token of the other party's room
 */

- (void)receivedCoHostJoin:(NSArray<LiveUserModel *> *)userlList
         otherAnchorRoomId:(NSString *)otherRoomId
          otherAnchorToken:(NSString *)otherToken;

/**
 * @brief Received cohost end
 */

- (void)receivedCoHostEnd;

#pragma mark - Listener Guests

/**
 * @brief Received application from make guests
 * @param applicant applicant user model
 * @param linkerID Linker ID
 * @param extra extended transparent transmission data
 */

- (void)receivedAddGuestsApplyWithUser:(LiveUserModel *)applicant
                              linkerID:(NSString *)linkerID
                                 extra:(NSString *)extra;


/**
 * @brief Received an invitation from the make guests
 * @param inviter Inviter user model
 * @param linkerID Linker ID
 * @param extra extended transparent transmission data
 */

- (void)receivedAddGuestsInviteWithUser:(LiveUserModel *)inviter
                               linkerID:(NSString *)linkerID
                                  extra:(NSString *)extra;

/**
 * @brief Received rejection from make guests
 * @param invitee Invited guest user model
 */

- (void)receivedAddGuestsRefuseWithUser:(LiveUserModel *)invitee;


/**
 * @brief Received the change of the anchor and guest's camera and microphone switch
 * @param uid guest user ID
 * @param camera switch status of guest camera
 * @param mic guest microphone switch status
 */

- (void)receivedAddGuestsManageGuestMedia:(NSString *)uid
                                   camera:(NSInteger)camera
                                      mic:(NSInteger)mic;

/**
 * @brief Received make guests start
 * @param invitee Invited guest user model
 * @param linkerID Linker ID
 * @param rtcRoomID RTC room ID
 * @param rtcToken RTC Token
 */

- (void)receivedAddGuestsSucceedWithUser:(LiveUserModel *)invitee
                                linkerID:(NSString *)linkerID
                               rtcRoomID:(NSString *)rtcRoomID
                                rtcToken:(NSString *)rtcToken;

/**
 * @brief Received the news that the host and guest joined the host, and the guest joined the news
 * @param userlList current mic user list
 */

- (void)receivedAddGuestsJoin:(NSArray<LiveUserModel *> *)userlList;


/**
 * @brief Received the news that the host and guest are connected and the guest has left
 * @param uid guest user ID
 * @param userlList current mic user list
 */

- (void)receivedAddGuestsRemoveWithUser:(NSString *)uid userList:(NSArray<LiveUserModel *> *)userList;

- (void)receivedCancelApplyLinkmicWithUser:(NSString *)uid roomId:(NSString *)roomId;

/**
 * @brief Received make guests end
 */

- (void)receivedAddGuestsEnd;


@end
