// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushInnerNewViewController.h"
#import "VELPushUIViewController+Private.h"
#import "VELPushImageUtils.h"
#import "VELPreviewSizeManager.h"
#import <objc/runtime.h>
#import <MediaLive/VELCommon.h>
#import <MediaLive/VELCore.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>

#define LOG_TAG @"NEW_PUSH_INNER"
#define kVeLiveCurrentCMTime CMTimeMakeWithSeconds(CACurrentMediaTime(), 1000000000)
#define LocalizedStringByAppendingString(key,sufix) [LocalizedStringFromBundle(key, @"MediaLive") stringByAppendingString:sufix]

static NSString *const kPushTaskId = @"vel_push_single_stream_task";
static NSString *const kPushRoomIdPrefix = @"vel_push_room";

@interface VELPushInnerNewViewController () <ByteRTCEngineDelegate, ByteRTCRoomDelegate, ByteRTCVideoSnapshotCallbackDelegate>
@property (nonatomic, strong, readwrite) ByteRTCEngine *rtcEngine;
@property (nonatomic, strong, readwrite) ByteRTCRoom *rtcRoom;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) ByteRTCLocalStreamStats *localStats;
@property (nonatomic, strong, readwrite) VELPushImageUtils *imageUtils;
@property (nonatomic, copy) void(^updateEncodeBitrateCallback)(int bitrate);
@property (atomic, assign) BOOL hasInitEffect;
@property (nonatomic, assign) BOOL needStartStreaming;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isMuted;
@end

@implementation VELPushInnerNewViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.lastCameraId = ByteRTCCameraIDFront;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self destoryEngine];
}

- (void)destoryAllAdditionMemoryObjects {
    [super destoryAllAdditionMemoryObjects];
    self.hasInitEffect = NO;
    self.needStartStreaming = NO;
}

- (void)applicationWillResignActive {
    self.needStartStreaming = [self isStreaming];
    [self stopVideoCapture];
    [self stopAudioCapture];
    [self stopStreaming];
    return;
}

- (void)applicationDidBecomeActive {
    [self startVideoCapture];
    [self startAudioCapture];
    if (self.needStartStreaming) {
        [self startStreaming];
    }
    self.micViewModel.isSelected = NO;
    [self.micViewModel updateUI];
    [self attemptToCurrentDeviceOrientation];
    return;
}

- (void)setupEngine {
    if (self.rtcEngine) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@2 forKey:@"rtc.env"];
    [params setObject:@"rtc-test.bytedance.com" forKey:@"config_hosts"];
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"rtc-pre-access.bytedance.com", @"rtc-pre-access-sg.bytevcloud.com", @"rtc-pre-access-va.bytevcloud.com",nil];
    [params setObject:array forKey:@"access_hosts"];
    
    ByteRTCEngineConfig *config = [[ByteRTCEngineConfig alloc] init];
    config.appID = [RTCTokenProtocol rtcAppId];
    config.parameters = @{};
    self.rtcEngine = [ByteRTCEngine createRTCEngine:config delegate:self];
    
    
    self.userId = [LocalUserComponent userModel].uid;
    self.roomId = [NSString stringWithFormat:@"%@_%@", kPushRoomIdPrefix, self.userId];
    if (!self.rtcRoom) {
        self.rtcRoom = [self.rtcEngine createRTCRoom:self.roomId];
        [self.rtcRoom setRTCRoomDelegate:self];
    }

    ByteRTCVideoCaptureConfig *videoCaptureConfig = [[ByteRTCVideoCaptureConfig alloc] init];
    videoCaptureConfig.videoSize = self.config.captureSize;
    videoCaptureConfig.frameRate = self.config.captureFPS;
    videoCaptureConfig.preference = ByteRTCVideoCapturePreferenceMannal;
    [self.rtcEngine setVideoCaptureConfig:videoCaptureConfig];
    
    ByteRTCVideoEncoderConfig *videoEncodeConfig = [[ByteRTCVideoEncoderConfig alloc] init];
    videoEncodeConfig.width = self.config.encodeSize.width;
    videoEncodeConfig.height = self.config.encodeSize.height;
    videoEncodeConfig.frameRate = self.config.encodeFPS;
    videoEncodeConfig.maxBitrate = self.config.bitrate;
    videoEncodeConfig.minBitrate = self.config.enableAutoBitrate ? -1 : self.config.bitrate;
    videoEncodeConfig.keyFrameIntervalMS = 2000;
    [self.rtcEngine setVideoEncoderConfig:videoEncodeConfig];
}

