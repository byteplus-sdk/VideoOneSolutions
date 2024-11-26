// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRTCManager.h"
#import "LiveSettingVideoConfig.h"

@interface LiveRTCManager () <ByteRTCVideoDelegate>

// Business RTS room. Audience users do not need to join the RTC room when they are not make guest, but they need to join the RTS room for business logic processing.
@property (nonatomic, strong) ByteRTCRoom *businessRoom;

// RTC room object
@property (nonatomic, strong, nullable) ByteRTCRoom *rtcRoom;

// RTC Push video streaming settings
@property (nonatomic, strong) ByteRTCVideoEncoderConfig *pushRTCVideoConfig;

// Video stream and user model binding use
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIView *> *streamViewDic;
@property (nonatomic, assign) ByteRTCCameraID cameraID;
@property (nonatomic, assign) BOOL isVideoCaptued;
@property (nonatomic, assign) BOOL isAudioCaptued;

// Network Quality Block
@property (nonatomic, copy) void (^networkQualityBlock)(LiveNetworkQualityStatus status,
                                                        NSString *uid);
@end

@implementation LiveRTCManager

+ (LiveRTCManager *_Nullable)shareRtc {
    static LiveRTCManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LiveRTCManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.cameraID = ByteRTCCameraIDFront;
    }
    return self;
}

- (void)configeRTCEngine {
    [super configeRTCEngine];
    // Set RTC acquisition resolution and frame rate.
    ByteRTCVideoCaptureConfig *captureConfig = [[ByteRTCVideoCaptureConfig alloc] init];
    captureConfig.videoSize = CGSizeMake(1280, 720);
    captureConfig.frameRate = 15;
    captureConfig.preference = ByteRTCVideoCapturePreferenceAutoPerformance;
    [self.rtcEngineKit setVideoCaptureConfig:captureConfig];
    // Set the RTC encoding resolution, frame rate, and bit rate.
    [self.rtcEngineKit setMaxVideoEncoderConfig:self.pushRTCVideoConfig];

    // Set up video mirroring
    [self.rtcEngineKit setLocalVideoMirrorType:ByteRTCMirrorTypeRenderAndEncoder];

    // Audio Capture
    ByteRTCAudioFormat *audioFormat = [[ByteRTCAudioFormat alloc] init];
    audioFormat.sampleRate = 44100;
    audioFormat.channel = 2;
    [self.rtcEngineKit enableAudioProcessor:ByteRTCAudioFrameProcessorRecord audioFormat:audioFormat];
}

- (void)disconnect {
    [super disconnect];
    [self cleanAllStreamViews];
}

- (void)joinLiveRoomByToken:(NSString *)token
                     roomID:(NSString *)roomID
                     userID:(NSString *)userID {
    if (self.businessRoom) {
        [self leaveLiveRoom];
    }
    // To join a business RTS room, both the anchor and the audience need to join.
    self.businessRoom = [self.rtcEngineKit createRTCRoom:roomID];
    self.businessRoom.delegate = self;
    ByteRTCUserInfo *userInfo = [[ByteRTCUserInfo alloc] init];
    userInfo.userId = userID;

    ByteRTCRoomConfig *config = [[ByteRTCRoomConfig alloc] init];
    config.profile = ByteRTCRoomProfileInteractivePodcast;
    config.isAutoPublish = NO;
    config.isAutoSubscribeAudio = NO;
    config.isAutoSubscribeVideo = NO;
    [self.businessRoom joinRoom:token
                       userInfo:userInfo
                     roomConfig:config];
}

- (void)leaveLiveRoom {
    // Leave the RTS business room.
    CGSize videoSize = [LiveSettingVideoConfig defaultVideoConfig].videoSize;
    [self updateVideoEncoderResolution:videoSize];
    [self.rtcEngineKit stopPushStreamToCDN:@""];
    [self leaveRTCRoom];

    [self switchAudioCapture:NO];
    [self switchVideoCapture:NO];

    [self.businessRoom leaveRoom];
    [self.businessRoom destroy];
    self.businessRoom = nil;

    self.cameraID = ByteRTCCameraIDFront;
    [self switchCamera:ByteRTCCameraIDFront];
    _pushRTCVideoConfig = nil;
}

- (void)joinRTCRoomByToken:(NSString *)token
                 rtcRoomID:(NSString *)rtcRoomID
                    userID:(NSString *)userID {
    // Join the RTC room, which needs to be joined when the host and the mic audience start an audio and video call.
    ByteRTCUserInfo *userInfo = [[ByteRTCUserInfo alloc] init];
    userInfo.userId = userID;
    ByteRTCRoomConfig *config = [[ByteRTCRoomConfig alloc] init];
    config.profile = ByteRTCRoomProfileInteractivePodcast;
    config.isAutoPublish = YES;
    config.isAutoSubscribeAudio = YES;
    config.isAutoSubscribeVideo = YES;
    self.rtcRoom = [self.rtcEngineKit createRTCRoom:rtcRoomID];
    self.rtcRoom.delegate = self;
    [self.rtcRoom joinRoom:token userInfo:userInfo roomConfig:config];
}

