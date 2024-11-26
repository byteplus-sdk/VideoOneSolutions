// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVRTCManager.h"
#import "KTVRTSManager.h"

@implementation KTVRTSManager

#pragma mark - Get Voice data

+ (void)startLive:(NSString *)roomName
         userName:(NSString *)userName
      bgImageName:(NSString *)bgImageName
            block:(void (^)(NSString *RTCToken,
                            KTVRoomModel *roomModel,
                            KTVUserModel *hostUserModel,
                            RTSACKModel *model))block {
    NSDictionary *dic = @{
        @"room_name" : (roomName ?: @""),
        @"background_image_name" : (bgImageName ?: @""),
        @"user_name" : (userName ?: @"")
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvStartLive" with:dic block:^(RTSACKModel * _Nonnull ackModel) {

        NSString *RTCToken = @"";
        KTVRoomModel *roomModel = nil;
        KTVUserModel *hostUserModel = nil;
        if ([KTVRTSManager ackModelResponseClass:ackModel]) {
            roomModel = [KTVRoomModel yy_modelWithJSON:ackModel.response[@"room_info"]];
            hostUserModel = [KTVUserModel yy_modelWithJSON:ackModel.response[@"user_info"]];
            RTCToken = [NSString stringWithFormat:@"%@", ackModel.response[@"rtc_token"]];
        }
        if (block) {
            block(RTCToken, roomModel, hostUserModel, ackModel);
        }
    }];
}

+ (void)getAudienceList:(NSString *)roomID
                  block:(void (^)(NSArray<KTVUserModel *> *userLists,
                                  RTSACKModel *model))block {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
            @"room_id": (roomID ?: @"")
    };

    [[KTVRTCManager shareRtc] emitWithAck:@"ktvGetAudienceList" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        NSMutableArray<KTVUserModel *> *userLists = [[NSMutableArray alloc] init];
        if ([KTVRTSManager ackModelResponseClass:ackModel]) {
            NSArray *list = ackModel.response[@"audience_list"];
            for (int i = 0; i < list.count; i++) {
                KTVUserModel *userModel = [KTVUserModel yy_modelWithJSON:list[i]];
                [userLists addObject:userModel];
            }
        }
        if (block) {
            block([userLists copy], ackModel);
        }
    }];
}

+ (void)getApplyAudienceList:(NSString *)roomID
                       block:(void (^)(NSArray<KTVUserModel *> *userLists,
                                       RTSACKModel *model))block {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
            @"room_id": (roomID ?: @"")
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvGetApplyAudienceList" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        NSMutableArray<KTVUserModel *> *userLists = [[NSMutableArray alloc] init];
        if ([KTVRTSManager ackModelResponseClass:ackModel]) {
            NSArray *list = ackModel.response[@"audience_list"];
            for (int i = 0; i < list.count; i++) {
                KTVUserModel *userModel = [KTVUserModel yy_modelWithJSON:list[i]];
                [userLists addObject:userModel];
            }
        }
        if (block) {
            block([userLists copy], ackModel);
        }
    }];
}

+ (void)inviteInteract:(NSString *)roomID
                   uid:(NSString *)uid
                seatID:(NSString *)seatID
                 block:(void (^)(RTSACKModel *model))block {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
        @"room_id" : (roomID ?: @""),
        @"audience_user_id" : (uid ?: @""),
        @"seat_id" : @(seatID.integerValue)
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvInviteInteract" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        if (block) {
            block(ackModel);
        }
    }];
}

+ (void)agreeApply:(NSString *)roomID
               uid:(NSString *)uid
             block:(void (^)(RTSACKModel *model))block {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
        @"room_id" : (roomID ?: @""),
        @"audience_user_id" : (uid ?: @"")
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvAgreeApply" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        if (block) {
            block(ackModel);
        }
    }];
}

