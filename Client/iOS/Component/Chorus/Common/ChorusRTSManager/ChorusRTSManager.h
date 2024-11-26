// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>
#import "ChorusUserModel.h"
#import "ChorusRoomModel.h"
#import "ChorusControlRecordModel.h"
#import "RTSACKModel.h"
#import "ChorusSongModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChorusRTSManager : NSObject

#pragma mark - Host API
+ (void)startLive:(NSString *)roomName
         userName:(NSString *)userName
      bgImageName:(NSString *)bgImageName
            block:(void (^)(NSString *RTCToken,
                            ChorusRoomModel *roomModel,
                            ChorusUserModel *hostUserModel,
                            RTSACKModel *model))block;
+ (void)finishLive:(NSString *)roomID;
+ (void)requestPickedSongList:(NSString *)roomID
                        block:(void(^)(RTSACKModel *model, NSArray<ChorusSongModel*> *list))block;

+ (void)getPresetSongList:(NSString *)roomID
                    block:(void(^)(NSArray <ChorusSongModel *> *songList,
                                   RTSACKModel *model))complete;
+ (void)pickSong:(ChorusSongModel *)songModel
          roomID:(NSString *)roomID
           block:(void(^)(RTSACKModel *model))complete;


+ (void)cutOffSong:(NSString *)roomID
             block:(void(^)(RTSACKModel *model))complete;

+ (void)finishSing:(NSString *)roomID
            songID:(NSString *)songID
             score:(NSInteger)score
             block:(void(^)(ChorusSongModel *songModel,
                            RTSACKModel *model))complete;


#pragma mark - Audience API
+ (void)joinLiveRoom:(NSString *)roomID
            userName:(NSString *)userName
               block:(void (^)(NSString *RTCToken,
                               ChorusRoomModel *roomModel,
                               ChorusUserModel *userModel,
                               ChorusUserModel *hostUserModel,
                               ChorusSongModel *_Nullable songModel,
                               ChorusUserModel *_Nullable leadSingerUserModel,
                               ChorusUserModel *_Nullable succentorUserModel,
                               ChorusSongModel *_Nullable nextSongModel,
                               RTSACKModel *model))block;
+ (void)leaveLiveRoom:(NSString *)roomID;


#pragma mark - Publish API
+ (void)getActiveLiveRoomListWithBlock:(void (^)(NSArray<ChorusRoomModel *> *roomList,
                                                 RTSACKModel *model))block;
+ (void)sendMessage:(NSString *)roomID
            message:(NSString *)message
              block:(void (^)(RTSACKModel *model))block;
+ (void)startSingWithRoomID:(NSString *)roomID
                     songID:(NSString *)songID
                       type:(NSInteger)type
                      block:(void(^)(RTSACKModel *model))block;
+ (void)clearUser:(void(^)(RTSACKModel *model))block;
+ (void)reconnect:(NSString *)roomID
            block:(void(^)(NSString *RTCToken,
                           ChorusRoomModel *roomModel,
                           ChorusUserModel *userModel,
                           ChorusUserModel *hostUserModel,
                           ChorusSongModel *songModel,
                           ChorusUserModel *leadSingerUserModel,
                           ChorusUserModel *succentorUserModel,
                           ChorusSongModel *nextSongModel,
                           NSInteger audienceCount,
                           RTSACKModel *model))block;

#pragma mark - Notification Message
+ (void)onAudienceJoinRoomWithBlock:(void (^)(ChorusUserModel *userModel,
                                              NSInteger count))block;
+ (void)onAudienceLeaveRoomWithBlock:(void (^)(ChorusUserModel *userModel,
                                               NSInteger count))block;
+ (void)onFinishLiveWithBlock:(void (^)(NSString *rommID, NSInteger type))block;
+ (void)onMessageWithBlock:(void (^)(ChorusUserModel *userModel,
                                     NSString *message))block;
+ (void)onPickSongBlock:(void(^)(ChorusSongModel *songModel))block;
+ (void)onPrepareStartSingSongBlock:(void(^)(ChorusSongModel *_Nullable songModel,
                                             ChorusUserModel *_Nullable leadSingerUserModel))block;
+ (void)onReallyStartSingSongBlock:(void(^)(ChorusSongModel *songModel,
                                            ChorusUserModel *leadSingerUserModel,
                                            ChorusUserModel *_Nullable succentorUserModel))block;
+ (void)onFinishSingSongBlock:(void(^)(ChorusSongModel *nextSongModel, NSInteger score))block;

@end

NS_ASSUME_NONNULL_END
