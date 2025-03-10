// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "ChorusDataManager.h"

@interface ChorusRTCManager () <ByteRTCVideoDelegate, ByteRTCAudioFrameObserver>

// RTC / RTS room object
@property (nonatomic, strong, nullable) ByteRTCRoom *rtcRoom;

@property (nonatomic, assign) int audioMixingID;

@property (nonatomic, strong) NSMutableDictionary<NSString *, UIView *> *streamViewDic;
@property (nonatomic, assign, getter=isSuccentorAudioMixing) BOOL succentorAudioMixing;

@property (nonatomic, assign) BOOL isHost;

@property (nonatomic, assign) BOOL isSinger;

@property (nonatomic, assign) ByteRTCAudioRoute currentAudioRoute;

@end

@implementation ChorusRTCManager

+ (ChorusRTCManager *_Nullable)shareRtc {
    static ChorusRTCManager *rtcManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rtcManager = [[ChorusRTCManager alloc] init];
    });
    return rtcManager;
}

#pragma mark - Publish Action

- (void)configeRTCEngine {
    _audioMixingID = 3001;
}

- (void)joinChannelWithToken:(NSString *)token
                      roomID:(NSString *)roomID
                      userID:(NSString *)userID
                      isHost:(BOOL)isHost {
    self.isHost = isHost;
    self.rtcRoom = [self.rtcEngineKit createRTCRoom:roomID];
    self.rtcRoom.delegate = self;
    [self.rtcEngineKit setAudioScenario:ByteRTCAudioScenarioMedia];
    [self.rtcRoom setUserVisibility:isHost];
    if (isHost) {
        [self enableLocalAudio:YES];
        [self bingCanvasViewToUserID:userID];
    }
    [self.rtcEngineKit setLocalVideoMirrorType:ByteRTCMirrorTypeRenderAndEncoder];
    ByteRTCAudioPropertiesConfig *reportConfig = [[ByteRTCAudioPropertiesConfig alloc] init];
    reportConfig.interval = 300;
    [self.rtcEngineKit enableAudioPropertiesReport:reportConfig];
    
    ByteRTCUserInfo *userInfo = [[ByteRTCUserInfo alloc] init];
    userInfo.userId = userID;
    
    ByteRTCRoomConfig *config = [[ByteRTCRoomConfig alloc] init];
    config.profile = ByteRTCRoomProfileKTV;
    config.isAutoPublish = YES;
    config.isAutoSubscribeAudio = YES;
    config.isAutoSubscribeVideo = YES;
    [self.rtcRoom joinRoom:token userInfo:userInfo roomConfig:config];
    [self.rtcEngineKit setAudioScenario:ByteRTCAudioScenarioMedia];
}

- (BOOL)canEarMonitor {
    return _currentAudioRoute == ByteRTCAudioRouteHeadset || _currentAudioRoute == ByteRTCAudioRouteHeadsetUSB;
}

#pragma mark - rtc method

- (void)enableLocalAudio:(BOOL)enable {
    if (enable) {
        [SystemAuthority authorizationStatusWithType:AuthorizationTypeAudio
                                               block:^(BOOL isAuthorize) {
            if (isAuthorize) {
                [self.rtcEngineKit startAudioCapture];
                self->_isMicrophoneOpen = YES;
            }
        }];
    } else {
        [self.rtcEngineKit stopAudioCapture];
        _isMicrophoneOpen = NO;
    }
}