+ (void)managerInteractApply:(NSString *)roomID
                        type:(NSInteger)type
                       block:(void (^)(RTSACKModel *model))block {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
        @"room_id" : (roomID ?: @""),
        @"type" : @(type)
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvManageInteractApply" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        if (block) {
            block(ackModel);
        }
    }];
}

+ (void)managerSeat:(NSString *)roomID
             seatID:(NSString *)seatID
               type:(NSInteger)type
              block:(void (^)(RTSACKModel *model))block {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
        @"room_id" : (roomID ?: @""),
        @"seat_id" : @(seatID.integerValue),
        @"type" : @(type)
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvManageSeat" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        if (block) {
            block(ackModel);
        }
    }];
}

+ (void)finishLive:(NSString *)roomID {
    if (IsEmptyStr(roomID)) {
        return;
    }
    NSDictionary *dic = @{
            @"room_id": (roomID ?: @"")
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvFinishLive" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
    }];
}

+ (void)requestPickedSongList:(NSString *)roomID
                        block:(void(^)(RTSACKModel *model, NSArray<KTVSongModel*> *list))block {
    
    if (IsEmptyStr(roomID)) {
        return;
    }
    NSDictionary *dic = @{
            @"room_id": (roomID ?: @"")
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvGetRequestSongList" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        NSArray *list = nil;
        if ([KTVRTSManager ackModelResponseClass:ackModel]) {
            list = [NSArray yy_modelArrayWithClass:[KTVSongModel class] json:ackModel.response[@"song_list"]];
        }
        if (block) {
            block(ackModel, list);
        }
    }];
}

+ (void)pickSong:(KTVSongModel *)songModel
          roomID:(NSString *)roomID
           block:(void (^)(RTSACKModel * _Nonnull))complete {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
        @"room_id" : (roomID ?: @""),
        @"song_id" : (songModel.musicId ?: @""),
        @"song_name" : (songModel.musicName ?: @""),
        @"song_duration" : @(songModel.musicAllTime),
        @"cover_url" : (songModel.coverURL ?: @""),
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvRequestSong" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        if (complete) {
            complete(ackModel);
        }
    }];
}

+ (void)cutOffSong:(NSString *)roomID
             block:(void(^)(RTSACKModel *model))complete {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
            @"room_id": (roomID ?: @"")
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvCutOffSong" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        if (complete) {
            complete(ackModel);
        }
    }];
}

+ (void)finishSing:(NSString *)roomID
            songID:(NSString *)songID
             score:(NSInteger)score
             block:(void(^)(KTVSongModel *songModel,
                            RTSACKModel *model))complete {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
        @"room_id" : (roomID ?: @""),
        @"song_id" : (songID ?: @""),
        @"score" : @(score)
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvFinishSing" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        KTVSongModel *songModel = nil;
        if ([KTVRTSManager ackModelResponseClass:ackModel]) {
            songModel = [KTVSongModel yy_modelWithJSON:ackModel.response[@"next_song"]];
        }
        
        if (complete) {
            complete(songModel, ackModel);
        }
    }];
}

+ (void)getPresetSongList:(NSString *)roomID
                    block:(void(^)(NSArray <KTVSongModel *> *songList,
                                   RTSACKModel *model))complete {
    NSDictionary *dic = @{};
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvGetPresetSongList" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        NSMutableArray<KTVSongModel *> *songList = [[NSMutableArray alloc] init];
        if ([KTVRTSManager ackModelResponseClass:ackModel]) {
            NSArray *list = ackModel.response[@"song_list"];
            for (int i = 0; i < list.count; i++) {
                [songList addObject:[KTVSongModel yy_modelWithJSON:list[i]]];
            }
        }
        
        if (complete) {
            complete([songList copy], ackModel);
        }
    }];
}


#pragma mark - Audience API

