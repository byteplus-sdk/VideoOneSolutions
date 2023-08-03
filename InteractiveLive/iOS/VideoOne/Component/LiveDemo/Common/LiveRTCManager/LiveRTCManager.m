// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRTCManager.h"
#import "LiveSettingVideoConfig.h"


@interface LiveRTCManager () <ByteRTCVideoDelegate, LiveTranscodingDelegate>

// Business RTS room. Audience users do not need to join the RTC room when they are not make guest, but they need to join the RTS room for business logic processing.
@property (nonatomic, strong) ByteRTCRoom *businessRoom;

// RTC room object
@property (nonatomic, strong, nullable) ByteRTCRoom *rtcRoom;


// Mix streaming status
@property (nonatomic, assign) RTCMixStatus mixStatus;



// Mix streaming settings
@property (nonatomic, strong) ByteRTCLiveTranscoding *transcodingSetting;

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
    [self.rtcEngineKit SetMaxVideoEncoderConfig:self.pushRTCVideoConfig];
    
    // Set up video mirroring
    [self.rtcEngineKit setLocalVideoMirrorType:ByteRTCMirrorTypeRenderAndEncoder];
    
    // Confluence retweet Setting
    _transcodingSetting = [ByteRTCLiveTranscoding defaultTranscoding];
        
    
    // Audio Capture
    ByteRTCAudioFormat *audioFormat = [[ByteRTCAudioFormat alloc] init];
    audioFormat.sampleRate = 44100;
    audioFormat.channel = 2;
    [self.rtcEngineKit enableAudioProcessor:ByteRTCAudioFrameProcessorRecord audioFormat:audioFormat];    
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
    [self.businessRoom joinRoomByToken:token
                              userInfo:userInfo
                            roomConfig:config];
}

- (void)leaveLiveRoom {
    // Leave the RTS business room.
    CGSize videoSize = [LiveSettingVideoConfig defultVideoConfig].videoSize;
    [self updateVideoEncoderResolution:videoSize];
    [self.rtcEngineKit stopLiveTranscoding:@""];
    [self leaveRTCRoom];
    
    [self switchAudioCapture:NO];
    [self switchVideoCapture:NO];
    
    [self.businessRoom leaveRoom];
    [self.businessRoom destroy];
    self.businessRoom = nil;
    
    [self.streamViewDic removeAllObjects];
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
    [self.rtcRoom joinRoomByToken:token userInfo:userInfo roomConfig:config];
    NSLog(@"aaa joinrtcroom %@ to:%@, uid:%@", rtcRoomID, [token substringToIndex:10], userID);
}

- (void)leaveRTCRoom {
    // Leaving the RTC room, you need to leave the room when the audio and video call ends.
    NSLog(@"aaa leaveRtcRoom");
    NSString *saveKey = @"";
    UIView *saveView = nil;
    for (NSString *key in self.streamViewDic.allKeys) {
        if ([key containsString:@"self_"]) {
            saveKey = key;
            saveView = self.streamViewDic[key];
            break;
        }
    }
    [self.streamViewDic removeAllObjects];
    if (saveView && NOEmptyStr(saveKey)) {
        [self.streamViewDic setValue:saveView forKey:saveKey];
    }
    
    [self.rtcRoom leaveRoom];
    [self.rtcRoom destroy];
    self.rtcRoom = nil;
}

#pragma mark - Mix Stream & Forward Stream

- (void)startMixStreamRetweetWithPushUrl:(NSString *)pushUrl
                                hostUser:(LiveUserModel *)hostUser
                               rtcRoomId:(NSString *)rtcRoomId {
    NSLog(@"aaa startMixStreamRetweetWithPushUrl");
    // Enable confluence
    if (NOEmptyStr(pushUrl)) {
//        [self switchVideoCapture:YES];
//        [self switchAudioCapture:YES];
        
        if (IsEmptyStr(rtcRoomId)) {
            NSLog(@"Manager RTCSDK startLiveTranscoding error : roomid nil");
        }
        // Set mix SEI
        NSString *json = [self getSEIJsonWithMixStatus:RTCMixStatusSingleLive];
        
        // Set mix Regions
        NSArray *regions = [self getRegionWithUserList:@[hostUser]
                                             mixStatus:RTCMixStatusSingleLive
                                             rtcRoomId:rtcRoomId];
        
        _transcodingSetting.layout.appData = json;
        _transcodingSetting.layout.backgroundColor = @"#0D0B53";
        _transcodingSetting.layout.regions = regions;
        _transcodingSetting.roomId = rtcRoomId;
        _transcodingSetting.userId = [LocalUserComponent userModel].uid;
        _transcodingSetting.url = pushUrl;
        _transcodingSetting.expectedMixingType = ByteRTCStreamMixingTypeByServer;
        _transcodingSetting.audio.sampleRate = 44100;
        _transcodingSetting.audio.channels = 2;
        _transcodingSetting.video.fps = [LiveSettingVideoConfig defultVideoConfig].fps;
        _transcodingSetting.video.kBitRate = [LiveSettingVideoConfig defultVideoConfig].bitrate;
        _transcodingSetting.video.width = [LiveSettingVideoConfig defultVideoConfig].videoSize.width;
        _transcodingSetting.video.height = [LiveSettingVideoConfig defultVideoConfig].videoSize.height;
        NSLog(@"aaa startlvietranscoding");
        [self.rtcEngineKit startLiveTranscoding:@""
                                    transcoding:_transcodingSetting
                                       observer:self];
    }
}

