// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRtcLinkSession.h"
#import "LiveNormalPushStreamingImpl.h"
#import "LiveRTCInteract.h"
#import "LiveRTCManager.h"
#import "LiveRoomInfoModel.h"
#import "LiveSettingVideoConfig.h"

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
    [self.normalPushStreaming toggleReconnectCapability:YES];
}

- (void)stopNormalStreaming {
    [self.normalPushStreaming stopNormalStreaming];
}

- (void)startInteractive:(LiveInteractivePlayMode)playMode {
    [self.normalPushStreaming toggleReconnectCapability:NO];
    LivePushStreamParams *params = [[LivePushStreamParams alloc] init];
    params.rtcToken = self.roomModel.rtcToken;
    params.rtcRoomId = self.roomModel.rtcRoomId;
    params.pushUrl = self.streamConfig.rtmpUrl;
    params.currerntUserId = [LocalUserComponent userModel].uid;
    params.host = self.roomModel.hostUserModel;

    LiveSettingVideoConfig *videoConfig = [LiveSettingVideoConfig defaultVideoConfig];
    params.width = videoConfig.videoSize.width;
    params.height = videoConfig.videoSize.height;
    params.fps = videoConfig.fps;
    params.gop = 2;
    params.minBitrate = videoConfig.minBitrate;
    params.maxBitrate = videoConfig.maxBitrate;
    params.defaultBitrate = videoConfig.defaultBitrate;

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

    WeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        StrongSelf;
        // manually stop normal pushing in case we can receive mixstream success event while linking.
        if ([sself.interactivePushStreaming isInteracting]) {
            [sself stopNormalStreaming];
        }
    });
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
    if (self.normalPushStreaming) {
        [self.normalPushStreaming cameraStateChanged:isStart];
    }
    [[LiveRTCManager shareRtc] switchVideoCapture:isStart];
}

- (void)switchAudioCapture:(BOOL)isStart {
    [[LiveRTCManager shareRtc] switchAudioCapture:isStart];
}

- (void)startForwardStreamToRooms:(NSString *)rtcRoomId token:(NSString *)rtcToken {
    [self.interactivePushStreaming startForwardStreamToRooms:rtcRoomId token:rtcToken];
}

- (void)updatePushStreamBitrate:(NSInteger)bitrate {
    //    if ([self.interactivePushStreaming isInteracting]) {
    //        [self.interactivePushStreaming updatePushStreamBitrate:bitrate];
    //    } else {
    //        [self.normalPushStreaming updatePushStreamBitrate:bitrate];
    //    }
}

- (void)updatePushStreamResolution:(CGSize)resolution {
    if ([self.interactivePushStreaming isInteracting]) {
        [self.interactivePushStreaming updatePushStreamResolution:resolution];
    } else {
        //        [self.normalPushStreaming updatePushStreamResolution:resolution];
    }
}

- (void)updateVideoEncoderResolution:(CGSize)resolution {
    if ([self.interactivePushStreaming isInteracting]) {
        [self.interactivePushStreaming updatePushStreamResolution:resolution];
    }
}

#pragma mark - LiveRtcLinkSessionNetworkChangeDelegate

- (void)updateOnNetworkStatusChange:(LiveNetworkQualityStatus)status {
    if ([self.netwrokDelegate respondsToSelector:@selector(updateOnNetworkStatusChange:)]) {
        [self.netwrokDelegate updateOnNetworkStatusChange:status];
    }
}

#pragma mark-- LiveRTCInteractDelegate

- (void)rtcInteract:(LiveRTCInteract *_Nullable)interact didJoinChannel:(NSString *_Nullable)channelId withUid:(NSString *_Nullable)uid elapsed:(NSInteger)elapsed {
}

- (void)rtcInteract:(LiveRTCInteract *_Nullable)interact onUserPublishStream:(NSString *_Nullable)uid {
    if (uid.length && [self.roomModel.hostUserModel.uid isEqualToString:uid]) {
        [self.normalPushStreaming stopNormalStreaming];
    }
    [self.interactiveDelegate liveInteractiveOnUserPublishStream:uid];
}

- (void)rtcInteract:(LiveRTCInteract *)interact onMixingStreamSuccess:(ByteRTCMixedStreamType)mixType {
    if (mixType == ByteRTCMixedStreamByServer) {
        [self.normalPushStreaming stopNormalStreaming];
    }
}

@end