+ (void)joinLiveRoom:(NSString *)roomID
            userName:(NSString *)userName
               block:(void (^)(NSString *RTCToken,
                               KTVRoomModel *roomModel,
                               KTVUserModel *userModel,
                               KTVUserModel *hostUserModel,
                               KTVSongModel *songModel,
                               NSArray<KTVSeatModel *> *seatList,
                               RTSACKModel *model))block {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
        @"room_id" : (roomID ?: @""),
        @"user_name" : (userName ?: @"")
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvJoinLiveRoom" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        NSString *RTCToken = @"";
        KTVRoomModel *roomModel = nil;
        KTVUserModel *hostUserModel = nil;
        KTVUserModel *userModel = nil;
        KTVSongModel *songModel = [[KTVSongModel alloc] init];
        NSMutableArray<KTVSeatModel *> *seatList = [[NSMutableArray alloc] init];;
        if ([KTVRTSManager ackModelResponseClass:ackModel]) {
            NSDictionary *songDic = ackModel.response[@"cur_song"];
            songModel = [KTVSongModel yy_modelWithJSON:songDic];
            
            roomModel = [KTVRoomModel yy_modelWithJSON:ackModel.response[@"room_info"]];
            hostUserModel = [KTVUserModel yy_modelWithJSON:ackModel.response[@"host_info"]];
            userModel = [KTVUserModel yy_modelWithJSON:ackModel.response[@"user_info"]];
            RTCToken = [NSString stringWithFormat:@"%@", ackModel.response[@"rtc_token"]];
            NSDictionary *seatDic = ackModel.response[@"seat_list"];
            for (int i = 0; i < seatDic.allKeys.count; i++) {
                NSString *keyStr = [NSString stringWithFormat:@"%ld", (long)(i + 1)];
                KTVSeatModel *seatModel = [KTVSeatModel yy_modelWithJSON:seatDic[keyStr]];
                seatModel.index = keyStr.integerValue;
                [seatList addObject:seatModel];
            }
        }
        if (block) {
            block(RTCToken,
                  roomModel,
                  userModel,
                  hostUserModel,
                  songModel,
                  [seatList copy],
                  ackModel);
        }
    }];
}

+ (void)replyInvite:(NSString *)roomID
              reply:(NSInteger)reply
              block:(void (^)(RTSACKModel *model))block {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
         @"room_id": (roomID ?: @""),
         @"reply": @(reply)
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvReplyInvite" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        if (block) {
            block(ackModel);
        }
    }];
}

+ (void)finishInteract:(NSString *)roomID
                seatID:(NSString *)seatID
                 block:(void (^)(RTSACKModel *model))block {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
        @"room_id": (roomID ?: @""),
        @"seat_id": @(seatID.integerValue)
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvFinishInteract" with:dic block:^(RTSACKModel * _Nonnull ackModel) {

        if (block) {
            block(ackModel);
        }
    }];
}

+ (void)applyInteract:(NSString *)roomID
               seatID:(NSString *)seatID
                block:(void (^)(BOOL isNeedApply,
                                RTSACKModel *model))block {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
        @"room_id": (roomID ?: @""),
        @"seat_id": @(seatID.integerValue)
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvApplyInteract" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        BOOL isNeedApply = NO;
        if (ackModel.response &&
            [ackModel.response isKindOfClass:[NSDictionary class]]) {
            isNeedApply = [[NSString stringWithFormat:@"%@", ackModel.response[@"is_need_apply"]] boolValue];
        }
        if (block) {
            block(isNeedApply, ackModel);
        }
    }];
}

+ (void)leaveLiveRoom:(NSString *)roomID {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
            @"room_id": (roomID ?: @"")
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvLeaveLiveRoom" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
    }];
}


#pragma mark - Publish API

+ (void)getActiveLiveRoomListWithBlock:(void (^)(NSArray<KTVRoomModel *> *roomList,
                                                 RTSACKModel *model))block {
    NSDictionary *dic = @{};
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvGetActiveLiveRoomList" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        NSMutableArray<KTVRoomModel *> *roomModelList = [[NSMutableArray alloc] init];
        if ([KTVRTSManager ackModelResponseClass:ackModel]) {
            NSArray *list = ackModel.response[@"room_list"];
            for (int i = 0; i < list.count; i++) {
                KTVRoomModel *roomModel = [KTVRoomModel yy_modelWithJSON:list[i]];
                [roomModelList addObject:roomModel];
            }
        }
        if (block) {
            block([roomModelList copy], ackModel);
        }
    }];
}

