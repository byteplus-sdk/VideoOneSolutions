// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>
#import "ChorusSongModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChorusRoomViewController : UIViewController

- (instancetype)initWithRoomModel:(ChorusRoomModel *)roomModel;

- (instancetype)initWithRoomModel:(ChorusRoomModel *)roomModel
                         rtcToken:(NSString *)rtcToken
                    hostUserModel:(ChorusUserModel *)hostUserModel;

- (void)receivedJoinUser:(ChorusUserModel *)userModel
                   count:(NSInteger)count;

- (void)receivedLeaveUser:(ChorusUserModel *)userModel
                    count:(NSInteger)count;

- (void)receivedFinishLive:(NSInteger)type roomID:(NSString *)roomID;

- (void)receivedMessageWithUser:(ChorusUserModel *)userModel
                            message:(NSString *)message;

- (void)receivedPickedSong:(ChorusSongModel *)songModel;
- (void)receivedPrepareStartSingSong:(ChorusSongModel *_Nullable)songModel
                 leadSingerUserModel:(ChorusUserModel *_Nullable)leadSingerUserModel;
- (void)receivedReallyStartSingSong:(ChorusSongModel *)songModel
                leadSingerUserModel:(ChorusUserModel *)leadSingerUserModel
                 succentorUserModel:( ChorusUserModel * _Nullable)succentorUserModel;

- (void)receivedFinishSingSong:(NSInteger)score nextSongModel:(ChorusSongModel *)nextSongModel;

@end

NS_ASSUME_NONNULL_END
