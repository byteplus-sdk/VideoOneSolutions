#import "KTVRTCManager.h"
#import "AlertActionManager.h"
#import "SystemAuthority.h"



@interface KTVRTCManager () <ByteRTCVideoDelegate>

// RTC / RTS room object
@property (nonatomic, strong, nullable) ByteRTCRoom *rtcRoom;
@property (nonatomic, strong) KTVRoomParamInfoModel *paramInfoModel;
@property (nonatomic, assign) int audioMixingID;
@property (nonatomic, assign) BOOL isAudioMixing;
@property (nonatomic, assign) BOOL isEnableAudioCapture;
@property (nonatomic, assign) ByteRTCAudioRoute currentAudioRoute;
@property (nonatomic, copy) NSString *currentMusicID;

@end

@implementation KTVRTCManager

+ (KTVRTCManager *_Nullable)shareRtc {
    static KTVRTCManager *rtcManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rtcManager = [[KTVRTCManager alloc] init];
    });
    return rtcManager;
}

#pragma mark - Publish Action

- (void)configeRTCEngine {
    [self.rtcEngineKit setAudioScenario:ByteRTCAudioScenarioMedia];
    [self.rtcRoom setUserVisibility:NO];
    self.paramInfoModel.rtt = @"0";
    self.audioMixingID = 3001;
}

- (void)joinChannelWithToken:(NSString *)token roomID:(NSString *)roomID uid:(NSString *)uid {
    self.isEnableAudioCapture = NO;
    // Turn on/off local audio capture
    [self.rtcEngineKit stopAudioCapture];
    [self.rtcEngineKit stopVideoCapture];
    // Set the audio routing mode, YES speaker/NO earpiece
    [self.rtcEngineKit setDefaultAudioRoute:ByteRTCAudioRouteSpeakerphone];
    // Turn on/off speaker volume keying
    ByteRTCAudioPropertiesConfig *audioPropertiesConfig = [[ByteRTCAudioPropertiesConfig alloc] init];
    audioPropertiesConfig.interval = 300;
    [self.rtcEngineKit enableAudioPropertiesReport:audioPropertiesConfig];
    // Join the room, start connecting the microphone, you need to apply for AppId and Token
    ByteRTCUserInfo *userInfo = [[ByteRTCUserInfo alloc] init];
    userInfo.userId = uid;
    ByteRTCRoomConfig *config = [[ByteRTCRoomConfig alloc] init];
    config.profile = ByteRTCRoomProfileKTV;
    config.isAutoPublish = YES;
    config.isAutoSubscribeAudio = YES;
    self.rtcRoom = [self.rtcEngineKit createRTCRoom:roomID];
    self.rtcRoom.delegate = self;
    [self.rtcRoom joinRoom:token
                  userInfo:userInfo
                roomConfig:config];
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
                NSLog(@"KTV RTC Manager == startAudioCapture");
                [self.rtcRoom setUserVisibility:YES];
                [self.rtcRoom publishStream:ByteRTCMediaStreamTypeAudio];
                [self.rtcEngineKit startAudioCapture];
                self.isEnableAudioCapture = YES;
            }
        }];
    } else {
        NSLog(@"KTV RTC Manager == stopAudioCapture");
        [self.rtcRoom setUserVisibility:NO];
        self.isEnableAudioCapture = NO;
        [self.rtcEngineKit stopAudioCapture];
        self.paramInfoModel.rtt = @"0";
    }
}

- (void)muteLocalAudio:(BOOL)mute {
    if (mute) {
        [self.rtcRoom unpublishStream:ByteRTCMediaStreamTypeAudio];
    } else {
        [self.rtcRoom publishStream:ByteRTCMediaStreamTypeAudio];
    }
}

- (void)leaveChannel {
    // close the mix
    [self stopSinging];
    // The ear return restores the default value
    [self enableEarMonitor:NO];
    [self setEarMonitorVolume:100];
    // Leave the channel
    [self.rtcRoom leaveRoom];
}

#pragma mark - Singing Music Method