- (void)leaveRTCRoom {
    // Leaving the RTC room, you need to leave the room when the audio and video call ends.
    [self.rtcRoom leaveRoom];
    [self.rtcRoom destroy];
    self.rtcRoom = nil;
}

- (void)startForwardStreamToRooms:(NSString *)roomId token:(NSString *)token {
    // Enable forward stream
    ByteRTCForwardStreamConfiguration *configuration = [[ByteRTCForwardStreamConfiguration alloc] init];
    configuration.roomId = roomId;
    configuration.token = token;

    [self.rtcRoom startForwardStreamToRooms:@[configuration]];
}

- (void)stopForwardStreamToRooms {
    // End forward stream
    CGSize videoSize = [LiveSettingVideoConfig defaultVideoConfig].videoSize;
    self.pushRTCVideoConfig.width = videoSize.width;
    self.pushRTCVideoConfig.height = videoSize.height;

    [self.rtcEngineKit setMaxVideoEncoderConfig:self.pushRTCVideoConfig];
    [self.rtcRoom stopForwardStreamToRooms];
}

#pragma mark - Device Setting

- (void)switchVideoCapture:(BOOL)isStart {
    // Switch camera capture
    if (_isVideoCaptued != isStart) {
        _isVideoCaptued = isStart;
        if (isStart) {
            [self.rtcEngineKit startVideoCapture];
        } else {
            [self.rtcEngineKit stopVideoCapture];
        }
    }
}

- (void)switchAudioCapture:(BOOL)isStart {
    // Switch microphone capture
    if (_isAudioCaptued != isStart) {
        _isAudioCaptued = isStart;
        if (isStart) {
            [self.rtcEngineKit startAudioCapture];
        } else {
            [self.rtcEngineKit stopAudioCapture];
        }
    }
}

- (BOOL)getCurrentVideoCapture {
    return self.isVideoCaptued;
}

- (void)switchCamera {
    // Switch to the front-facing/back-facing camera
    if (self.cameraID == ByteRTCCameraIDFront) {
        self.cameraID = ByteRTCCameraIDBack;
    } else {
        self.cameraID = ByteRTCCameraIDFront;
    }
    [self switchCamera:self.cameraID];
}

- (void)switchCamera:(ByteRTCCameraID)cameraID {
    if (cameraID == ByteRTCCameraIDFront) {
        [self.rtcEngineKit setLocalVideoMirrorType:ByteRTCMirrorTypeRenderAndEncoder];
    } else {
        [self.rtcEngineKit setLocalVideoMirrorType:ByteRTCMirrorTypeNone];
    }
    [self.rtcEngineKit switchCamera:cameraID];
}

- (void)updateVideoEncoderResolution:(CGSize)size {
    // Update RTC encoding resolution
    self.pushRTCVideoConfig.width = size.width;
    self.pushRTCVideoConfig.height = size.height;
    [self.rtcEngineKit setMaxVideoEncoderConfig:self.pushRTCVideoConfig];
}

- (void)updateVideoEncoderFrameRate:(NSInteger)frameRate {
    self.pushRTCVideoConfig.frameRate = frameRate;
    [self.rtcEngineKit setMaxVideoEncoderConfig:self.pushRTCVideoConfig];
}

#pragma mark - NetworkQuality

- (void)didChangeNetworkQuality:(void (^)(LiveNetworkQualityStatus status, NSString *uid))block {
    self.networkQualityBlock = block;
}

- (BOOL)isSupportClientPushStream {
    return NO;
}