- (void)destoryEngine {
    [self stopStreaming];
    [self stopAudioCapture];
    [self stopVideoCapture];
    if (self.rtcRoom) {
        [self.rtcRoom destroy];
        self.rtcRoom = nil;
    }
    [ByteRTCEngine destroyRTCEngine];
    self.rtcEngine = nil;
    self.hasInitEffect = NO;
}

- (void)startVideoCapture {
    __weak __typeof__(self)weakSelf = self;
    [VELDeviceHelper requestCameraAuthorization:^(BOOL granted) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [self.rtcEngine startVideoCapture];
        [self.rtcEngine switchCamera:self.lastCameraId];
        if (self.lastCameraId == ByteRTCCameraIDFront) {
            [self.rtcEngine setLocalVideoMirrorType:ByteRTCMirrorTypeRenderAndEncoder];
        } else {
            [self.rtcEngine setLocalVideoMirrorType:ByteRTCMirrorTypeNone];
        }
        [self setupEffectManager];
    }];
}

- (void)stopVideoCapture {
    [self.rtcEngine stopVideoCapture];
}

- (void)startAudioCapture {
    __weak __typeof__(self)weakSelf = self;
    [VELDeviceHelper requestMicrophoneAuthorization:^(BOOL granted) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [self.rtcEngine startAudioCapture];
        if (self.config.enableHardwareEarback) {
            [self.rtcEngine setEarMonitorMode:ByteRTCEarMonitorModeOn];
        }
    }];
}

- (void)stopAudioCapture {
    [self.rtcEngine stopAudioCapture];
}

- (void)startPreivew {
    ByteRTCVideoCanvas *canvas = [[ByteRTCVideoCanvas alloc] init];
    canvas.view = self.previewContainer;
    canvas.backgroundColor = 0xFF00FFFF;
    canvas.renderMode = (ByteRTCRenderMode)self.config.renderMode;
    [self.rtcEngine setLocalVideoCanvas:canvas];
}

- (void)startStreaming {
    if ([self isStreaming]) {
        return;
    }

    if (![self checkConfigIsValid]) {
        return;
    }
    
    __weak __typeof__(self)weakSelf = self;
    [RTCTokenProtocol generateTokenWithRoomId:self.roomId
                                       userId:self.userId
                                   completion:^(NSString * _Nonnull token) {
        __strong __typeof__(weakSelf)self = weakSelf;

        ByteRTCUserInfo *userInfo = [[ByteRTCUserInfo alloc] init];
        userInfo.userId = self.userId;
        ByteRTCRoomConfig *roomConfig = [[ByteRTCRoomConfig alloc] init];
        roomConfig.isPublishAudio = YES;
        roomConfig.isPublishVideo = YES;
        roomConfig.profile = ByteRTCRoomProfileLivePush;
//        [self.rtcRoom joinRoom:@"" userInfo:userInfo userVisibility:YES roomConfig:roomConfig];
        [self.rtcRoom joinRoom:token userInfo:userInfo userVisibility:YES roomConfig:roomConfig];

        [self.config.urls enumerateObjectsUsingBlock:^(NSString * _Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
            if (url.length > 0) {
                NSString *taskId = [NSString stringWithFormat:@"%@_%ld", kPushTaskId, (unsigned long)idx];
                ByteRTCPushSingleStreamParam *param = [[ByteRTCPushSingleStreamParam alloc] init];
                param.url = url;
                param.roomId = self.roomId;
                param.userId = self.userId;
                param.pushType = ByteRTCSingleStreamPushToCDN;
                int errCode = [self.rtcEngine startPushSingleStream:taskId singleStream:param];
                if (errCode != 0) {
                    VELLogInfo(LOG_TAG, @"Failed to push stream with errorCode:%d", errCode);
                    return;
                }
            }
        }];

        [self setStreamStatus:VELStreamStatusConnecting msg:LocalizedStringFromBundle(@"medialive_connecting", @"MediaLive")];
        VELLogInfo(LOG_TAG, @"PushConfig:%@", [self.config yy_modelToJSONString]);
    }];
}