- (void)startStartSinging:(NSString *)filePath {
    if (IsEmptyStr(filePath)) {
        return;
    }
    
    [self enableEarMonitor:NO];
    
    self.isAudioMixing = YES;
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    ByteRTCAudioMixingConfig *config = [[ByteRTCAudioMixingConfig alloc] init];
    config.type = ByteRTCAudioMixingTypePlayoutAndPublish;
    config.playCount = 1;
    [audioMixingManager startAudioMixing:self.audioMixingID
                                filePath:filePath
                                  config:config];
    [audioMixingManager setAudioMixingProgressInterval:self.audioMixingID interval:100];
}

- (void)pauseSinging {
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    [audioMixingManager pauseAudioMixing:self.audioMixingID];
}

- (void)resumeSinging {
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    [audioMixingManager resumeAudioMixing:self.audioMixingID];
}

- (void)stopSinging {
    self.isAudioMixing = NO;
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    [audioMixingManager stopAudioMixing:self.audioMixingID];
}

- (void)resetAudioMixingStatus {
    self.isAudioMixing = NO;
}

- (void)switchAccompaniment:(BOOL)isAccompaniment {
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    NSInteger trackCount = [audioMixingManager getAudioTrackCount:self.audioMixingID];
    if (trackCount >= 2) {
        if (isAccompaniment) {
            [audioMixingManager selectAudioTrack:self.audioMixingID audioTrackIndex:1];
        } else {
            [audioMixingManager selectAudioTrack:self.audioMixingID audioTrackIndex:2];
        }
    } else {
        if (isAccompaniment) {
            [audioMixingManager setAudioMixingDualMonoMode:self.audioMixingID
                                                      mode:ByteRTCAudioMixingDualMonoModeR];
        } else {
            [audioMixingManager setAudioMixingDualMonoMode:self.audioMixingID
                                                      mode:ByteRTCAudioMixingDualMonoModeL];
        }
    }
}

- (void)sendStreamSyncTime:(NSDictionary *)infoDic {
    if (infoDic && [infoDic isKindOfClass:[NSDictionary class]]) {
        NSData *data = [[infoDic yy_modelToJSONString] dataUsingEncoding:NSUTF8StringEncoding];
        ByteRTCStreamSycnInfoConfig *config = [[ByteRTCStreamSycnInfoConfig alloc] init];
        config.streamIndex = ByteRTCStreamIndexMain;
        config.repeatCount = 3;
        config.streamType = ByteRTCSyncInfoStreamTypeAudio;
        [self.rtcEngineKit sendStreamSyncInfo:data config:config];
    }
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
    
    [audioMixingManager setAudioMixingVolume:self.audioMixingID volume:(int)volume type:ByteRTCAudioMixingTypePlayoutAndPublish];
}

#pragma mark - ByteRTCRoomDelegate

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRoomStateChanged:(NSString *)roomId
               withUid:(NSString *)uid
                 state:(NSInteger)state
             extraInfo:(NSString *)extraInfo {
    [super rtcRoom:rtcRoom onRoomStateChanged:roomId withUid:uid state:state extraInfo:extraInfo];
    if ([rtcRoom.getRoomId isEqualToString:self.rtcRoom.getRoomId]) {
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            RTCJoinModel *joinModel = [RTCJoinModel modelArrayWithClass:extraInfo state:state roomId:roomId];
            if ([self.delegate respondsToSelector:@selector(KTVRTCManager:onRoomStateChanged:uid:)]) {
                [self.delegate KTVRTCManager:self onRoomStateChanged:joinModel uid:uid];
            }
        });
    }
}

#pragma mark - ByteRTCVideoDelegate

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onNetworkQuality:(ByteRTCNetworkQualityStats *)localQuality remoteQualities:(NSArray<ByteRTCNetworkQualityStats *> *)remoteQualities {
    if (self.isEnableAudioCapture) {
        // For users who enable audio capture, the round-trip delay of data transmission.
        self.paramInfoModel.rtt = [NSString stringWithFormat:@"%.0ld",(long)localQuality.rtt];
    } else {
        // 关闭音频采集的用户，数据传输往返时延。
        // For users who turn off audio capture, the round-trip delay of data transmission.
        self.paramInfoModel.rtt = [NSString stringWithFormat:@"%.0ld",(long)remoteQualities.firstObject.rtt];
    }
    // Downlink network quality score
    self.paramInfoModel.rxQuality = localQuality.rxQuality;
    // Uplink network quality score
    self.paramInfoModel.txQuality = localQuality.txQuality;
    [self updateRoomParamInfoModel];
}

