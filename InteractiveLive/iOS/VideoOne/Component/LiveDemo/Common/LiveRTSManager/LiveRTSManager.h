// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>
#import "BaseUserModel.h"
#import "LiveReconnectModel.h"
#import "LiveRoomInfoModel.h"
#import "LiveUserModel.h"
#import "LiveMessageModel.h"
#import "RoomStatusModel.h"
#import "LiveEndLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LiveInviteReply) {
    LiveInviteReplyPermitted = 1,
    LiveInviteReplyForbade   = 2,
};

@interface LiveRTSManager : NSObject

#pragma mark - Host Live API

// Create a live broadcast
+ (void)liveCreateLive:(NSString *)userName
                 block:(void (^ __nullable)(LiveRoomInfoModel * _Nullable roomInfoModel,
                                            LiveUserModel * _Nullable hostUserModel,
                                            NSString * _Nullable pushUrl,
                                            RTSACKModel *model))block;

// Start live broadcast
+ (void)liveStartLive:(NSString *)roomID
                block:(void (^ __nullable)(LiveUserModel * _Nullable hostUserModel,
                                           RTSACKModel *model))block;

// Get the list of live broadcasters
+ (void)liveGetActiveAnchorList:(NSString *)roomID
                          block:(void (^ __nullable)(NSArray<LiveUserModel *> * _Nullable userList,
                                                     RTSACKModel *model))block;

// Get the audience list
+ (void)liveGetAudienceList:(NSString *)roomID
                      block:(void (^ __nullable)(NSArray<LiveUserModel *> * _Nullable userList,
                                                 RTSACKModel *model))block;

// Management
+ (void)liveManageGuestMedia:(NSString *)roomID
                 guestRoomID:(NSString *)guestRoomID
                 guestUserID:(NSString *)guestUserID
                         mic:(NSInteger)mic
                      camera:(NSInteger)camera
                       block:(void (^ __nullable)(RTSACKModel *model))block;

/*
 * Finish Live
 @param type
 2: End the anchor linking the microphone
 3: The guest ends himself
 4: The host ends all guests (disconnect)
 */
+ (void)liveFinishLive:(NSString *)roomID
                 block:(void (^ __nullable)(LiveEndLiveModel *endLiveInfo,RTSACKModel *model))block;

#pragma mark Linkmic API

+ (void)liveAudienceLinkmicInvite:(NSString *)roomID
                   audienceRoomID:(NSString *)audienceRoomID
                   audienceUserID:(NSString *)audienceUserID
                            extra:(NSString *)extra
                            block:(void (^ __nullable)(NSString * _Nullable linkerID,
                                                       RTSACKModel *model))block;

+ (void)liveAudienceLinkmicPermit:(NSString *)roomID
                   audienceRoomID:(NSString *)audienceRoomID
                   audienceUserID:(NSString *)audienceUserID
                         linkerID:(NSString *)linkerID
                       permitType:(LiveInviteReply)permitType
                            block:(void (^ __nullable)(NSString * _Nullable rtcRoomID,
                                                       NSString * _Nullable rtcToken,
                                                       NSArray<LiveUserModel *> * _Nullable userList,
                                                       RTSACKModel *model))block;

+ (void)liveAudienceLinkmicKick:(NSString *)roomID
                 audienceRoomID:(NSString *)audienceRoomID
                 audienceUserID:(NSString *)audienceUserID
                          block:(void (^ __nullable)(RTSACKModel *model))block;

+ (void)liveAudienceLinkmicFinish:(NSString *)roomID
                            block:(void (^ __nullable)(RTSACKModel *model))block;

+ (void)liveAnchorLinkmicInvite:(NSString *)roomID
                  inviteeRoomID:(NSString *)inviteeRoomID
                  inviteeUserID:(NSString *)inviteeUserID
                          extra:(NSString *)extra
                          block:(void (^ __nullable)(NSString * _Nullable linkerID,
                                                     RTSACKModel *model))block;

+ (void)liveAnchorLinkmicReply:(NSString *)roomID
                 inviterRoomID:(NSString *)inviterRoomID
                 inviterUserID:(NSString *)inviterUserID
                      linkerID:(NSString *)linkerID
                     replyType:(LiveInviteReply)replyType
                         block:(void (^ __nullable)(NSString * _Nullable rtcRoomID,
                                                    NSString * _Nullable rtcToken,
                                                    NSArray<LiveUserModel *> * _Nullable userList,
                                                    RTSACKModel *model))block;

+ (void)liveAnchorLinkmicFinish:(NSString *)linkerID
                          block:(void (^)(RTSACKModel * _Nonnull))block;

#pragma mark - Audience Live API

// Live join live room
+ (void)liveJoinLiveRoom:(NSString *)roomID
                   block:(void (^ __nullable)(LiveRoomInfoModel * _Nullable roomModel,
                                              LiveUserModel * _Nullable userModel,
                                              RTSACKModel *model))block;

// Live leave live room
+ (void)liveLeaveLiveRoom:(NSString *)roomID
                    block:(void (^ __nullable)(RTSACKModel *model))block;

#pragma mark Linkmic API

+ (void)liveAudienceLinkmicApply:(NSString *)roomID
                           block:(void (^ __nullable)(NSString * _Nullable linkerID,
                                                      RTSACKModel *model))  block;

+ (void)liveAudienceCancelApplyLinkerId:(NSString *)LinkerId
                                  block:(void (^)(RTSACKModel *model))block;