- (void)enableLocalVideo:(BOOL)enable {
    
    if (enable) {
        [SystemAuthority authorizationStatusWithType:AuthorizationTypeCamera
                                               block:^(BOOL isAuthorize) {
            if (isAuthorize) {
                [self.rtcEngineKit startVideoCapture];
            }
        }];
    } else {
        [self.rtcEngineKit stopVideoCapture];
    }
    
    UIView *streamView = [self getStreamViewWithUserID:[LocalUserComponent userModel].uid];
    streamView.hidden = !enable;
    _isCameraOpen = enable;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onRemoteVideoStateChanged" object:nil];
}
- (void)switchIdentifyBecomeSinger:(BOOL)isSinger {
    if (self.isSinger == isSinger) {
        return;
    }
    self.isSinger = isSinger;
    
    if (isSinger) {
        [self.rtcRoom setUserVisibility:YES];
        [self enableLocalAudio:YES];
        [self enableLocalVideo:NO];
        
        [self bingCanvasViewToUserID:[LocalUserComponent userModel].uid];
    } else {
        if (self.isHost) {
            [self enableLocalVideo:NO];
        } else {
            [self.rtcRoom setUserVisibility:NO];
            [self enableLocalAudio:NO];
            [self enableLocalVideo:NO];
            
            NSString *groupKey = [NSString stringWithFormat:@"self_%@", [LocalUserComponent userModel].uid];
            [self.streamViewDic removeObjectForKey:groupKey];
        }
    }
}

- (void)leaveChannel {
    
    [self.streamViewDic removeAllObjects];
    [self stopSinging];
    self.isSinger = NO;
    // Close audio and video capture
    [self enableLocalAudio:NO];
    [self enableLocalVideo:NO];
    // Close ear return
    [self enableEarMonitor:NO];
    // Leave the channel
    [self.rtcRoom leaveRoom];
}

#pragma mark - Render

- (UIView *)getStreamViewWithUserID:(NSString *)userID {
    if (IsEmptyStr(userID)) {
        return nil;
    }
    NSString *typeStr = @"";
    if ([userID isEqualToString:[LocalUserComponent userModel].uid]) {
        typeStr = @"self";
    } else {
        typeStr = @"remote";
    }
    NSString *key = [NSString stringWithFormat:@"%@_%@", typeStr, userID];
    UIView *view = self.streamViewDic[key];
    NSLog(@"Manager RTCSDK getStreamViewWithUid : %@|%@", view, userID);
    
    if(!view && ![userID isEqualToString:[LocalUserComponent userModel].uid]) {
        UIView *remoteRoomView = [[UIView alloc] init];
        remoteRoomView.hidden = YES;
        ByteRTCVideoCanvas *canvas = [[ByteRTCVideoCanvas alloc] init];
        canvas.renderMode = ByteRTCRenderModeHidden;
        canvas.view = remoteRoomView;
        ByteRTCRemoteStreamKey *streamKey = [[ByteRTCRemoteStreamKey alloc] init];
        streamKey.userId = userID;
        streamKey.roomId = self.rtcRoom.getRoomId;
        streamKey.streamIndex = ByteRTCStreamIndexMain;
        [self.rtcEngineKit setRemoteVideoCanvas:streamKey
                                        withCanvas:canvas];
        NSString *groupKey = [NSString stringWithFormat:@"remote_%@", userID];
        [self.streamViewDic setValue:remoteRoomView forKey:groupKey];
        view = remoteRoomView;

    }
    
    return view;
}

