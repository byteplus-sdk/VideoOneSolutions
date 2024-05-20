// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "KTVSongModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTVRoomViewController : UIViewController

- (instancetype)initWithRoomModel:(KTVRoomModel *)roomModel;

- (instancetype)initWithRoomModel:(KTVRoomModel *)roomModel
                         rtcToken:(NSString *)rtcToken
                    hostUserModel:(KTVUserModel *)hostUserModel;

- (void)receivedJoinUser:(KTVUserModel *)userModel
                   count:(NSInteger)count;

- (void)receivedLeaveUser:(KTVUserModel *)userModel
                    count:(NSInteger)count;

- (void)receivedFinishLive:(NSInteger)type roomID:(NSString *)roomID;

- (void)receivedJoinInteractWithUser:(KTVUserModel *)userModel
                              seatID:(NSString *)seatID;

- (void)receivedLeaveInteractWithUser:(KTVUserModel *)userModel
                               seatID:(NSString *)seatID
                                 type:(NSInteger)type;

- (void)receivedSeatStatusChange:(NSString *)seatID
                            type:(NSInteger)type;

- (void)receivedMediaStatusChangeWithUser:(KTVUserModel *)userModel
                                   seatID:(NSString *)seatID
                                      mic:(NSInteger)mic;

- (void)receivedMessageWithUser:(KTVUserModel *)userModel
                            message:(NSString *)message;

- (void)receivedInviteInteractWithUser:(KTVUserModel *)hostUserModel
                                seatID:(NSString *)seatID;

- (void)receivedApplyInteractWithUser:(KTVUserModel *)userModel
                               seatID:(NSString *)seatID;


- (void)receivedInviteResultWithUser:(KTVUserModel *)hostUserModel
                               reply:(NSInteger)reply;

- (void)receivedMediaOperatWithUid:(NSInteger)mic;

- (void)receivedClearUserWithUid:(NSString *)uid;

- (void)receivedPickedSong:(KTVSongModel *)songModel;

- (void)receivedStartSingSong:(KTVSongModel *)songModel;

- (void)receivedFinishSingSong:(NSInteger)score
                 nextSongModel:(KTVSongModel *)nextSongModel
                  curSongModel:(KTVSongModel *)curSongModel;

@end

NS_ASSUME_NONNULL_END
