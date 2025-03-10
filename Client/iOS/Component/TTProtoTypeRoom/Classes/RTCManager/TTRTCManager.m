// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "TTRTCManager.h"
#import "NetworkingManager+TTProto.h"
#import <ToolKit/ToolKit.h>

@interface TTRTCManager ()

@property (nonatomic, strong, nullable) ByteRTCRoom *businessRoom;
@property (nonatomic, strong) NSString *preRoomId;
@end

@implementation TTRTCManager

+ (TTRTCManager *_Nullable)shareRtc {
    static TTRTCManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTRTCManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _preRoomId = @"";
    }
    return self;
}

- (void)disconnect {
    [super disconnect];
    _preRoomId = @"";
    _businessRoom = nil;
    [self offSceneListener];
}

- (void)joinRoomByToken:(NSString *)token
                     roomID:(NSString *)roomID
                 userID:(NSString *)userID {
    if (self.businessRoom) {
        if (![[self.businessRoom getRoomId] isEqualToString:roomID]) {
            [self leaveRoom];
        } else {
            return;
        }
    }
    self.businessRoom = [self.rtcEngineKit createRTCRoom:roomID];
    self.businessRoom.delegate = self;
    ByteRTCUserInfo *userInfo = [[ByteRTCUserInfo alloc] init];
    userInfo.userId = userID;

    ByteRTCRoomConfig *config = [[ByteRTCRoomConfig alloc] init];
    config.isAutoPublish = NO;
    config.isAutoSubscribeAudio = NO;
    config.isAutoSubscribeVideo = NO;
    [self.businessRoom joinRoom:token
                       userInfo:userInfo
                     roomConfig:config];
}

- (void)leaveRoom {
    NSString *curRoomId = [self.businessRoom getRoomId];
    [NetworkingManager liveSwitchFeedRoom:curRoomId newRoomId:@"" userId:[LocalUserComponent userModel].uid success:^(NSInteger audienceCount) {
        VOLogI(VOTTProto, @"leaveLiveRoom, audienceCount: %ld", audienceCount);
    } failure:^(NSString * _Nonnull errorMessage) {
        VOLogI(VOTTProto, @"leaveLiveRoom,%@", errorMessage);
    }];
    _preRoomId = @"";
    [self.businessRoom leaveRoom];
    [self.businessRoom destroy];
    self.businessRoom = nil;
}


#pragma mark -- ByteRTCRoomDelegate
- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRoomStateChanged:(NSString *)roomId withUid:(NSString *)uid state:(NSInteger)state extraInfo:(NSString *)extraInfo {
    VOLogI(VOTTProto, @"rtcCallback, roomId: %@", roomId);
    if (![self.preRoomId isEqualToString:roomId]) {
        [NetworkingManager liveSwitchFeedRoom:self.preRoomId newRoomId:roomId userId:uid success:^(NSInteger audienceCount) {
            VOLogI(VOTTProto, @"joinRoom, audienceCount: %ld", audienceCount);
        } failure:^(NSString * _Nonnull errorMessage) {
            VOLogI(VOTTProto, @"joinRoomFailed,%@", errorMessage);
        }];
        _preRoomId = roomId;
    }
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserJoined:(ByteRTCUserInfo *)userInfo elapsed:(NSInteger)elapsed {
    VOLogI(VOTTProto, @"rtcCallback");
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserLeave:(NSString *)uid reason:(ByteRTCUserOfflineReason)reason {
    VOLogI(VOTTProto, @"rtcCallback");
}
@end
