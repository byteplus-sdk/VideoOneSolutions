//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import <Foundation/Foundation.h>
#import "KTVUserModel.h"
#import "KTVRoomModel.h"
#import "KTVSeatModel.h"
#import "KTVControlRecordModel.h"
#import "RTSACKModel.h"
#import "KTVSongModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTVRTSManager : NSObject

#pragma mark - Host API

/// The host creates a live room
/// @param roomName Room Name
/// @param userName User Name
/// @param bgImageName Bg Image Name
/// @param block Callback
+ (void)startLive:(NSString *)roomName
         userName:(NSString *)userName
      bgImageName:(NSString *)bgImageName
            block:(void (^)(NSString *RTCToken,
                            KTVRoomModel *roomModel,
                            KTVUserModel *hostUserModel,
                            RTSACKModel *model))block;


/// Get the list of viewers in the room
/// @param roomID Room ID
/// @param block Callback
+ (void)getAudienceList:(NSString *)roomID
                  block:(void (^)(NSArray<KTVUserModel *> *userLists,
                                  RTSACKModel *model))block;


/// Get the list of audiences applied for in the room
/// @param roomID Room ID
/// @param block Callback
+ (void)getApplyAudienceList:(NSString *)roomID
                       block:(void (^)(NSArray<KTVUserModel *> *userLists,
                                       RTSACKModel *model))block;


/// The anchor invites the audience to come on stage
/// @param roomID Room ID
/// @param uid User ID
/// @param seatID Seat ID
/// @param block Callback
+ (void)inviteInteract:(NSString *)roomID
                   uid:(NSString *)uid
                seatID:(NSString *)seatID
                 block:(void (^)(RTSACKModel *model))block;


/// The anchor agrees to the audience's application
/// @param roomID Room ID
/// @param uid User ID
/// @param block Callback
+ (void)agreeApply:(NSString *)roomID
               uid:(NSString *)uid
             block:(void (^)(RTSACKModel *model))block;



/// Whether the host switch is turned on to apply
/// @param roomID Room ID
/// @param type 1 open, other close
/// @param block Callback
+ (void)managerInteractApply:(NSString *)roomID
                        type:(NSInteger)type
                       block:(void (^)(RTSACKModel *model))block;


/// Host management Shangmai guests
/// @param roomID Room ID
/// @param seatID Seat ID
/// @param type management
/// @param block Callback
+ (void)managerSeat:(NSString *)roomID
             seatID:(NSString *)seatID
               type:(NSInteger)type
              block:(void (^)(RTSACKModel *model))block;



/// The host ends the live broadcast
/// @param roomID Room ID
+ (void)finishLive:(NSString *)roomID;

/// Request picked list
/// @param block Callback
+ (void)requestPickedSongList:(NSString *)roomID
                        block:(void(^)(RTSACKModel *model, NSArray<KTVSongModel*> *list))block;

/// Request pick song
/// @param songModel Song model
/// @param roomID RoomID
/// @param complete Callback
+ (void)pickSong:(KTVSongModel *)songModel
          roomID:(NSString *)roomID
           block:(void(^)(RTSACKModel *model))complete;

/// Cut off song
/// @param roomID Room id
/// @param complete Callback
+ (void)cutOffSong:(NSString *)roomID
             block:(void(^)(RTSACKModel *model))complete;


/// Finish sing song
/// @param roomID Room id
/// @param songID Song id
/// @param score Score
/// @param complete Callback
+ (void)finishSing:(NSString *)roomID
            songID:(NSString *)songID
             score:(NSInteger)score
             block:(void(^)(KTVSongModel *songModel,
                            RTSACKModel *model))complete;


/// Get preset song list
/// @param roomID Room id
/// @param complete Callback
+ (void)getPresetSongList:(NSString *)roomID
                    block:(void(^)(NSArray <KTVSongModel *> *songList,
                                   RTSACKModel *model))complete;


#pragma mark - Audience API


/// The audience joins the room
/// @param roomID Room ID
/// @param userName User Name
/// @param block Callback
+ (void)joinLiveRoom:(NSString *)roomID
            userName:(NSString *)userName
               block:(void (^)(NSString *RTCToken,
                               KTVRoomModel *roomModel,
                               KTVUserModel *userModel,
                               KTVUserModel *hostUserModel,
                               KTVSongModel *songModel,
                               NSArray<KTVSeatModel *> *seatList,
                               RTSACKModel *model))block;




/// Reply to the host’s invitation
/// @param roomID Room ID
/// @param reply 1 accept, 2 Refuse
/// @param block Callback
+ (void)replyInvite:(NSString *)roomID
              reply:(NSInteger)reply
              block:(void (^)(RTSACKModel *model))block;