#pragma mark - ByteRTCRoomDelegate

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRoomStateChanged:(NSString *)roomId
               withUid:(NSString *)uid
                 state:(NSInteger)state
             extraInfo:(NSString *)extraInfo {
    [super rtcRoom:rtcRoom onRoomStateChanged:roomId withUid:uid state:state extraInfo:extraInfo];
    if ([rtcRoom.getRoomId isEqualToString:self.rtcRoom.getRoomId]) {
        // Join the RTC room successfully
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            [self bindCanvasViewToUid:uid];
            RTCJoinModel *joinModel = [RTCJoinModel modelArrayWithClass:extraInfo state:state roomId:roomId];
            if ([self.delegate respondsToSelector:@selector(liveRTCManager:onRoomStateChanged:uid:)]) {
                [self.delegate liveRTCManager:self onRoomStateChanged:joinModel uid:uid];
            }
        });
    } else {
        RTCJoinModel *joinModel = [RTCJoinModel modelArrayWithClass:extraInfo state:state roomId:roomId];
        if (joinModel.joinType != 0) {
            if ([self.businessDelegate respondsToSelector:@selector(LiveRTCManagerReconnectDelegate:onRoomStateChanged:uid:)]) {
                [self.businessDelegate LiveRTCManagerReconnectDelegate:self onRoomStateChanged:joinModel uid:uid];
            }
        }
    }
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserJoined:(ByteRTCUserInfo *)userInfo elapsed:(NSInteger)elapsed {
    BOOL result = NO;
    if ([self.delegate respondsToSelector:@selector(liveRTCManager:onUserJoined:)]) {
        result = [self.delegate liveRTCManager:self onUserJoined:userInfo.userId];
    }
    if (result && [rtcRoom.getRoomId isEqualToString:self.rtcRoom.getRoomId]) {
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            [self bindCanvasViewToUid:userInfo.userId];
        });
    }
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserPublishStream:(NSString *)userId type:(ByteRTCMediaStreamType)type {
    if (type == ByteRTCMediaStreamTypeBoth ||
        type == ByteRTCMediaStreamTypeVideo) {
        dispatch_queue_async_safe(dispatch_get_main_queue(), (^{
            if ([self.delegate respondsToSelector:@selector(liveRTCManager:onUserPublishStream:)]) {
                [self.delegate liveRTCManager:self onUserPublishStream:userId];
            }
        }));
    }
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onLocalStreamStats:(ByteRTCLocalStreamStats *)stats {
    LiveNetworkQualityStatus liveStatus = LiveNetworkQualityStatusNone;
    if (stats.txQuality == ByteRTCNetworkQualityExcellent ||
        stats.txQuality == ByteRTCNetworkQualityGood) {
        liveStatus = LiveNetworkQualityStatusGood;
    } else {
        liveStatus = LiveNetworkQualityStatusBad;
    }
    if (self.networkQualityBlock) {
        self.networkQualityBlock(liveStatus, [LocalUserComponent userModel].uid);
    }
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRemoteStreamStats:(ByteRTCRemoteStreamStats *)stats {
    LiveNetworkQualityStatus liveStatus = LiveNetworkQualityStatusNone;
    if (stats.txQuality == ByteRTCNetworkQualityExcellent ||
        stats.txQuality == ByteRTCNetworkQualityGood) {
        liveStatus = LiveNetworkQualityStatusGood;
    } else {
        liveStatus = LiveNetworkQualityStatusBad;
    }
    if (self.networkQualityBlock) {
        self.networkQualityBlock(liveStatus, stats.uid);
    }
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onForwardStreamStateChanged:(NSArray<ByteRTCForwardStreamStateInfo *> * _Nonnull)infos {
    VOLogI(VOInteractiveLive,@"Manager RTCSDK onForwardStreamStateChanged %@", infos);
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserLeave:(NSString *)uid reason:(ByteRTCUserOfflineReason)reason {
    if ([self.delegate respondsToSelector:@selector(liveRTCManager:onUserLeave:reason:)]) {
        [self.delegate liveRTCManager:self onUserLeave:uid reason:reason];
    }
}

#pragma mark - RTC Render View

- (nullable UIView *)getStreamViewWithUid:(NSString *)uid {
    if (IsEmptyStr(uid)) {
        return nil;
    }
    NSString *key = [self streamKeyWithUid:uid];
    return self.streamViewDic[key];
}

- (nullable UIView *)bindCanvasViewToUid:(NSString *)uid {
    if (IsEmptyStr(uid)) {
        return nil;
    }
    UIView *streamView = [self creatStreamViewIfNeedWithUid:uid];
    if ([uid isEqualToString:[LocalUserComponent userModel].uid]) {
        ByteRTCVideoCanvas *canvas = [[ByteRTCVideoCanvas alloc] init];
        canvas.renderMode = ByteRTCRenderModeHidden;
        canvas.view.backgroundColor = [UIColor clearColor];
        canvas.view = streamView;
        [self.rtcEngineKit setLocalVideoCanvas:ByteRTCStreamIndexMain
                                    withCanvas:canvas];
    } else {
        ByteRTCVideoCanvas *canvas = [[ByteRTCVideoCanvas alloc] init];
        canvas.renderMode = ByteRTCRenderModeHidden;
        canvas.view.backgroundColor = [UIColor clearColor];
        canvas.view = streamView;

        ByteRTCRemoteStreamKey *streamKey = [[ByteRTCRemoteStreamKey alloc] init];
        streamKey.userId = uid;
        streamKey.roomId = self.rtcRoom.getRoomId;
        streamKey.streamIndex = ByteRTCStreamIndexMain;

        [self.rtcEngineKit setRemoteVideoCanvas:streamKey withCanvas:canvas];
    }
    return streamView;
}

- (void)cleanAllStreamViews {
    [self.streamViewDic removeAllObjects];
}

- (UIView *)creatStreamViewIfNeedWithUid:(NSString *)uid {
    NSString *key = [self streamKeyWithUid:uid];
    UIView *view = self.streamViewDic[key];
    if (!view) {
        UIView *streamView = [[UIView alloc] init];
        streamView.hidden = YES;
        [self.streamViewDic setValue:streamView forKey:key];
        view = streamView;
    }
    return view;
}

- (NSString *)streamKeyWithUid:(NSString *)uid {
    NSString *typeStr = @"";
    if ([uid isEqualToString:[LocalUserComponent userModel].uid]) {
        typeStr = @"self";
    } else {
        typeStr = @"remote";
    }
    return [NSString stringWithFormat:@"%@_%@", typeStr, uid];
}

#pragma mark - ByteRTCVideoSinkDelegate

- (void)renderPixelBuffer:(CVPixelBufferRef _Nonnull)pixelBuffer
                 rotation:(ByteRTCVideoRotation)rotation
             extendedData:(NSData *_Nullable)extendedData {
    
}
#pragma mark - ByteRTCAudioProcessor
- (int)processAudioFrame:(ByteRTCAudioFrame *)audioFrame {
    
    return 0;
}

#pragma mark - Private Action
- (NSString *)getSEIJsonWithMixStatus:(RTCMixStatus)mixStatus {
    NSDictionary *dic = @{LiveSEIKEY: @(mixStatus)};
    NSString *json = [dic yy_modelToJSONString];
    return json;
}

- (CGSize)getOtherUserVideSize:(NSArray<LiveUserModel *> *)userList {
    CGSize otherVideoSize = [LiveSettingVideoConfig defaultVideoConfig].videoSize;
    if (userList.count < 2) {
        return otherVideoSize;
    }
    LiveUserModel *firstUserModel = userList.firstObject;
    LiveUserModel *lastUserModel = userList.lastObject;
    if (otherVideoSize.width == firstUserModel.videoSize.width &&
        otherVideoSize.height == firstUserModel.videoSize.height) {
        otherVideoSize = lastUserModel.videoSize;
    } else {
        otherVideoSize = firstUserModel.videoSize;
    }
    if (otherVideoSize.width == 0 || otherVideoSize.height == 0) {
        otherVideoSize = [LiveSettingVideoConfig defaultVideoConfig].videoSize;
    }
    CGSize newSize = CGSizeMake(otherVideoSize.width / 2,
                                otherVideoSize.height / 2);
    return newSize;
}

- (CGSize)getMaxUserVideSize:(NSArray<LiveUserModel *> *)userList {
    CGSize maxVideoSize = [LiveSettingVideoConfig defaultVideoConfig].videoSize;
    if (userList.count < 2) {
        return maxVideoSize;
    }
    LiveUserModel *firstUserModel = userList.firstObject;
    LiveUserModel *lastUserModel = userList.lastObject;
    if ((firstUserModel.videoSize.width * firstUserModel.videoSize.height) >
        (lastUserModel.videoSize.width * lastUserModel.videoSize.height)) {
        maxVideoSize = firstUserModel.videoSize;
    } else {
        maxVideoSize = lastUserModel.videoSize;
    }
    if (maxVideoSize.width == 0 || maxVideoSize.height == 0) {
        maxVideoSize = [LiveSettingVideoConfig defaultVideoConfig].videoSize;
    }
    CGSize newSize = CGSizeMake(maxVideoSize.width / 2,
                                maxVideoSize.height / 2);
    return newSize;
}

#pragma mark - Getter

- (ByteRTCVideoEncoderConfig *)pushRTCVideoConfig {
    if (!_pushRTCVideoConfig) {
        _pushRTCVideoConfig = [[ByteRTCVideoEncoderConfig alloc] init];
        CGSize videoSize = [LiveSettingVideoConfig defaultVideoConfig].videoSize;
        _pushRTCVideoConfig.width = videoSize.width;
        _pushRTCVideoConfig.height = videoSize.height;
        _pushRTCVideoConfig.frameRate = [LiveSettingVideoConfig defaultVideoConfig].fps;
        _pushRTCVideoConfig.maxBitrate = [LiveSettingVideoConfig defaultVideoConfig].bitrate;
    }
    return _pushRTCVideoConfig;
}

- (NSMutableDictionary<NSString *, UIView *> *)streamViewDic {
    if (!_streamViewDic) {
        _streamViewDic = [[NSMutableDictionary alloc] init];
    }
    return _streamViewDic;
}
@end