+ (void)clearUser:(void (^)(RTSACKModel *model))block {
    NSDictionary *dic = @{};
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvClearUser" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        if (block) {
            block(ackModel);
        }
    }];
}

+ (void)sendMessage:(NSString *)roomID
            message:(NSString *)message
              block:(void (^)(RTSACKModel *model))block {
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)message,NULL,NULL,kCFStringEncodingUTF8));
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
        @"room_id" : (roomID ?: @""),
        @"message" : (encodedString ?: @"")
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvSendMessage" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        if (block) {
            block(ackModel);
        }
    }];
}

+ (void)updateMediaStatus:(NSString *)roomID
                      mic:(NSInteger)mic
                    block:(void (^)(RTSACKModel *model))block {
    NSAssert(roomID, @"roomID is nil");
    NSDictionary *dic = @{
        @"room_id": (roomID ?: @""),
        @"mic": @(mic)
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvUpdateMediaStatus" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        if (block) {
            block(ackModel);
        }
    }];
}

+ (void)reconnect:(NSString *)roomID
            block:(void (^)(NSString *RTCToken,
                            KTVRoomModel *roomModel,
                            KTVUserModel *userModel,
                            KTVUserModel *hostUserModel,
                            KTVSongModel *songModel,
                            NSArray<KTVSeatModel *> *seatList,
                            RTSACKModel *model))block {
    NSDictionary *dic = @{
        @"room_id": (roomID ?: @""),
    };
    
    [[KTVRTCManager shareRtc] emitWithAck:@"ktvReconnect" with:dic block:^(RTSACKModel * _Nonnull ackModel) {
        
        KTVRoomModel *roomModel = nil;
        KTVUserModel *hostUserModel = nil;
        KTVUserModel *userModel = nil;
        KTVSongModel *songModel = nil;
        NSMutableArray<KTVSeatModel *> *seatList = [[NSMutableArray alloc] init];
        NSString *RTCToken = @"";
        if ([KTVRTSManager ackModelResponseClass:ackModel]) {
            roomModel = [KTVRoomModel yy_modelWithJSON:ackModel.response[@"room_info"]];
            hostUserModel = [KTVUserModel yy_modelWithJSON:ackModel.response[@"host_info"]];
            userModel = [KTVUserModel yy_modelWithJSON:ackModel.response[@"user_info"]];
            songModel = [KTVSongModel yy_modelWithJSON:ackModel.response[@"cur_song"]];
            NSDictionary *seatDic = ackModel.response[@"seat_list"];
            for (int i = 0; i < seatDic.allKeys.count; i++) {
                NSString *keyStr = [NSString stringWithFormat:@"%ld", (long)(i + 1)];
                KTVSeatModel *seatModel = [KTVSeatModel yy_modelWithJSON:seatDic[keyStr]];
                seatModel.index = keyStr.integerValue;
                [seatList addObject:seatModel];
            }
            RTCToken = [NSString stringWithFormat:@"%@", ackModel.response[@"rtc_token"]];
        }
        if (block) {
            block(RTCToken,
                  roomModel,
                  userModel,
                  hostUserModel,
                  songModel,
                  [seatList copy],
                  ackModel);
        }
    }];
}

#pragma mark - Notification Message

+ (void)onAudienceJoinRoomWithBlock:(void (^)(KTVUserModel *userModel,
                                              NSInteger count))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnAudienceJoinRoom" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        KTVUserModel *model = nil;
        NSInteger count = -1;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            model = [KTVUserModel yy_modelWithJSON:noticeModel.data[@"user_info"]];
            NSString *str = [NSString stringWithFormat:@"%@", noticeModel.data[@"audience_count"]];
            count = [str integerValue];
        }
        if (block) {
            block(model, count);
        }
    }];
}