- (BOOL)isStreaming {
    return self.streamStatus == VELStreamStatusConnecting || self.streamStatus == VELStreamStatusReconnecting || self.streamStatus == VELStreamStatusConnected;
}

- (void)stopStreaming {
    [VELUIToast hideAllLoadingView];
    [self.config.urls enumerateObjectsUsingBlock:^(NSString * _Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
        if (url.length > 0) {
            NSString *taskId = [NSString stringWithFormat:@"%@_%ld", kPushTaskId, (unsigned long)idx];
            [self.rtcEngine stopPushSingleStream:taskId];
        }
    }];
    if (self.rtcRoom) {
        [self.rtcRoom leaveRoom];
        [self.rtcRoom destroy];
        self.rtcRoom = nil;
    }
    [self setStreamStatus:(VELStreamStatusNone) msg:nil];
    [self setupUIForNotStreaming];
}

- (void)switchCamera {
    if (self.lastCameraId == ByteRTCCameraIDFront) {
        self.lastCameraId = ByteRTCCameraIDBack;
    } else {
        self.lastCameraId = ByteRTCCameraIDFront;
    }
    [self.rtcEngine switchCamera:self.lastCameraId];
    if (self.lastCameraId == ByteRTCCameraIDFront) {
        [self.rtcEngine setLocalVideoMirrorType:ByteRTCMirrorTypeRenderAndEncoder];
    } else {
        [self.rtcEngine setLocalVideoMirrorType:ByteRTCMirrorTypeNone];
    }
}

- (void)muteAudio {
    self.isMuted = YES;
    [self.rtcEngine muteAudioCapture:YES];
}
- (void)unMuteAudio {
    self.isMuted = NO;
    [self.rtcEngine muteAudioCapture:NO];
}
- (void)setMirrorType:(VELSettingsMirrorType)mirrorType isOn:(BOOL)enable {
    if (enable) {
        if (mirrorType == VELSettingsMirrorTypeCapture) {
            [self.rtcEngine setLocalVideoMirrorType:ByteRTCMirrorTypeRenderAndEncoder];
        } else if (mirrorType == VELSettingsMirrorTypePreview) {
            [self.rtcEngine setLocalVideoMirrorType:ByteRTCMirrorTypeRender];
        } else if (mirrorType == VELSettingsMirrorTypeStream) {
            [self.rtcEngine setLocalVideoMirrorType:ByteRTCMirrorTypeEncoder];
        }
    } else {
        [self.rtcEngine setLocalVideoMirrorType:ByteRTCMirrorTypeNone];
    }
}

- (void)setEnableAudioHardwareEcho:(BOOL)enable {
    if (enable) {
        [self.rtcEngine setEarMonitorMode:ByteRTCEarMonitorModeOn];
    } else {
        [self.rtcEngine setEarMonitorMode:ByteRTCEarMonitorModeOff];
    }
}

- (BOOL)isHardwareEchoEnable {
    return self.config.enableHardwareEarback;
}

- (BOOL)isSupportAudioHardwareEcho {
    return YES;
}

- (void)setAudioLoudness:(float)loudness {
    [self.rtcEngine setCaptureVolume:(int)(loudness * 100)];
}

- (void)setPreviewRenderMode:(VELSettingPreviewRenderMode)renderMode {
    ByteRTCVideoCanvas *canvas = [[ByteRTCVideoCanvas alloc] init];
    canvas.view = self.previewContainer;
    canvas.renderMode = (ByteRTCRenderMode)renderMode;
    [self.rtcEngine setLocalVideoCanvas:canvas];
}