- (void)updateTranscodingLayout:(NSArray<LiveUserModel *> *)userList
                      mixStatus:(RTCMixStatus)mixStatus
                      rtcRoomId:(NSString *)rtcRoomId {
    // Update the merge layout
    // Set mix SEI
    NSString *json = [self getSEIJsonWithMixStatus:mixStatus];
    
    // Servers merge, take half of the maximum resolution
    CGSize pushRTCVideoSize = [LiveSettingVideoConfig defultVideoConfig].videoSize;
    if (mixStatus == RTCMixStatusPK) {
        pushRTCVideoSize = [self getMaxUserVideSize:userList];
    }
    self.pushRTCVideoConfig.width = pushRTCVideoSize.width;
    self.pushRTCVideoConfig.height = pushRTCVideoSize.height;
    [self.rtcEngineKit SetMaxVideoEncoderConfig:self.pushRTCVideoConfig];
    
    _transcodingSetting.layout.appData = json;
    _transcodingSetting.layout.regions = [self getRegionWithUserList:userList
                                                           mixStatus:mixStatus
                                                           rtcRoomId:rtcRoomId];
    [self.rtcEngineKit updateLiveTranscoding:@""
                                 transcoding:_transcodingSetting];
}

- (void)startForwardStreamToRooms:(NSString *)roomId token:(NSString *)token {
    NSLog(@"aaa startForwardStreamToRooms");
    // Enable forward stream
    ForwardStreamConfiguration *configuration = [[ForwardStreamConfiguration alloc] init];
    configuration.roomId = roomId;
    configuration.token = token;
    
    [self.rtcRoom startForwardStreamToRooms:@[configuration]];
}

- (void)stopForwardStreamToRooms {
    NSLog(@"aaa stopForwardStreamToRooms");
    // End forward stream
    CGSize videoSize = [LiveSettingVideoConfig defultVideoConfig].videoSize;
    self.pushRTCVideoConfig.width = videoSize.width;
    self.pushRTCVideoConfig.height = videoSize.height;
    
    [self.rtcEngineKit SetMaxVideoEncoderConfig:self.pushRTCVideoConfig];
    _mixStatus = RTCMixStatusSingleLive;
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
    [self.rtcEngineKit SetMaxVideoEncoderConfig:self.pushRTCVideoConfig];
}

- (void)updateLiveTranscodingResolution:(CGSize)size {
    // Update confluence encoding resolution
    _transcodingSetting.video.width = size.width;
    _transcodingSetting.video.height = size.height;
    [self.rtcEngineKit updateLiveTranscoding:@""
                                 transcoding:_transcodingSetting];
}

- (void)updateLiveTranscodingFrameRate:(CGFloat)fps {
    // Update confluence encoding frame rate
    _transcodingSetting.video.fps = fps;
    [self.rtcEngineKit updateLiveTranscoding:@""
                                 transcoding:_transcodingSetting];
}

- (void)updateLiveTranscodingBitRate:(NSInteger)bitRate {
    // Update confluence encoding bit rate
    _transcodingSetting.video.kBitRate = bitRate;
    [self.rtcEngineKit updateLiveTranscoding:@""
                                 transcoding:_transcodingSetting];
}

#pragma mark - NetworkQuality

- (void)didChangeNetworkQuality:(void (^)(LiveNetworkQualityStatus status, NSString *uid))block {
    self.networkQualityBlock = block;
}