+ (void)onAudienceLeaveRoomWithBlock:(void (^)(KTVUserModel *userModel,
                                               NSInteger count))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnAudienceLeaveRoom" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        KTVUserModel *model = nil;
        NSInteger count = -1;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            model = [KTVUserModel yy_modelWithJSON:noticeModel.data[@"user_info"]];
            NSString *str = [NSString stringWithFormat:@"%@", noticeModel.data[@"audience_count"]];
            count = [str integerValue];
        }
        if (block) {
            block(model, count);
        }
    }];
}

+ (void)onFinishLiveWithBlock:(void (^)(NSString *rommID, NSInteger type))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnFinishLive" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        NSInteger type = -1;
        NSString *rommID = @"";
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            NSString *str = [NSString stringWithFormat:@"%@", noticeModel.data[@"type"]];
            type = [str integerValue];
            rommID = [NSString stringWithFormat:@"%@", noticeModel.data[@"room_id"]];
        }
        if (block) {
            block(rommID, type);
        }
    }];
}

+ (void)onJoinInteractWithBlock:(void (^)(KTVUserModel *userModel,
                                          NSString *seatID))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnJoinInteract" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        KTVUserModel *model = nil;
        NSString *seatID = @"";
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            model = [KTVUserModel yy_modelWithJSON:noticeModel.data[@"user_info"]];
            seatID = [NSString stringWithFormat:@"%@", noticeModel.data[@"seat_id"]];
        }
        if (block) {
            block(model, seatID);
        }
    }];
}

+ (void)onFinishInteractWithBlock:(void (^)(KTVUserModel *userModel,
                                            NSString *seatID,
                                            NSInteger type))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnFinishInteract" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        KTVUserModel *model = nil;
        NSString *seatID = @"";
        NSInteger type = -1;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            model = [KTVUserModel yy_modelWithJSON:noticeModel.data[@"user_info"]];
            seatID = [NSString stringWithFormat:@"%@", noticeModel.data[@"seat_id"]];
            NSString *str = [NSString stringWithFormat:@"%@", noticeModel.data[@"type"]];
            type = [str integerValue];
        }
        if (block) {
            block(model, seatID, type);
        }
    }];
}

+ (void)onSeatStatusChangeWithBlock:(void (^)(NSString *seatID,
                                              NSInteger type))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnSeatStatusChange" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        NSInteger type = -1;
        NSString *seatID = @"";
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            NSString *str = [NSString stringWithFormat:@"%@", noticeModel.data[@"type"]];
            type = [str integerValue];
            seatID = [NSString stringWithFormat:@"%@", noticeModel.data[@"seat_id"]];
        }
        if (block) {
            block(seatID, type);
        }
    }];
}

+ (void)onMediaStatusChangeWithBlock:(void (^)(KTVUserModel *userModel,
                                               NSString *seatID,
                                               NSInteger mic))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnMediaStatusChange" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        KTVUserModel *model = nil;
        NSString *seatID = @"";
        NSInteger mic = -1;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            model = [KTVUserModel yy_modelWithJSON:noticeModel.data[@"user_info"]];
            seatID = [NSString stringWithFormat:@"%@", noticeModel.data[@"seat_id"]];
            NSString *str = [NSString stringWithFormat:@"%@", noticeModel.data[@"mic"]];
            mic = [str integerValue];
        }
        if (block) {
            block(model, seatID, mic);
        }
    }];
}

+ (void)onMessageWithBlock:(void (^)(KTVUserModel *userModel,
                                     NSString *message))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnMessage" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        KTVUserModel *model = nil;
        NSString *message = @"";
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            model = [KTVUserModel yy_modelWithJSON:noticeModel.data[@"user_info"]];
            message = [NSString stringWithFormat:@"%@", noticeModel.data[@"message"]];
        }
        if (block) {
            block(model, message);
        }
    }];
}