- (float)getCurrentAudioLoudness {
    return self.config.audioVoiceLoudness;
}

- (void)updateVideoEncodeResolution:(VELSettingResolutionType)resolution {
    self.config.encodeResolutionType = resolution;
    [self updateRTCVideoEncoderConfig];
}

- (void)updateVideoEncodeFps:(int)fps {
    if (fps < 15 || fps > 30) {
        return;
    }
    self.config.encodeFPS = fps;
    [self updateRTCVideoEncoderConfig];
}

- (void)updateRTCVideoEncoderConfig {
    ByteRTCVideoEncoderConfig *videoEncodeCfg = [[ByteRTCVideoEncoderConfig alloc] init];
    videoEncodeCfg.width = self.config.encodeSize.width;
    videoEncodeCfg.height = self.config.encodeSize.height;
    videoEncodeCfg.frameRate = self.config.encodeFPS;
    videoEncodeCfg.maxBitrate = self.config.bitrate;
    [self.rtcEngine setVideoEncoderConfig:videoEncodeCfg];
}

- (BOOL)isSupportTorch {
    return [self.rtcEngine isCameraTorchSupported];
}
- (void)torch:(BOOL)isOn {
    [self.rtcEngine setCameraTorch:isOn ? ByteRTCTorchStateOn : ByteRTCTorchStateOff];
}
- (void)rotatedTo:(UIInterfaceOrientation)orientation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ByteRTCVideoOrientation rtcOrientation = ByteRTCVideoOrientationPortrait;
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            rtcOrientation = ByteRTCVideoOrientationLandscape;
        }
        [self.rtcEngine setVideoOrientation:rtcOrientation];
    });
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (BOOL)showLogInfo {
    return YES;
}
- (BOOL)hideLogInfo {
    return YES;
}
#pragma clang diagnostic pop
- (NSAttributedString *)getPushInfoString {
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    static NSDictionary *titleStyle = nil;
    static NSDictionary *contentStyle = nil;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    [paraStyle setParagraphStyle:NSParagraphStyle.defaultParagraphStyle];
    paraStyle.lineHeightMultiple = 1.2;
    if (!titleStyle) {
        titleStyle = @{
            NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
            NSForegroundColorAttributeName : UIColor.whiteColor,
            NSParagraphStyleAttributeName : paraStyle,
        };
    }
    if (!contentStyle) {
        contentStyle = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.whiteColor,
            NSParagraphStyleAttributeName : paraStyle,
        };
    }
#define VEL_PUSH_TITLE(fmt, ...) [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:fmt, ##__VA_ARGS__] attributes:titleStyle]
#define VEL_PUSH_CONTENT(fmt, ...) [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:fmt, ##__VA_ARGS__] attributes:contentStyle]

    ByteRTCLocalVideoStats *videoStats = self.localStats.videoStats;
    ByteRTCLocalAudioStats *audioStats = self.localStats.audioStats;

    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_push_adress", @":%@\n"), self.config.urls.firstObject ?: @"")];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_max_bitrate", @":%d kbps"), (int)self.config.bitrate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_initial_bitrate", @":%d kbps\n"), (int)self.config.bitrate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_capture_resolution", @":%d, %d \n"), (int)self.config.captureSize.width, (int)self.config.captureSize.height)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_push_resolution", @":%d, %d "), (int)self.config.encodeSize.width, (int)self.config.encodeSize.height)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_capture_fps", @":%d \n"), (int)self.config.captureFPS)];
    
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_capture_io_fps", @":%d/%d"), (int)videoStats.inputFrameRate, (int)videoStats.sentFrameRate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_encode_format", @":%@ \n"), @"H264")];
    
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_real_time_transport_fps", @":%d \n"), (int)videoStats.sentFrameRate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_real_time_encode_bitrate", @":%d kbps"), (int)videoStats.sentKBitrate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_real_time_transport_bitrate", @":%d kbps\n"), (int)(videoStats.sentKBitrate + audioStats.sentKBitrate))];
    return attributedString;
}