- (void)bingCanvasViewToUserID:(NSString *)userID {
    dispatch_queue_async_safe(dispatch_get_main_queue(), (^{
        if ([userID isEqualToString:[LocalUserComponent userModel].uid]) {
            UIView *view = [self getStreamViewWithUserID:userID];
            if (!view) {
                UIView *streamView = [[UIView alloc] init];
                streamView.hidden = YES;
                ByteRTCVideoCanvas *canvas = [[ByteRTCVideoCanvas alloc] init];
                canvas.renderMode = ByteRTCRenderModeHidden;
                canvas.view = streamView;
                [self.rtcEngineKit setLocalVideoCanvas:ByteRTCStreamIndexMain
                                            withCanvas:canvas];
                NSString *key = [NSString stringWithFormat:@"self_%@", userID];
                [self.streamViewDic setValue:streamView forKey:key];
            }
        } else {
            UIView *remoteRoomView = [self getStreamViewWithUserID:userID];
            if (!remoteRoomView) {
                remoteRoomView = [[UIView alloc] init];
                ByteRTCVideoCanvas *canvas = [[ByteRTCVideoCanvas alloc] init];
                canvas.renderMode = ByteRTCRenderModeHidden;
                canvas.view = remoteRoomView;
                
                ByteRTCRemoteStreamKey *streamKey = [[ByteRTCRemoteStreamKey alloc] init];
                streamKey.userId = userID;
                streamKey.roomId = self.rtcRoom.getRoomId;
                streamKey.streamIndex = ByteRTCStreamIndexMain;
                
                [self.rtcEngineKit setRemoteVideoCanvas:streamKey
                                                withCanvas:canvas];
                
                NSString *groupKey = [NSString stringWithFormat:@"remote_%@", userID];
                [self.streamViewDic setValue:remoteRoomView forKey:groupKey];
            }
        }
        NSLog(@"Manager RTCSDK bingCanvasViewToUid : %@", self.streamViewDic);
    }));
}
- (void)updateAudioSubscribeWithChorusStatus:(ChorusStatus)status {
    NSMutableSet<NSString *> *set = [NSMutableSet set];
    [set addObject:[ChorusDataManager shared].roomModel.hostUid];
    if ([ChorusDataManager shared].leadSingerUserModel) {
        [set addObject:[ChorusDataManager shared].leadSingerUserModel.uid];
    }
    if ([ChorusDataManager shared].succentorUserModel) {
        [set addObject:[ChorusDataManager shared].succentorUserModel.uid];
    }
    [set removeObject:[LocalUserComponent userModel].uid];
    
    for (NSString *uid in set) {
        [self.rtcRoom subscribeStream:uid mediaStreamType:ByteRTCMediaStreamTypeBoth];
    }
    if (status != ChorusStatusSinging || ![ChorusDataManager shared].succentorUserModel) {
        return;
    }
    
    if ([ChorusDataManager shared].isLeadSinger) {
        [self.rtcRoom unsubscribeStream:[ChorusDataManager shared].succentorUserModel.uid  mediaStreamType:ByteRTCMediaStreamTypeAudio];
        return;
    }
    
    if (![ChorusDataManager shared].isSuccentor) {
        [self.rtcRoom unsubscribeStream:[ChorusDataManager shared].leadSingerUserModel.uid mediaStreamType:ByteRTCMediaStreamTypeAudio];
    }
    
}
- (void)updateSuccentorAudioMixingWithChorusState:(ChorusStatus)status {
    BOOL needStartAudioMixing = ([ChorusDataManager shared].isSuccentor &&
                                 status == ChorusStatusSinging &&
                                 !self.isSuccentorAudioMixing);
    if (needStartAudioMixing) {
        self.succentorAudioMixing = YES;
        
        ByteRTCAudioMixingManager *manager = [self.rtcEngineKit getAudioMixingManager];
        [manager enableAudioMixingFrame:_audioMixingID type:ByteRTCAudioMixingTypePublish];
        
        [self.rtcEngineKit registerAudioFrameObserver:self];
        ByteRTCAudioFormat *format = [[ByteRTCAudioFormat alloc] init];
        format.sampleRate = ByteRTCAudioSampleRateAuto;
        format.channel = ByteRTCAudioChannelAuto;
        [self.rtcEngineKit enableAudioFrameCallback:ByteRTCAudioFrameCallbackRemoteUser format:format];
    } else {
        if (self.isSuccentorAudioMixing) {
            self.succentorAudioMixing = NO;
            [self.rtcEngineKit registerAudioFrameObserver:nil];
            [self.rtcEngineKit disableAudioFrameCallback:ByteRTCAudioFrameCallbackRemoteUser];
            
            ByteRTCAudioMixingManager *manager = [self.rtcEngineKit getAudioMixingManager];
            [manager disableAudioMixingFrame:_audioMixingID];
        }
    }
}