+ (void)liveAudienceLinkmicReply:(NSString *)roomID
                        linkerID:(NSString *)linkerID
                       replyType:(LiveInviteReply)replyType
                           block:(void (^ __nullable)(NSString * _Nullable rtcRoomID,
                                                      NSString * _Nullable rtcToken,
                                                      NSArray<LiveUserModel *> * _Nullable userList,
                                                      RTSACKModel *model))block;

+ (void)liveAudienceLinkmicLeave:(NSString *)roomID
                        linkerID:(NSString *)linkerID
                           block:(void (^ __nullable)(RTSACKModel *model))block;

#pragma mark - Publish API

// Update resolution
+ (void)liveUpdateResWithSize:(CGSize)videoSize
                       roomID:(NSString *)roomID
                        block:(void (^)(RTSACKModel *model))block;

// Live get active live room list
+ (void)liveGetActiveLiveRoomListWithBlock:(void (^ __nullable)(NSArray<LiveRoomInfoModel *> * _Nullable roomList,
                                                                RTSACKModel *model))block;

// Live clear user status
+ (void)liveClearUserWithBlock:(void (^)(RTSACKModel *model))block;

// Update camera microphone status
+ (void)liveUpdateMediaMic:(BOOL)mic
                    camera:(BOOL)camera
                     block:(void (^)(RTSACKModel *model))block;

// Reconnect
+ (void)reconnect:(NSString *)roomID
            block:(void (^ __nullable)(LiveReconnectModel * _Nullable reconnectModel,
                                       RTSACKModel *model))block;

// Send IM message
+ (void)sendIMMessage:(LiveMessageModel *)message
                block:(void (^ __nullable)(RTSACKModel *model))block;

#pragma mark - Global Notification message

// Audience join room
+ (void)onAudienceJoinRoomWithBlock:(void (^)(LiveUserModel *userModel,
                                              NSString *audienceCount))block;

// Audience leave room
+ (void)onAudienceLeaveRoomWithBlock:(void (^)(LiveUserModel *userModel,
                                               NSString *audienceCount))block;

// Finish Live
+ (void)onFinishLiveWithBlock:(void (^)(NSString *roomID,
                                        NSString *type, LiveEndLiveModel *endLiveInfo))block;

// Room Linkmic Status changed
+ (void)onLinkmicStatusWithBlock:(void (^)(LiveInteractStatus status))block;

// Audience join the interaction
+ (void)onAudienceLinkmicJoinWithBlock:(void (^)(NSString *rtcRoomID,
                                                 NSString *uid,
                                                 NSArray<LiveUserModel *> *userList))block;

// Audience leave the interaction
+ (void)onAudienceLinkmicLeaveWithBlock:(void (^)(NSString *rtcRoomID,
                                                  NSString *uid,
                                                  NSArray<LiveUserModel *> *userList))block;

//Audience cancel the linkmic application
+ (void)onAudienceCancelLinkmicWithBlock:(void (^)(NSString *rtcRoomID, NSString *userID))block;

// End of audience linkmic
+ (void)onAudienceLinkmicFinishWithBlock:(void (^)(NSString *rtcRoomID))block;

// End of anchor linkmic
+ (void)onAnchorLinkmicFinishWithBlock:(void (^)(NSString *rtcRoomID))block;

// Camera microphone changes
+ (void)onMediaChangeWithBlock:(void (^)(NSString *rtcRoomID,
                                         NSString *uid,
                                         NSString *operatorUid,
                                         NSInteger camera,
                                         NSInteger mic))block;

// Message send
+ (void)onMessageSendWithBlock:(void (^)(LiveUserModel *userModel,
                                         LiveMessageModel *message))block;

#pragma mark - Single Point Notification message

// Audience linkmic invitation
+ (void)onAudienceLinkmicInviteWithBlock:(void (^)(LiveUserModel *inviter,
                                                   NSString *linkerID,
                                                   NSString *extra))block;

// Audience linkmic application
+ (void)onAudienceLinkmicApplyWithBlock:(void (^)(LiveUserModel *applicant,
                                                  NSString *linkerID,
                                                  NSString *extra))block;

// Audience linkmic Reply
+ (void)onAudienceLinkmicReplyWithBlock:(void (^)(LiveUserModel *invitee,
                                                  NSString *linkerID,
                                                  LiveInviteReply replyType,
                                                  NSString *rtcRoomID,
                                                  NSString *rtcToken,
                                                  NSArray<LiveUserModel *> *userList))block;

// Audience linkmic Permit
+ (void)onAudienceLinkmicPermitWithBlock:(void (^)(NSString *linkerID,
                                                   LiveInviteReply permitType,
                                                   NSString *rtcRoomID,
                                                   NSString *rtcToken,
                                                   NSArray<LiveUserModel *> *userList))block;

// Kick Audience
+ (void)onAudienceLinkmicKickWithBlock:(void (^)(NSString *linkerID,
                                                 NSString *rtcRoomID,
                                                 NSString *uid))block;

+ (void)onAnchorLinkmicInviteWithBlock:(void (^)(LiveUserModel *inviter,
                                                 NSString *linkerID,
                                                 NSString *extra))block;

+ (void)onAnchorLinkmicReplyWithBlock:(void (^)(LiveUserModel *invitee,
                                                NSString *linkerID,
                                                LiveInviteReply replyType,
                                                NSString *rtcRoomID,
                                                NSString *rtcToken,
                                                NSArray<LiveUserModel *> *userList))block;

+ (void)onManageGuestMediaWithBlock:(void (^)(NSString *guestRoomID,
                                              NSString *guestUserID,
                                              NSInteger camera,
                                              NSInteger mic))block;
@end

NS_ASSUME_NONNULL_END