- (NSString *)jsonStringWithKey:(NSString *)key value:(NSString *)value {
    if (!key || !value) {
        return nil;
    }
    
    NSDictionary *dict = @{
        key : value
    };
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    if (error || !jsonData) {
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)sendSEIWithKey:(NSString *)key value:(NSString *)value {
    // SEI not directly supported in single stream push mode
    [self.rtcEngine enableSendLivePushSEI:YES];
    NSString* json = [self jsonStringWithKey:key value:value];
    [self.rtcEngine sendLivePushSEIMessage:json count:100 isKeyFrameOnly:YES allowOverwrite:YES];
}

- (void)stopSendSEIForKey:(NSString *)key {
    // SEI not directly supported in single stream push mode
}

- (void)setupEffectManager {
    if (!self.hasInitEffect) {
        self.hasInitEffect = YES;
        _beautyComponent = [[BytedEffectProtocol alloc] initWithEngine:self.rtcEngine withType:EffectTypeRTC useCache:YES];
        if (_beautyComponent == nil) {
            self.hasInitEffect = NO;
        }
    }
}

- (void)startRecord:(int)width height:(int)height {
    ByteRTCRecordingConfig *config = [[ByteRTCRecordingConfig alloc] init];
    config.dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    // Width and height not directly configurable in ByteRTCRecordingConfig
    // It captures what the encoder produces.
    
    [self.rtcEngine startFileRecording:config type:ByteRTCRecordingTypeVideoAndAudio];
    self.isRecording = YES;
}

- (void)stopRecord {
    if (self.isRecording) {
        [self.rtcEngine stopFileRecording];
    }
    self.isRecording = NO;
}

- (void)snapShot {
    [self.rtcEngine takeLocalSnapshot:self];
}


-(AudioStreamBasicDescription)getASBD:(int)sampleRate channels:(int)channels {
    AudioStreamBasicDescription format = {0};
    format.mSampleRate = sampleRate;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags =  kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    format.mChannelsPerFrame = channels;
    format.mBitsPerChannel = channels * 8;
    format.mFramesPerPacket = 1;
    format.mBytesPerFrame = format.mBitsPerChannel / 8 * format.mChannelsPerFrame;
    format.mBytesPerPacket = format.mBytesPerFrame * format.mFramesPerPacket;
    format.mReserved = 0;
    return format;
}

- (CMSampleBufferRef)convertAudioSampleWithData:(NSData *)audioData channels:(int)channels sampleRate:(int)sampleRate {
    AudioBufferList audioBufferList;
    audioBufferList.mNumberBuffers = 1;
    audioBufferList.mBuffers[0].mNumberChannels = channels;
    audioBufferList.mBuffers[0].mDataByteSize = (UInt32)audioData.length;
    audioBufferList.mBuffers[0].mData = (void *)audioData.bytes;

    AudioStreamBasicDescription asbd = [self getASBD:sampleRate channels:channels];
    CMSampleBufferRef buff = NULL;
    static CMFormatDescriptionRef format = NULL;
    CMSampleTimingInfo timing = {CMTimeMake(1,sampleRate), kCMTimeZero, kCMTimeInvalid };
    OSStatus error = 0;
    if(format == NULL){
        error = CMAudioFormatDescriptionCreate(kCFAllocatorDefault, &asbd, 0, NULL, 0, NULL, NULL, &format);
    }

    error = CMSampleBufferCreate(kCFAllocatorDefault, NULL, false, NULL, NULL, format, audioData.length / (2*channels), 1, &timing, 0, NULL, &buff);

    if (error) {
        VOLogI(VOMediaLive,@"CMSampleBufferCreate returned error: %ld", (long)error);
        return NULL;
    }

    error = CMSampleBufferSetDataBufferFromAudioBufferList(buff, kCFAllocatorDefault, kCFAllocatorDefault, 0, &audioBufferList);

    if(error){
        VOLogI(VOMediaLive,@"CMSampleBufferSetDataBufferFromAudioBufferList returned error: %ld", (long)error);
        return NULL;
    }
    return buff;
}
- (CGFloat)getCurrentCameraZoomRatio {
    // Current zoom ratio is not directly queryable in ByteRTCEngine API, return 1.0 as a safe default
    return 1.0;
}
- (CGFloat)getCameraZoomMaxRatio {
    return [self.rtcEngine getCameraZoomMaxRatio];
}
- (CGFloat)getCameraZoomMinRatio {
    return 1.0;
}
- (void)setCameraZoomRatio:(CGFloat)ratio {
    [self.rtcEngine setCameraZoomRatio:ratio];
}

- (BOOL)isSupportCameraZoomRatio {
    return [self.rtcEngine isCameraZoomSupported];
}

- (BOOL)isAutoFocusSupported {
    return [self.rtcEngine isCameraFocusPositionSupported];
}

- (void)enableCameraAutoFocus:(BOOL)enable {
    // Built-in auto focus handled by SDK automatically
}

- (void)setCameraFocusPosition:(CGPoint)position {
    [self.rtcEngine setCameraFocusPosition:position];
}

#pragma mark - ByteRTCVideoSnapshotCallbackDelegate

- (void)onTakeLocalSnapshotResult:(NSInteger)taskId videoSource:(ByteRTCVideoSource *)videoSource image:(ByteRTCImage *)image errorCode:(NSInteger)errorCode {
    vel_sync_main_queue(^{
        UIImage *uiImage = nil;
        if ([image isKindOfClass:[UIImage class]]) {
            uiImage = (UIImage *)image;
        }
        [self setSnapShotResult:uiImage error:nil];
    });
}

#pragma mark - ByteRTCEngineDelegate

- (void)rtcEngine:(ByteRTCEngine *)engine onConnectionStateChanged:(ByteRTCConnectionState)state {
    VELLogDebug(LOG_TAG, @"Connection state changed: %ld", (long)state);
}

- (void)rtcEngine:(ByteRTCEngine *)engine onError:(ByteRTCErrorCode)errorCode {
    NSString *info = [NSString stringWithFormat:@"RTC Error: %ld", (long)errorCode];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
}

- (void)rtcEngine:(ByteRTCEngine *)engine onWarning:(ByteRTCWarningCode)warningCode {
    NSString *info = [NSString stringWithFormat:@"RTC Warning: %ld", (long)warningCode];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
}

- (void)rtcEngine:(ByteRTCEngine *)engine onSingleStreamEvent:(ByteRTCSingleStreamTaskEvent)event
       withTaskId:(NSString *)taskId withErrorCode:(ByteRTCSingleStreamTaskErrorCode)errorCode {
    vel_sync_main_queue(^{
        NSString *msg = nil;
        switch (event) {
            case ByteRTCSingleStreamTaskEventBase:
                msg = LocalizedStringFromBundle(@"medialive_push_status_connecting", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusConnecting) msg:msg];
                break;
            case ByteRTCSingleStreamTaskEventStartSuccess:
                msg = LocalizedStringFromBundle(@"medialive_push_status_connected", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusConnected) msg:msg];
                break;
            case ByteRTCSingleStreamTaskEventStartFailed:
                msg = LocalizedStringFromBundle(@"medialive_push_status_error", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusError) msg:msg];
                [self stopStreaming];
                break;
            case ByteRTCSingleStreamTaskEventStopSuccess:
                msg = LocalizedStringFromBundle(@"medialive_push_status_stop", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusStop) msg:msg];
                break;
            case ByteRTCSingleStreamTaskEventStopFailed:
                msg = LocalizedStringFromBundle(@"medialive_push_status_error", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusError) msg:msg];
                break;
            default:
                break;
        }
        if (msg) {
            NSString *info = [NSString stringWithFormat:LocalizedStringByAppendingString(@"medialive_push_status", @":%@"), msg];
            [self updateCallBackInfo:info append:YES];
        }
    });
}

