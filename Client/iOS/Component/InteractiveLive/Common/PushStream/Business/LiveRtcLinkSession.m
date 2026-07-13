// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRtcLinkSession.h"
#import "LiveRTCInteract.h"
#import "LiveRTCManager.h"
#import "LiveRoomInfoModel.h"
#import "LiveSettingVideoConfig.h"

@interface LiveRtcLinkSession () <LiveRTCInteractDelegate>

@property (nonatomic, strong) LiveRoomInfoModel *roomModel;

// live broadcast push service, both audio and video stream are provided by rtcSDK.
//@property (nonatomic, strong, readwrite) id<LiveNormalPushStreaming> normalPushStreaming;
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
    NSAssert(self.rtmpUrl, @"you should config streamConfig when you create a live");
    LivePushStreamParams *params = [[LivePushStreamParams alloc] init];
    params.rtcToken = self.roomModel.rtcToken;
    params.rtcRoomId = self.roomModel.rtcRoomId;
    params.pushUrl = self.rtmpUrl;
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
    [self.interactivePushStreaming startPushStream];
}

- (void)stopNormalStreaming {
//    no use
}

- (void)startInteractive:(LiveInteractivePlayMode)playMode {
    LivePushStreamParams *params = [[LivePushStreamParams alloc] init];
    params.rtcToken = self.roomModel.rtcToken;
    params.rtcRoomId = self.roomModel.rtcRoomId;
    params.pushUrl = self.rtmpUrl;
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
    [self.interactivePushStreaming switchPlayMode:playMode];
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

- (void)switchVideoCapture:(BOOL)isStart {
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
//        [self.normalPushStreaming stopNormalStreaming];
    }
    [self.interactiveDelegate liveInteractiveOnUserPublishStream:uid];
}

- (void)rtcInteract:(LiveRTCInteract *)interact onMixingStreamSuccess:(ByteRTCMixedStreamPushTargetType)mixType {
//        [self.normalPushStreaming stopNormalStreaming];
}

@end
