// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRtcLinkSession.h"
#import "LiveRoomInfoModel.h"
#import "LiveNormalPushStreamingImpl.h"
#import "LiveRTCManager.h"
#import "LiveRTCInteract.h"


@interface LiveRtcLinkSession () <LiveRTCInteractDelegate, LiveNormalPushStreamingNetworkChangeDelegate>


@property (nonatomic, strong) LiveRoomInfoModel *roomModel;

// live broadcast push service, both audio and video stream are provided by rtcSDK.
@property (nonatomic, strong, readwrite) id<LiveNormalPushStreaming> normalPushStreaming;
@property (nonatomic, strong) id<LiveInteractivePushStreaming> interactivePushStreaming;

@end

@implementation LiveRtcLinkSession

- (instancetype)initWithRoom:(LiveRoomInfoModel *)roomModel {
    if (self = [super init]) {
        _roomModel = roomModel;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"aaa dealloc linkSession");
    [self stopInteractive];
    [self stopNormalStreaming];
}

- (BOOL)p_isHost {
    return self.roomModel.anchorUserID.length && [self.roomModel.anchorUserID isEqualToString:self.roomModel.hostUserModel.uid];
}

- (void)startNormalStreaming {
    if (![self p_isHost]) {
        return;
    }
    NSAssert(self.streamConfig, @"you should config streamConfig when you create a live");
    if (!self.normalPushStreaming) {
        LiveNormalPushStreamingImpl *impl = [[LiveNormalPushStreamingImpl alloc] init];
        impl.streamConfig = self.streamConfig;
        impl.delegate = self;
        self.normalPushStreaming = impl;
    }
    [self.normalPushStreaming startNormalStreaming];
}

- (void)stopNormalStreaming {
    [self.normalPushStreaming stopNormalStreaming];
}

- (void)startInteractive:(LiveInteractivePlayMode)playMode {
    LivePushStreamParams *params = [[LivePushStreamParams alloc] init];
    params.rtcToken = self.roomModel.rtcToken;
    params.rtcRoomId = self.roomModel.rtcRoomId;
    params.pushUrl = self.streamConfig.rtmpUrl;
    params.currerntUserId = [LocalUserComponent userModel].uid;
    params.host = self.roomModel.hostUserModel;
    if (!self.interactivePushStreaming) {
        LiveRTCInteract *interact = [[LiveRTCInteract alloc] initWithPushStreamParams:params];
        interact.delegate = self;
        self.interactivePushStreaming = interact;
        
    } else {
        LiveRTCInteract *interact = (LiveRTCInteract *)self.interactivePushStreaming;
        interact.delegate = self;
        [interact updateStreamParams:params];
    }
    [self.interactivePushStreaming startInteractive];
    [self switchPlayMode:playMode];
    NSLog(@"bb pull %@", [self.roomModel.streamPullStreamList objectForKey:@"720"]);
}

- (void)stopInteractive {
    [self.interactivePushStreaming stopInteractive];
    self.interactivePushStreaming = nil;
}
- (BOOL)isInteracting {
    return [self.interactivePushStreaming isInteracting];
}

- (void)onUserListChanged:(NSArray<LiveUserModel *> *)userList {
    _userList = userList.copy;
    [self.interactivePushStreaming onUserListChanged:userList];
}

- (void)switchPlayMode:(LiveInteractivePlayMode)playMode {
    [self.interactivePushStreaming switchPlayMode:playMode];
}

- (void)switchVideoCapture:(BOOL)isStart {
    [[LiveRTCManager shareRtc] switchVideoCapture:isStart];
}

- (void)switchAudioCapture:(BOOL)isStart {
    [[LiveRTCManager shareRtc] switchAudioCapture:isStart];
}

- (void)startForwardStreamToRooms:(NSString *)rtcRoomId token:(NSString *)rtcToken {
    [self.interactivePushStreaming startForwardStreamToRooms:rtcRoomId token:rtcToken];
}


#pragma mark - LiveNormalPushStreamingNetworkChangeDelegate

- (void)updateOnNetworkStatusChange:(LiveCoreNetworkQuality)status {
    if([self.netwrokDelegate respondsToSelector:@selector(updateOnNetworkStatusChange:)]) {
        [self.netwrokDelegate updateOnNetworkStatusChange:status];
    }
}

#pragma mark -- LiveRTCInteractDelegate

- (void)rtcInteract:(LiveRTCInteract *_Nullable)interact didJoinChannel:(NSString *_Nullable)channelId withUid:(NSString *_Nullable)uid elapsed:(NSInteger)elapsed {
    
}

- (void)rtcInteract:(LiveRTCInteract *_Nullable)interact onUserPublishStream:(NSString *_Nullable)uid {
    if (uid.length && [self.roomModel.hostUserModel.uid isEqualToString:uid]) {
        [self.normalPushStreaming stopNormalStreaming];
    }
    [self.interactiveDelegate liveInteractiveOnUserPublishStream:uid];
}

- (void)rtcInteract:(LiveRTCInteract *)interact onMixingStreamSuccess:(ByteRTCStreamMixingType)mixType {
    if (mixType == ByteRTCStreamMixingTypeByServer) {
        [self.normalPushStreaming stopNormalStreaming];
    }
}


@end