- (void)rtcEngine:(ByteRTCEngine *)engine onSysStats:(const ByteRTCSysStats *)stats {
    // Optional sys stats display
}

- (void)rtcEngine:(ByteRTCEngine *)engine onRecordingStateUpdate:(ByteRTCVideoSource *)videoSource state:(ByteRTCRecordingState)state error_code:(ByteRTCRecordingErrorCode)errorCode recording_info:(ByteRTCRecordingInfo *)recordingInfo {
    vel_sync_main_queue(^{
        if (state == ByteRTCRecordingStateSuccess) {
            [VELUIToast showText:LocalizedStringFromBundle(@"medialive_record_success", @"MediaLive")];
        } else if (state == ByteRTCRecordingStateError) {
            [VELUIToast showText:LocalizedStringFromBundle(@"medialive_record_failed", @"MediaLive")];
        }
    });
}

#pragma mark - ByteRTCRoomDelegate

- (void)rtcRoom:(ByteRTCRoom *_Nonnull)rtcRoom onNetworkQuality:(ByteRTCNetworkQualityStats *_Nonnull)localQuality remoteQualities:(NSArray<ByteRTCNetworkQualityStats*> *_Nonnull)remoteQualities {
    NSString *info = [NSString stringWithFormat:LocalizedStringByAppendingString(@"medialive_network_quality", @": %ld"), (long)localQuality.txQuality];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    vel_sync_main_queue(^{
        switch (localQuality.txQuality) {
            case ByteRTCNetworkQualityUnknown:
                [self setNetworkQuality:(VELNetworkQualityUnKnown)];
                break;
            case ByteRTCNetworkQualityBad:
            case ByteRTCNetworkQualityVeryBad:
            case ByteRTCNetworkQualityDown:
                [self setNetworkQuality:(VELNetworkQualityBad)];
                break;
            case ByteRTCNetworkQualityPoor:
                [self setNetworkQuality:(VELNetworkQualityPoor)];
                break;
            case ByteRTCNetworkQualityGood:
            case ByteRTCNetworkQualityExcellent:
                [self setNetworkQuality:(VELNetworkQualityGood)];
                break;
        }
    });
}