#pragma mark - LiveTranscodingDelegate

- (void)onStreamMixingEvent:(ByteRTCStreamMixingEvent)event taskId:(NSString *)taskId error:(ByteRtcTranscoderErrorCode)Code mixType:(ByteRTCStreamMixingType)mixType {
    NSLog(@"Manager RTCSDK onStreamMixingEvent %lu %lu %lu", (unsigned long)Code, (unsigned long)mixType, (unsigned long)event);
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(liveRTCManager:onStreamMixingEvent:taskId:error:mixType:)]) {
            [self.delegate liveRTCManager:self onStreamMixingEvent:event taskId:taskId error:Code mixType:mixType];
        }
    });
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
    if ([rtcRoom.getRoomId isEqualToString:self.rtcRoom.getRoomId] ) {
        // Join the RTC room successfully
        [self bindCanvasViewToUid:uid];
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            RTCJoinModel *joinModel = [RTCJoinModel modelArrayWithClass:extraInfo state:state roomId:roomId];
            if ([self.delegate respondsToSelector:@selector(liveRTCManager:onRoomStateChanged:uid:)]) {
                [self.delegate liveRTCManager:self onRoomStateChanged:joinModel uid:uid];
            }
        });
    } else {
        RTCJoinModel *joinModel = [RTCJoinModel modelArrayWithClass:extraInfo state:state roomId:roomId];
        if(joinModel.joinType != 0) {
            if([self.businessDelegate respondsToSelector:@selector(LiveRTCManagerReconnectDelegate:onRoomStateChanged:uid:)]) {
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
    if (result && [rtcRoom.getRoomId isEqualToString:self.rtcRoom.getRoomId] ) {
        [self bindCanvasViewToUid:userInfo.userId];
    }
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserPublishStream:(NSString *)userId type:(ByteRTCMediaStreamType)type {
    if (type == ByteRTCMediaStreamTypeBoth ||
        type == ByteRTCMediaStreamTypeVideo) {
        dispatch_queue_async_safe(dispatch_get_main_queue(), (^{
            if (self.onUserPublishStreamBlock) {
                self.onUserPublishStreamBlock(userId);
            }
            if ([self.delegate respondsToSelector:@selector(liveRTCManager:onUserPublishStream:)]) {
                [self.delegate liveRTCManager:self onUserPublishStream:userId];
            }
        }));
        
    }
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onLocalStreamStats:(ByteRTCLocalStreamStats *)stats {

    LiveNetworkQualityStatus liveStatus = LiveNetworkQualityStatusNone;
    if (stats.tx_quality == ByteRTCNetworkQualityExcellent ||
        stats.tx_quality == ByteRTCNetworkQualityGood) {
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
    if (stats.tx_quality == ByteRTCNetworkQualityExcellent ||
        stats.tx_quality == ByteRTCNetworkQualityGood) {
        liveStatus = LiveNetworkQualityStatusGood;
    } else {
        liveStatus = LiveNetworkQualityStatusBad;
    }
    if (self.networkQualityBlock) {
        self.networkQualityBlock(liveStatus, stats.uid);
    }
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onForwardStreamStateChanged:(NSArray<ForwardStreamStateInfo *> *)infos {
    NSLog(@"Manager RTCSDK onForwardStreamStateChanged %@", infos);
}


- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserLeave:(NSString *)uid reason:(ByteRTCUserOfflineReason)reason {
    if ([self.delegate respondsToSelector:@selector(liveRTCManager:onUserLeave:reason:)]) {
        [self.delegate liveRTCManager:self onUserLeave:uid reason:reason];
    }
}

#pragma mark - RTC Render View

- (UIView *)getStreamViewWithUid:(NSString *)uid {
    if (IsEmptyStr(uid)) {
        return nil;
    }
    NSString *typeStr = @"";
    if ([uid isEqualToString:[LocalUserComponent userModel].uid]) {
        typeStr = @"self";
    } else {
        typeStr = @"remote";
    }
    NSString *key = [NSString stringWithFormat:@"%@_%@", typeStr, uid];
    UIView *view = self.streamViewDic[key];
    if (!view && [uid isEqualToString:[LocalUserComponent userModel].uid]) {
        UIView *streamView = [[UIView alloc] init];
        streamView.hidden = YES;
        ByteRTCVideoCanvas *canvas = [[ByteRTCVideoCanvas alloc] init];
        canvas.renderMode = ByteRTCRenderModeHidden;
        canvas.view.backgroundColor = [UIColor clearColor];
        canvas.view = streamView;
        
        [self.rtcEngineKit setLocalVideoCanvas:ByteRTCStreamIndexMain
                                    withCanvas:canvas];
        NSString *key = [NSString stringWithFormat:@"self_%@", uid];
        [self.streamViewDic setValue:streamView forKey:key];
        view = streamView;
    }
    return view;
}

- (void)bindCanvasViewToUid:(NSString *)uid {
    if (uid.length == 0) {
        return;
    }
    
    dispatch_queue_async_safe(dispatch_get_main_queue(), (^{
        if ([uid isEqualToString:[LocalUserComponent userModel].uid]) {
            UIView *view = [self getStreamViewWithUid:uid];
            if (!view) {
                UIView *streamView = [[UIView alloc] init];
                streamView.hidden = YES;
                ByteRTCVideoCanvas *canvas = [[ByteRTCVideoCanvas alloc] init];
                canvas.renderMode = ByteRTCRenderModeHidden;
                canvas.view.backgroundColor = [UIColor clearColor];
                canvas.view = streamView;
                [self.rtcEngineKit setLocalVideoCanvas:ByteRTCStreamIndexMain
                                            withCanvas:canvas];
                NSString *key = [NSString stringWithFormat:@"self_%@", uid];
                [self.streamViewDic setValue:streamView forKey:key];
            }
        } else {
            UIView *remoteRoomView = [self getStreamViewWithUid:uid];
            if (!remoteRoomView) {
                remoteRoomView = [[UIView alloc] init];
                remoteRoomView.hidden = YES;
                ByteRTCVideoCanvas *canvas = [[ByteRTCVideoCanvas alloc] init];
                canvas.renderMode = ByteRTCRenderModeHidden;
                canvas.view.backgroundColor = [UIColor clearColor];
                canvas.view = remoteRoomView;
                canvas.uid = uid;
                canvas.roomId = self.rtcRoom.getRoomId;

                [self.rtcEngineKit setRemoteVideoCanvas:uid
                                              withIndex:ByteRTCStreamIndexMain
                                             withCanvas:canvas];
                
                NSString *groupKey = [NSString stringWithFormat:@"remote_%@", uid];
                [self.streamViewDic setValue:remoteRoomView forKey:groupKey];
            }
        }
    }));
}

#pragma mark - ByteRTCVideoSinkDelegate

- (void)renderPixelBuffer:(CVPixelBufferRef _Nonnull)pixelBuffer
                 rotation:(ByteRTCVideoRotation)rotation
             extendedData:(NSData * _Nullable)extendedData {
    NSLog(@"video---");
}
#pragma mark - ByteRTCAudioProcessor
- (int)processAudioFrame:(ByteRTCAudioFrame *)audioFrame {
    NSLog(@"audio");
    return 0;
}

#pragma mark - Private Action
- (NSString *)getSEIJsonWithMixStatus:(RTCMixStatus)mixStatus {
    NSDictionary *dic = @{LiveSEIKEY : @(mixStatus)};
    NSString *json = [dic yy_modelToJSONString];
    return json;
}

- (NSArray *)getRegionWithUserList:(NSArray <LiveUserModel *> *)userList
                         mixStatus:(RTCMixStatus)mixStatus
                         rtcRoomId:(NSString *)rtcRoomId {
    NSInteger audienceIndex = 0;
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i = 0; i < userList.count; i++) {
        LiveUserModel *userModel = userList[i];
        ByteRTCVideoCompositingRegion *region = [[ByteRTCVideoCompositingRegion alloc] init];
        region.uid = userModel.uid;
        region.roomId = rtcRoomId;
        region.localUser = [userModel.uid isEqualToString:[LocalUserComponent userModel].uid] ? YES : NO;
        region.renderMode = ByteRTCRenderModeHidden;
        switch (mixStatus) {
            case RTCMixStatusSingleLive: {
                // Single anchor layout
                region.x = 0.0;
                region.y = 0.0;
                region.width = 1.0;
                region.height = 1.0;
                region.zOrder = 1;
                region.alpha = 1.0;
            } break;
                
            case RTCMixStatusPK: {
                // Make Co-host layout
                if (region.localUser) {
                    region.x = 0.0;
                    region.y = 0.25;
                    region.width = 0.5;
                    region.height = 0.5;
                    region.zOrder = 0;
                    region.alpha = 1.0;
                } else {
                    region.x = 0.5;
                    region.y = 0.25;
                    region.width = 0.5;
                    region.height = 0.5;
                    region.zOrder = 0;
                    region.alpha = 1.0;
                }
            } break;
                
            case RTCMixStatusAddGuestsTwo: {
                // Make Guests layout
                if (region.localUser) {
                    region.x = 0.0;
                    region.y = 0.0;
                    region.width = 1.0;
                    region.height = 1.0;
                    region.zOrder = 1;
                    region.alpha = 1.0;
                } else {
                    CGFloat screenW = 375.0;
                    CGFloat screenH = 667.0;
                    CGFloat itemHeight = 120.0;
                    CGFloat itemSpace = 6.0;
                    CGFloat itemRightSpace = 12;
                    CGFloat itemTopSpace = screenH - 23 - itemHeight;
                    NSInteger index = audienceIndex++;
                    CGFloat regionHeight = itemHeight / screenH;
                    CGFloat regionWidth = regionHeight * screenH / screenW;
                    CGFloat regionY = (itemTopSpace - (itemHeight + itemSpace) * index) / screenH;
                    CGFloat regionX = 1 - (regionHeight * screenH + itemRightSpace) / screenW;

                    region.x = regionX;
                    region.y = regionY;
                    region.width = regionWidth;
                    region.height = regionHeight;
                    region.zOrder = 2;
                    region.alpha = 1.0;
//                    region.cornerRadius = 4 / screenW;
                }
            } break;
                
            case RTCMixStatusAddGuestsMulti: {
                // Make Guests layout
                CGFloat screenW = 375.0;
                CGFloat screenH = 667.0;
                NSInteger maxItemNumber = 6;
                CGFloat itemSpace = 2.0;
                CGFloat itemHeight = (screenH - ((maxItemNumber - 1) * itemSpace)) / 6;
                CGFloat itemRightSpace = 0;
                if (region.localUser) {
                    region.x = 0.0;
                    region.y = 0.0;
                    region.width = 1.0 - ((itemSpace + itemHeight) / screenW);
                    region.height = 1.0;
                    region.zOrder = 1;
                    region.alpha = 1.0;
                } else {
                    NSInteger index = audienceIndex++;
                    CGFloat itemTopSpace = (itemHeight + itemSpace) * index;
                    CGFloat regionHeight = itemHeight / screenH;
                    CGFloat regionWidth = regionHeight * screenH / screenW;
                    CGFloat regionY = itemTopSpace / screenH;
                    CGFloat regionX = 1 - (regionHeight * screenH + itemRightSpace) / screenW;
                    
                    region.x = regionX;
                    region.y = regionY;
                    region.width = regionWidth;
                    region.height = regionHeight;
                    region.zOrder = 2;
                    region.alpha = 1.0;
                }
            } break;

            default:
                break;
        }
        [list addObject:region];
    }
    return [list copy];
}

- (CGSize)getOtherUserVideSize:(NSArray<LiveUserModel *> *)userList {
    CGSize otherVideoSize = [LiveSettingVideoConfig defultVideoConfig].videoSize;
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
        otherVideoSize = [LiveSettingVideoConfig defultVideoConfig].videoSize;
    }
    CGSize newSize = CGSizeMake(otherVideoSize.width / 2,
                                otherVideoSize.height / 2);
    return newSize;
}

- (CGSize)getMaxUserVideSize:(NSArray<LiveUserModel *> *)userList {
    CGSize maxVideoSize = [LiveSettingVideoConfig defultVideoConfig].videoSize;
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
        maxVideoSize = [LiveSettingVideoConfig defultVideoConfig].videoSize;
    }
    CGSize newSize = CGSizeMake(maxVideoSize.width / 2,
                                maxVideoSize.height / 2);
    return newSize;
}

#pragma mark - Getter

- (ByteRTCVideoEncoderConfig *)pushRTCVideoConfig {
    if (!_pushRTCVideoConfig) {
        _pushRTCVideoConfig = [[ByteRTCVideoEncoderConfig alloc] init];
        CGSize videoSize = [LiveSettingVideoConfig defultVideoConfig].videoSize;
        _pushRTCVideoConfig.width = videoSize.width;
        _pushRTCVideoConfig.height = videoSize.height;
        _pushRTCVideoConfig.frameRate = [LiveSettingVideoConfig defultVideoConfig].fps;
        _pushRTCVideoConfig.maxBitrate = [LiveSettingVideoConfig defultVideoConfig].bitrate;
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