#pragma mark - Singing Music Method

- (void)startAudioMixingWithFilePath:(NSString *)filePath {
    if (IsEmptyStr(filePath)) {
        return;
    }
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    ByteRTCAudioMixingConfig *config = [[ByteRTCAudioMixingConfig alloc] init];
    config.type = ByteRTCAudioMixingTypePlayoutAndPublish;
    config.playCount = 1;
    [audioMixingManager startAudioMixing:_audioMixingID
                                filePath:filePath
                                  config:config];
    [audioMixingManager setAudioMixingProgressInterval:_audioMixingID interval:100];
}

- (void)stopSinging {
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    [audioMixingManager stopAudioMixing:_audioMixingID];
}

- (void)switchAccompaniment:(BOOL)isAccompaniment {
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    if (isAccompaniment) {
        [audioMixingManager setAudioMixingDualMonoMode:_audioMixingID
                                                  mode:ByteRTCAudioMixingDualMonoModeR];
    } else {
        [audioMixingManager setAudioMixingDualMonoMode:_audioMixingID
                                                  mode:ByteRTCAudioMixingDualMonoModeL];
    }
}

- (void)sendStreamSyncTime:(NSString *)time {
    NSData *data = [time dataUsingEncoding:NSUTF8StringEncoding];
    ByteRTCStreamSycnInfoConfig *config = [[ByteRTCStreamSycnInfoConfig alloc] init];
    [self.rtcEngineKit sendStreamSyncInfo:data config:config];
}

- (void)setVoiceReverbType:(ByteRTCVoiceReverbType)reverbType {
    [self.rtcEngineKit setVoiceReverbType:reverbType];
}

- (void)enableEarMonitor:(BOOL)isEnable {
    [self.rtcEngineKit setEarMonitorMode:isEnable ? ByteRTCEarMonitorModeOn : ByteRTCEarMonitorModeOff];
}

- (void)setEarMonitorVolume:(NSInteger)volume {
    [self.rtcEngineKit setEarMonitorVolume:volume];
}

- (void)setRecordingVolume:(NSInteger)volume {
    [self.rtcEngineKit setCaptureVolume:ByteRTCStreamIndexMain volume:(int)volume];
}

- (void)setMusicVolume:(NSInteger)volume {
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    if ([ChorusDataManager shared].isSuccentor) {
        [audioMixingManager setAudioMixingVolume:_audioMixingID volume:(int)volume type:ByteRTCAudioMixingTypePublish];
        [self.rtcEngineKit setRemoteAudioPlaybackVolume:[ChorusDataManager shared].roomModel.roomID remoteUid:[ChorusDataManager shared].leadSingerUserModel.uid playVolume:volume];
    } else {
        [audioMixingManager setAudioMixingVolume:_audioMixingID volume:(int)volume type:ByteRTCAudioMixingTypePlayoutAndPublish];
    }
}

- (void)rtcEngine:(ByteRTCVideo *)engine onStreamSyncInfoReceived:(ByteRTCRemoteStreamKey *)remoteStreamKey streamType:(ByteRTCSyncInfoStreamType)streamType data:(NSData *)data {
    if ([ChorusDataManager shared].isLeadSinger) {
        return;
    }
    
    NSString *json = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    
    if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onStreamSyncInfoReceived:)]) {
        [self.delegate chorusRTCManager:self onStreamSyncInfoReceived:json];
    }
    if ([ChorusDataManager shared].isSuccentor) {
        ByteRTCStreamSycnInfoConfig *config = [[ByteRTCStreamSycnInfoConfig alloc] init];
        [self.rtcEngineKit sendStreamSyncInfo:data config:config];
    }
}

