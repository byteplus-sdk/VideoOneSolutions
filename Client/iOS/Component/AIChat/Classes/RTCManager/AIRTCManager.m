//
//  AIRTCManager.m
//  AFNetworking
//
//  Created by ByteDance on 2025/3/13.
//

static inline void DispatchSafeAsyncRunOnMainThread(void (^ _Nullable block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

#import "AIRTCManager.h"

@interface AIRTCManager ()

@property (nonatomic, strong) ByteRTCRoom *chatRoom;

@end

@implementation AIRTCManager
- (void)joinRoom:(NSString *)token
          roomId:(nonnull NSString *)roomId
          userId:(nonnull NSString *)userId  block:(void (^)(int res))block{
    if (self.chatRoom) {
        [self.chatRoom destroy];
        self.chatRoom = nil;
    }
    self.chatRoom = [self.rtcEngineKit createRTCRoom:roomId];
    self.chatRoom.delegate = self;
    ByteRTCUserInfo *info = [[ByteRTCUserInfo alloc] init];
    info.userId = userId;
    info.extraInfo = @"";
    
    ByteRTCRoomConfig *config = [[ByteRTCRoomConfig alloc] init];
    config.profile = ByteRTCRoomProfileChat;
    config.isAutoPublish = YES;
    config.isAutoSubscribeAudio = YES;
    config.isAutoSubscribeVideo = NO;
    int res = [self.chatRoom joinRoom:token userInfo:info roomConfig:config];
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if (block) {
            block(res);
        }
    });
}

- (void)configeRTCEngine {
    ByteRTCAudioPropertiesConfig *audioConfig = [ByteRTCAudioPropertiesConfig new];
    audioConfig.interval = 700;
    audioConfig.smooth = 0.3;
    [self.rtcEngineKit enableAudioPropertiesReport:audioConfig];
}

- (void)leaveRoom {
    [self.chatRoom leaveRoom];
}

- (void)startPublishAudio {
    if (self.chatRoom) {
        [self.chatRoom publishStream:ByteRTCMediaStreamTypeAudio];
    }
}

- (void)stopPublishAudio {
    if (self.chatRoom) {
        [self.chatRoom unpublishStream:ByteRTCMediaStreamTypeAudio];
    }
}

- (void)startAudioCapture {
    [self.rtcEngineKit startAudioCapture];
}

- (void)stopAudioCapture {
    [self.rtcEngineKit stopAudioCapture];
}

- (ByteRTCMediaPlayer *)getMediaPlayer {
    return [self.rtcEngineKit getMediaPlayer:0];
}

#pragma mark - ByteRTCVideoDelegate

- (void)rtcEngine:(ByteRTCVideo *)engine onUserStartAudioCapture:(NSString *)roomId uid:(NSString *)userId {
    VOLogD(VOAIChat, @"onUserStartAudioCapture");
}

- (void)rtcEngine:(ByteRTCVideo *)engine onUserStopAudioCapture:(NSString *)roomId uid:(NSString *)userId {
    VOLogD(VOAIChat, @"onUserStopAudioCapture");
}


- (void)rtcEngine:(ByteRTCVideo *)engine onLocalAudioPropertiesReport:(NSArray<ByteRTCLocalAudioPropertiesInfo *> *)audioPropertiesInfos {
    
}

- (void)rtcEngine:(ByteRTCVideo *)engine onRemoteAudioPropertiesReport:(NSArray<ByteRTCRemoteAudioPropertiesInfo *> *)audioPropertiesInfos totalRemoteVolume:(NSInteger)totalRemoteVolume {
    
}

- (void)rtcEngine:(ByteRTCVideo *)engine onActiveSpeaker:(NSString *)roomId uid:(NSString *)uid {
    if ([self.delegate respondsToSelector:@selector(onActiveSpeakerChange:)]) {
        WeakSelf
        DispatchSafeAsyncRunOnMainThread(^{
            StrongSelf
            [sself.delegate onActiveSpeakerChange:[[LocalUserComponent userModel].uid isEqualToString:uid]];
        });
    }
    
}

#pragma mark - ByteRTCRoomDelegate

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRoomStateChanged:(NSString *)roomId withUid:(NSString *)uid state:(NSInteger)state extraInfo:(NSString *)extraInfo {
    if (state != 0)  {
        [[ToastComponent shareToastComponent]
         showWithMessage:[NSString stringWithFormat:@"onRoomStateChanged state: %ld", (long)state]];
    }
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onLeaveRoom:(ByteRTCRoomStats *)stats {
    VOLogD(VOAIChat, @"onLeaveRoom");
    WeakSelf
    DispatchSafeAsyncRunOnMainThread(^{
        StrongSelf
        if (sself.chatRoom) {
            [sself.chatRoom destroy];
            sself.chatRoom = nil;
        }
    });
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserJoined:(ByteRTCUserInfo *)userInfo elapsed:(NSInteger)elapsed {
    VOLogD(VOAIChat, @"onUserJoined userId:%@", userInfo.userId);
    if ([self.delegate respondsToSelector:@selector(onAIReady)]) {
        WeakSelf
        DispatchSafeAsyncRunOnMainThread(^{
            StrongSelf
            [sself.delegate onAIReady];
        });
    }
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserLeave:(NSString *)uid reason:(ByteRTCUserOfflineReason)reason {
    VOLogD(VOAIChat, @"onUserLeave userId:%@, reason: %ld", uid, reason);
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserPublishStream:(NSString *)userId type:(ByteRTCMediaStreamType)type {
    VOLogD(VOAIChat, @"onUserPublishStream userId:%@", userId);
}


- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserUnpublishStream:(NSString *)userId type:(ByteRTCMediaStreamType)type reason:(ByteRTCStreamRemoveReason)reason {
    VOLogD(VOAIChat, @"onUserUnpublishStream userId:%@, reason: %ld", userId, reason);

}
@end