- (void)rtcEngine:(ByteRTCVideo *)engine onRemoteAudioPropertiesReport:(NSArray<ByteRTCRemoteAudioPropertiesInfo *> *)audioPropertiesInfos totalRemoteVolume:(NSInteger)totalRemoteVolume {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < audioPropertiesInfos.count; i++) {
        ByteRTCRemoteAudioPropertiesInfo *model = audioPropertiesInfos[i];
        [dic setValue:@(model.audioPropertiesInfo.linearVolume) forKey:model.streamKey.userId];
    }
    if ([self.delegate respondsToSelector:@selector(KTVRTCManager:reportAllAudioVolume:)]) {
        [self.delegate KTVRTCManager:self reportAllAudioVolume:dic];
    }
}

- (void)rtcEngine:(ByteRTCVideo *)engine onLocalAudioPropertiesReport:(NSArray<ByteRTCLocalAudioPropertiesInfo *> *_Nonnull)audioPropertiesInfos {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < audioPropertiesInfos.count; i++) {
        ByteRTCLocalAudioPropertiesInfo *model = audioPropertiesInfos[i];
        [dic setValue:@(model.audioPropertiesInfo.linearVolume) forKey:[LocalUserComponent userModel].uid];
    }
    if ([self.delegate respondsToSelector:@selector(KTVRTCManager:reportAllAudioVolume:)]) {
        [self.delegate KTVRTCManager:self reportAllAudioVolume:dic];
    }
}

/**
 * @type callback
 * @region 音频事件回调
 * @author dixing
 * @brief 音频播放路由变化时，收到该回调。
 * @param device 新的音频播放路由，详见 ByteRTCAudioRouteDevice{@link #ByteRTCAudioRouteDevice}
 * @notes 关于音频路由设置，详见 setAudioRoute:{@link #ByteRTCEngineKit#setAudioRoute:}。
 */
- (void)rtcEngine:(ByteRTCVideo *)engine onAudioRouteChanged:(ByteRTCAudioRoute)device {
    _currentAudioRoute = device;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(KTVRTCManagerOnAudioRouteChanged:)]) {
            [self.delegate KTVRTCManagerOnAudioRouteChanged:self];
        }
    });
}

- (void)rtcEngine:(ByteRTCVideo *)engine onAudioMixingStateChanged:(NSInteger)mixId state:(ByteRTCAudioMixingState)state error:(ByteRTCAudioMixingError)error {
    if (state == ByteRTCAudioMixingStateFinished) {
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(KTVRTCManager:songEnds:)]) {
                [self.delegate KTVRTCManager:self songEnds:YES];
            }
        });
    }
}

- (void)rtcEngine:(ByteRTCVideo *)engine onAudioMixingPlayingProgress:(NSInteger)mixId progress:(int64_t)progress {
        if ([self.delegate respondsToSelector:@selector(KTVRTCManager:onAudioMixingPlayingProgress:)]) {
            [self.delegate KTVRTCManager:self onAudioMixingPlayingProgress:progress];
        }
}

- (void)rtcEngine:(ByteRTCVideo *)engine onStreamSyncInfoReceived:(ByteRTCRemoteStreamKey *)remoteStreamKey streamType:(ByteRTCSyncInfoStreamType)streamType data:(NSData *)data {
    // Cut the song enough to start local playback and still be able to receive callbacks causing the lyrics to flicker
    if (self.isAudioMixing) {
        return;
    }
    
    NSString *json = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NetworkingTool decodeJsonMessage:json];
    
    if ([self.delegate respondsToSelector:@selector(KTVRTCManager:onStreamSyncInfoReceived:)]) {
        [self.delegate KTVRTCManager:self onStreamSyncInfoReceived:dic];
    }
}

#pragma mark - Private Action

- (void)updateRoomParamInfoModel {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(KTVRTCManager:changeParamInfo:)]) {
            [self.delegate KTVRTCManager:self changeParamInfo:self.paramInfoModel];
        }
    });
}

#pragma mark - Getter

- (KTVRoomParamInfoModel *)paramInfoModel {
    if (!_paramInfoModel) {
        _paramInfoModel = [[KTVRoomParamInfoModel alloc] init];
    }
    return _paramInfoModel;
}

@end