- (void)rtcEngine:(ByteRTCVideo *)engine onAudioMixingStateChanged:(NSInteger)mixId state:(ByteRTCAudioMixingState)state error:(ByteRTCAudioMixingError)error {
    if (state == ByteRTCAudioMixingStateFinished) {
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onSingEnded:)]) {
                [self.delegate chorusRTCManager:self onSingEnded:YES];
            }
        });
    }
}

- (void)rtcEngine:(ByteRTCVideo *)engine onAudioMixingPlayingProgress:(NSInteger)mixId progress:(int64_t)progress {
    if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onAudioMixingPlayingProgress:)]) {
        [self.delegate chorusRTCManager:self onAudioMixingPlayingProgress:progress];
    }
}

#pragma mark - ByteRTCVideoDelegate

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRoomStateChanged:(NSString *)roomId
        withUid:(NSString *)uid
          state:(NSInteger)state
      extraInfo:(NSString *)extraInfo {
    [super rtcRoom:rtcRoom onRoomStateChanged:roomId withUid:uid state:state extraInfo:extraInfo];
    
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        RTCJoinModel *joinModel = [RTCJoinModel modelArrayWithClass:extraInfo state:state roomId:roomId];
        if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onRoomStateChanged:)]) {
            [self.delegate chorusRTCManager:self onRoomStateChanged:joinModel];
        }
    });
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserJoined:(ByteRTCUserInfo *)userInfo elapsed:(NSInteger)elapsed {
    
    [self bingCanvasViewToUserID:userInfo.userId];
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserLeave:(NSString *)uid reason:(ByteRTCUserOfflineReason)reason {
    
    NSString *groupKey = [NSString stringWithFormat:@"remote_%@", uid];
    [self.streamViewDic removeObjectForKey:groupKey];
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onLocalStreamStats:(ByteRTCLocalStreamStats *)stats {

    ChorusNetworkQualityStatus liveStatus = ChorusNetworkQualityStatusNone;
    if (stats.txQuality == ByteRTCNetworkQualityExcellent ||
        stats.txQuality == ByteRTCNetworkQualityGood) {
        liveStatus = ChorusNetworkQualityStatusGood;
    } else if (stats.txQuality == ByteRTCNetworkQualityPoor ||
               stats.txQuality == ByteRTCNetworkQualityBad) {
        liveStatus = ChorusNetworkQualityStatusPoor;
    } else if (stats.txQuality == ByteRTCNetworkQualityVeryBad ||
               stats.txQuality == ByteRTCNetworkQualityDown) {
        liveStatus = ChorusNetworkQualityStatusBad;
    } else {
        liveStatus = ChorusNetworkQualityStatusNone;
    }
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onNetworkQualityStatus:userID:)]) {
            [self.delegate chorusRTCManager:self onNetworkQualityStatus:liveStatus userID:[LocalUserComponent userModel].uid];
        }
    });
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRemoteStreamStats:(ByteRTCRemoteStreamStats *)stats {
    ChorusNetworkQualityStatus liveStatus = ChorusNetworkQualityStatusNone;
    if (stats.txQuality == ByteRTCNetworkQualityExcellent ||
        stats.txQuality == ByteRTCNetworkQualityGood) {
        liveStatus = ChorusNetworkQualityStatusGood;
    } else {
        liveStatus = ChorusNetworkQualityStatusBad;
    }
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onNetworkQualityStatus:userID:)]) {
            [self.delegate chorusRTCManager:self onNetworkQualityStatus:liveStatus userID:stats.uid];
        }
    });
}

- (void)rtcEngine:(ByteRTCVideo *)engine onFirstRemoteVideoFrameRendered:(ByteRTCRemoteStreamKey *)streamKey withFrameInfo:(ByteRTCVideoFrameInfo *)frameInfo {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onFirstVideoFrameRenderedWithUserID:)]) {
            [self.delegate chorusRTCManager:self onFirstVideoFrameRenderedWithUserID:streamKey.userId];
        }
    });
}