+ (void)onPickSongBlock:(void(^)(KTVSongModel *songModel))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnRequestSong" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        KTVSongModel *songModel = nil;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            songModel = [KTVSongModel yy_modelWithJSON:noticeModel.data[@"song"]];
        }
        if (block) {
            block(songModel);
        }
    }];
}

+ (void)onStartSingSongBlock:(void(^)(KTVSongModel *songModel))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnStartSing" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        KTVSongModel *songModel = nil;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            songModel = [KTVSongModel yy_modelWithJSON:noticeModel.data[@"song"]];
        }
        if (block) {
            block(songModel);
        }
    }];
}

+ (void)onFinishSingSongBlock:(void(^)(KTVSongModel *nextSongModel,
                                       KTVSongModel *curSongModel,
                                       NSInteger score))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnFinishSing" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        KTVSongModel *nextSongModel = nil;
        KTVSongModel *curSongModel = nil;
        NSInteger score = 0;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            nextSongModel = [KTVSongModel yy_modelWithJSON:noticeModel.data[@"next_song"]];
            curSongModel = [KTVSongModel yy_modelWithJSON:noticeModel.data[@"cur_song"]];
            score = [noticeModel.data[@"score"] integerValue];
        }
        if (block) {
            block(nextSongModel, curSongModel, score);
        }
    }];
}


#pragma mark - Single Notification Message

+ (void)onInviteInteractWithBlock:(void (^)(KTVUserModel *hostUserModel,
                                            NSString *seatID))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnInviteInteract" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        KTVUserModel *model = nil;
        NSString *seatID = @"";
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            model = [KTVUserModel yy_modelWithJSON:noticeModel.data[@"host_info"]];
            seatID = [NSString stringWithFormat:@"%@", noticeModel.data[@"seat_id"]];
        }
        if (block) {
            block(model, seatID);
        }
    }];
}

+ (void)onInviteResultWithBlock:(void (^)(KTVUserModel *userModel,
                                          NSInteger reply))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnInviteResult" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        KTVUserModel *model = nil;
        NSInteger reply = -1;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            model = [KTVUserModel yy_modelWithJSON:noticeModel.data[@"user_info"]];
            NSString *str = [NSString stringWithFormat:@"%@", noticeModel.data[@"reply"]];
            reply = [str integerValue];
        }
        if (block) {
            block(model, reply);
        }
    }];
}

+ (void)onApplyInteractWithBlock:(void (^)(KTVUserModel *userModel,
                                           NSString *seatID))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnApplyInteract" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        KTVUserModel *model = nil;
        NSString *seatID = @"";
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            model = [KTVUserModel yy_modelWithJSON:noticeModel.data[@"user_info"]];
            seatID = [NSString stringWithFormat:@"%@", noticeModel.data[@"seat_id"]];
        }
        if (block) {
            block(model, seatID);
        }
    }];
}

+ (void)onMediaOperateWithBlock:(void (^)(NSInteger mic))block  {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnMediaOperate" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        NSInteger mic = -1;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            NSString *str = [NSString stringWithFormat:@"%@", noticeModel.data[@"mic"]];
            mic = [str integerValue];
        }
        if (block) {
            block(mic);
        }
    }];
}

+ (void)onClearUserWithBlock:(void (^)(NSString *uid))block {
    [[KTVRTCManager shareRtc] onSceneListener:@"ktvOnClearUser" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        
        NSString *uid = @"";
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            uid = [NSString stringWithFormat:@"%@", noticeModel.data[@"user_id"]];
        }
        if (block) {
            block(uid);
        }
    }];
}

#pragma mark - tool

+ (BOOL)ackModelResponseClass:(RTSACKModel *)ackModel {
    if ([ackModel.response isKindOfClass:[NSDictionary class]]) {
        return YES;
    } else {
        return NO;
    }
}

@end