/// Distinguished guests
/// @param roomID Room ID
/// @param seatID Seat ID
/// @param block Callback
+ (void)finishInteract:(NSString *)roomID
                seatID:(NSString *)seatID
                block:(void (^)(RTSACKModel *model))block;


/// Audience application on stage
/// @param roomID Room ID
/// @param seatID Seat ID [1-8]
/// @param block Callback
+ (void)applyInteract:(NSString *)roomID
               seatID:(NSString *)seatID
                block:(void (^)(BOOL isNeedApply,
                                RTSACKModel *model))block;


/// The audience leaves the room
/// @param roomID Room ID
+ (void)leaveLiveRoom:(NSString *)roomID;


#pragma mark - Publish API


/// Received the audience
/// @param block Callback
+ (void)getActiveLiveRoomListWithBlock:(void (^)(NSArray<KTVRoomModel *> *roomList,
                                                 RTSACKModel *model))block;


/// Mutual kick notification
/// @param block Callback
+ (void)clearUser:(void (^)(RTSACKModel *model))block;


/// Send IM message
/// @param roomID Room ID
/// @param message Message
/// @param block Callback
+ (void)sendMessage:(NSString *)roomID
            message:(NSString *)message
              block:(void (^)(RTSACKModel *model))block;


/// Update microphone status
/// @param roomID Room ID
/// @param mic 0 close ,1 open
/// @param block Callback
+ (void)updateMediaStatus:(NSString *)roomID
                      mic:(NSInteger)mic
                    block:(void (^)(RTSACKModel *model))block;



/// reconnect
/// @param block Callback
+ (void)reconnectWithBlock:(void (^)(NSString *RTCToken,
                                     KTVRoomModel *roomModel,
                                     KTVUserModel *userModel,
                                     KTVUserModel *hostUserModel,
                                     KTVSongModel *songModel,
                                     NSArray<KTVSeatModel *> *seatList,
                                     RTSACKModel *model))block;



#pragma mark - Notification Message


/// The audience joins the room
/// @param block Callback
+ (void)onAudienceJoinRoomWithBlock:(void (^)(KTVUserModel *userModel,
                                              NSInteger count))block;


/// The audience leaves the room
/// @param block Callback
+ (void)onAudienceLeaveRoomWithBlock:(void (^)(KTVUserModel *userModel,
                                               NSInteger count))block;


/// Received the end of the live broadcast room
/// @param block Callback
+ (void)onFinishLiveWithBlock:(void (^)(NSString *rommID, NSInteger type))block;


/// Successful audience
/// @param block Callback
+ (void)onJoinInteractWithBlock:(void (^)(KTVUserModel *userModel,
                                          NSString *seatID))block;


/// Distinguished guests
/// @param block Callback
+ (void)onFinishInteractWithBlock:(void (^)(KTVUserModel *userModel,
                                            NSString *seatID,
                                            NSInteger type))block;


/// Wheat status changes
/// @param block Callback
+ (void)onSeatStatusChangeWithBlock:(void (^)(NSString *seatID,
                                              NSInteger type))block;


/// Microphone status changes
/// @param block Callback
+ (void)onMediaStatusChangeWithBlock:(void (^)(KTVUserModel *userModel,
                                               NSString *seatID,
                                               NSInteger mic))block;


/// IM message received
/// @param block Callback
+ (void)onMessageWithBlock:(void (^)(KTVUserModel *userModel,
                                     NSString *message))block;

/// Pick song received
/// @param block Callback
+ (void)onPickSongBlock:(void(^)(KTVSongModel *songModel))block;

/// Start sing song
/// @param block Callback
+ (void)onStartSingSongBlock:(void(^)(KTVSongModel *songModel))block;

/// Finish sing song
/// @param block Callback
+ (void)onFinishSingSongBlock:(void (^)(KTVSongModel * _Nonnull, KTVSongModel * _Nonnull, NSInteger))block;


#pragma mark - Single Notification Message


/// Received an invitation
/// @param block Callback
+ (void)onInviteInteractWithBlock:(void (^)(KTVUserModel *hostUserModel,
                                            NSString *seatID))block;

/// Application received
/// @param block Callback
+ (void)onApplyInteractWithBlock:(void (^)(KTVUserModel *userModel,
                                           NSString *seatID))block;


/// Receipt of invitation result
/// @param block Callback
+ (void)onInviteResultWithBlock:(void (^)(KTVUserModel *userModel,
                                          NSInteger reply))block;

/// Receive guest/host microphone changes
/// @param block Callback
+ (void)onMediaOperateWithBlock:(void (^)(NSInteger mic))block;


/// Received mutual kick notification
/// @param block Callback
+ (void)onClearUserWithBlock:(void (^)(NSString *uid))block;

@end

NS_ASSUME_NONNULL_END