- (void)rtcEngine:(ByteRTCVideo *)engine onFirstLocalVideoFrameCaptured:(ByteRTCStreamIndex)streamIndex withFrameInfo:(ByteRTCVideoFrameInfo *)frameInfo {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onFirstVideoFrameRenderedWithUserID:)]) {
            [self.delegate chorusRTCManager:self onFirstVideoFrameRenderedWithUserID:[LocalUserComponent userModel].uid];
        }
    });
}

- (void)rtcEngine:(ByteRTCVideo *)engine onUserStartVideoCapture:(NSString *)roomId uid:(NSString *)uid {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        UIView *view = [self getStreamViewWithUserID:uid];
        view.hidden = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"onRemoteVideoStateChanged" object:nil];
    });
}

- (void)rtcEngine:(ByteRTCVideo *)engine onUserStopVideoCapture:(NSString *)roomId uid:(NSString *)uid {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        UIView *view = [self getStreamViewWithUserID:uid];
        view.hidden = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"onRemoteVideoStateChanged" object:nil];
    });
}

- (void)rtcEngine:(ByteRTCVideo *)engine onAudioRouteChanged:(ByteRTCAudioRoute)device {
    _currentAudioRoute = device;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(chorusRTCManagerOnAudioRouteChanged:)]) {
            [self.delegate chorusRTCManagerOnAudioRouteChanged:self];
        }
    });
}
- (void)rtcEngine:(ByteRTCVideo *)engine onLocalAudioPropertiesReport:(NSArray<ByteRTCLocalAudioPropertiesInfo *> *)audioPropertiesInfos {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (ByteRTCLocalAudioPropertiesInfo *info in audioPropertiesInfos) {
        [dict setValue:@(info.audioPropertiesInfo.linearVolume) forKey:[LocalUserComponent userModel].uid ? : @""];
    }
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onReportUserAudioVolume:)]) {
            [self.delegate chorusRTCManager:self onReportUserAudioVolume:dict];
        }
    });
    
}
- (void)rtcEngine:(ByteRTCVideo *)engine onRemoteAudioPropertiesReport:(NSArray<ByteRTCRemoteAudioPropertiesInfo *> *)audioPropertiesInfos totalRemoteVolume:(NSInteger)totalRemoteVolume {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (ByteRTCRemoteAudioPropertiesInfo *info in audioPropertiesInfos) {
        [dict setValue:@(info.audioPropertiesInfo.linearVolume) forKey:info.streamKey.userId];
    }
    
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(chorusRTCManager:onReportUserAudioVolume:)]) {
            [self.delegate chorusRTCManager:self onReportUserAudioVolume:dict];
        }
    });
}

#pragma mark - ByteRTCAudioFrameObserver
- (void)onRemoteUserAudioFrame:(ByteRTCRemoteStreamKey * _Nonnull)streamKey audioFrame:(ByteRTCAudioFrame * _Nonnull)audioFrame {
    if ([streamKey.roomId isEqualToString:[ChorusDataManager shared].roomModel.roomID] &&
        [streamKey.userId isEqualToString:[ChorusDataManager shared].leadSingerUserModel.uid] &&
        [ChorusDataManager shared].isSuccentor) {
        
        ByteRTCAudioMixingManager *manager = [self.rtcEngineKit getAudioMixingManager];
        [manager pushAudioMixingFrame:_audioMixingID audioFrame:audioFrame];
    }
}

- (void)onMixedAudioFrame:(ByteRTCAudioFrame * _Nonnull)audioFrame {
    
}


- (void)onPlaybackAudioFrame:(ByteRTCAudioFrame * _Nonnull)audioFrame {
    
}


- (void)onRecordAudioFrame:(ByteRTCAudioFrame * _Nonnull)audioFrame {
    
}


#pragma mark - Getter

- (NSMutableDictionary<NSString *, UIView *> *)streamViewDic {
    if (!_streamViewDic) {
        _streamViewDic = [[NSMutableDictionary alloc] init];
    }
    return _streamViewDic;
}

@end