- (void)rtcRoom:(ByteRTCRoom *_Nonnull)rtcRoom onLocalStreamStats:(NSString *_Nonnull)streamId info:(ByteRTCStreamInfo* _Nonnull)info stats:(ByteRTCLocalStreamStats *_Nonnull)stats {
    self.localStats = stats;
    NSString *statsInfo = [self getPushInfoString].string;
    [self updateCycleInfo:statsInfo append:NO];
}

/// MARK: - Lazy
- (NSString *)getRecordPath:(BOOL)shouldDelete {
    NSString *videoPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    videoPath = [videoPath stringByAppendingPathComponent:@"record_video.mp4"];
    if (shouldDelete && [NSFileManager.defaultManager fileExistsAtPath:videoPath]) {
        [NSFileManager.defaultManager removeItemAtPath:videoPath error:nil];
    }
    return videoPath;
}

- (VELPushImageUtils *)imageUtils {
    if (!_imageUtils) {
        _imageUtils = [[VELPushImageUtils alloc] init];
    }
    return _imageUtils;
}

- (CGRect)getMixRect:(CGPoint)position width:(CGFloat)width height:(CGFloat)height {
    CGFloat w = 0.5;
    CGFloat h = -1;
    CGFloat preViewWidth = self.previewContainer.vel_width;
    CGFloat preViewHeight = self.previewContainer.vel_height;
    if (preViewWidth > preViewHeight) {
        w = -1;
        h = 0.5;
    }
    if (h < 0) {
        h = (height * preViewWidth) / (preViewHeight * width) * w;
    } else{
        w = (preViewHeight * width) / (height * preViewWidth) * h;
    }
    return CGRectMake(position.x, position.y, w, h);
}

@end
