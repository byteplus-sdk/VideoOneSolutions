// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushInnerNewViewController.h"
#import "VELPushUIViewController+Private.h"
#import "VELPushImageUtils.h"
#import "VELPreviewSizeManager.h"
#import "VELPushUIViewController+Private.h"
#import <objc/runtime.h>
#import <MediaLive/VELCommon.h>
#import <MediaLive/VELCore.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>

#define LOG_TAG @"NEW_PUSH_INNER"
#define kVeLiveCurrentCMTime CMTimeMakeWithSeconds(CACurrentMediaTime(), 1000000000)
#define LocalizedStringByAppendingString(key,sufix) [LocalizedStringFromBundle(key, @"MediaLive") stringByAppendingString:sufix]
@interface VeLiveMediaPlayer (VELPush)
@property (nonatomic, copy) NSString *playIdentifier;
@end
@implementation VeLiveMediaPlayer (VELPush)
static char kAssociatedObjectKey_playIdentifier;
- (void)setPlayIdentifier:(NSString *)playIdentifier {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_playIdentifier, playIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)playIdentifier {
    return (NSString *)objc_getAssociatedObject(self, &kAssociatedObjectKey_playIdentifier);
}


@end
@interface VELPushInnerNewViewController () <
VeLivePusherObserver,
VeLivePusherStatisticsObserver,
VeLiveFileRecordingListener,
VeLiveSnapshotListener
>
@property (nonatomic, strong, readwrite) VeLivePusher *pusher;
@property (atomic, strong) VeLivePusherStatistics *staticts;
@property (atomic, strong) NSDictionary *log;
@property (nonatomic, strong, readwrite) VELPushImageUtils *imageUtils;
@property (nonatomic, copy) void(^updateEncodeBitrateCallback)(int bitrate);
@property (nonatomic, copy) NSDictionary *(^excuteWithCommandAndUserInfo)(NSString *command, NSDictionary *userinfo); //for dns
@property (atomic, assign) BOOL hasInitEffect;
@property (atomic, assign) BOOL isSetMusicLoop;
@property (nonatomic, assign) BOOL needStartStreaming;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong) NSMutableDictionary *extraParams;
@end

@implementation VELPushInnerNewViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.lastAudioCaptureType = VeLiveAudioCaptureMicrophone;
    self.lastVideoCaptureType = VeLiveVideoCaptureFrontCamera;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self destoryEngine];
}

- (void)destoryAllAdditionMemoryObjects {
    [super destoryAllAdditionMemoryObjects];
    self.staticts = nil;
    self.log  = nil;
    self.hasInitEffect = NO;
    self.isSetMusicLoop = NO;
    self.needStartStreaming = NO;
}

- (void)applicationWillResignActive {
    self.needStartStreaming = [self isStreaming];
    self.lastVideoCaptureType = [self.pusher getCurrentVideoCaptureType];
    [self stopVideoCapture];
    
    self.lastAudioCaptureType = [self.pusher getCurrentAudioCaptureType];
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
    if (self.pusher) {
        return;
    }
    
    VeLivePusherConfiguration *cfg = [[VeLivePusherConfiguration alloc] init];
    
    VeLiveVideoCaptureConfiguration *videoCaptureConfig = [[VeLiveVideoCaptureConfiguration alloc] init];
    videoCaptureConfig.width = self.config.captureSize.width;
    videoCaptureConfig.height = self.config.captureSize.height;
    videoCaptureConfig.fps = (int)self.config.captureFPS;
    cfg.videoCaptureConfig = videoCaptureConfig;
    
    VeLiveAudioCaptureConfiguration *audioCaptureConfig = [[VeLiveAudioCaptureConfiguration alloc] init];
    cfg.audioCaptureConfig = audioCaptureConfig;
    
    
    self.pusher = [[VeLivePusher alloc] initWithConfig:cfg];

    [self.pusher setObserver:self];
    [self.pusher setStatisticsObserver:self interval:1];
    [self.pusher setEGLVersion:(int)self.config.glVersion];
    [self setPreviewRenderMode:(VELSettingPreviewRenderMode)self.config.renderMode];
}

- (void)destoryEngine {
    [self stopStreaming];
    [self stopRecord];
    [self stopAudioCapture];
    [self stopVideoCapture];
    [self.pusher destroy];
    self.pusher = nil;
    self.hasInitEffect = NO;
}

- (void)startVideoCapture {
    __weak __typeof__(self)weakSelf = self;
    [VELDeviceHelper requestCameraAuthorization:^(BOOL granted) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [self.pusher startVideoCapture:self.lastVideoCaptureType];
        [self setupEffectManager];
    }];
}

- (void)stopVideoCapture {
    [self.pusher stopVideoCapture];
}

- (void)startAudioCapture {
    __weak __typeof__(self)weakSelf = self;
    [VELDeviceHelper requestMicrophoneAuthorization:^(BOOL granted) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [self.pusher startAudioCapture:(self.lastAudioCaptureType)];
        [self.pusher.getAudioDevice enableEcho:self.config.enableHardwareEarback];
    }];
}

- (void)stopAudioCapture {
    [self.pusher stopAudioCapture];
}

- (void)startPreivew {
    [self.pusher setRenderView:self.previewContainer];
}

- (void)startStreaming {
    if ([self isStreaming]) {
        return;
    }
    
    if (![self checkConfigIsValid]) {
        return;
    }
    
    VeLiveVideoEncoderConfiguration *videoEncodeConfig = [[VeLiveVideoEncoderConfiguration alloc] initWithResolution:(VeLiveVideoResolution)self.config.encodeResolutionType];
    videoEncodeConfig.bitrate = (int)self.config.bitrate;
    videoEncodeConfig.maxBitrate = (int)self.config.bitrate;
    videoEncodeConfig.minBitrate = (int)self.config.bitrate;
    videoEncodeConfig.fps = (int)self.config.encodeFPS;
    if (self.config.enableAutoBitrate) {
        
    }
    [self.pusher setVideoEncoderConfiguration:videoEncodeConfig];
    
    VeLiveAudioEncoderConfiguration *audioEncodeConfig = [[VeLiveAudioEncoderConfiguration alloc] init];
    [self.pusher setAudioEncoderConfiguration:audioEncodeConfig];
    [self.pusher startPushWithUrls:self.config.urls];
    [self setStreamStatus:VELStreamStatusConnecting msg:LocalizedStringFromBundle(@"medialive_connecting", @"MediaLive")];
    VELLogInfo(LOG_TAG, @"PushConfig:%@", [self.config yy_modelToJSONString]);
}


- (BOOL)isStreaming {
    return [self.pusher isPushing] || self.streamStatus == VELStreamStatusConnecting || self.streamStatus == VELStreamStatusReconnecting || self.streamStatus == VELStreamStatusConnected;
}

- (void)stopStreaming {
    [VELUIToast hideAllLoadingView];
    [self.pusher stopPush];
    [self setStreamStatus:(VELStreamStatusNone) msg:nil];
    [self setupUIForNotStreaming];
}

- (void)switchCamera {
    if (self.pusher.getCurrentVideoCaptureType == VeLiveVideoCaptureBackCamera) {
        self.lastVideoCaptureType = VeLiveVideoCaptureFrontCamera;
        [self.pusher switchVideoCapture:(VeLiveVideoCaptureFrontCamera)];
    } else {
        self.lastVideoCaptureType = VeLiveVideoCaptureBackCamera;
        [self.pusher switchVideoCapture:(VeLiveVideoCaptureBackCamera)];
    }
}
- (void)muteAudio {
    [self.pusher setMute:YES];
}
- (void)unMuteAudio {
    [self.pusher setMute:NO];
}
- (void)setCaptureMirror:(BOOL)mirror {
    [self.pusher setVideoMirror:(VeLiveVideoMirrorCapture) enable:mirror];
}
- (void)setStreamMirror:(BOOL)mirror {
    [self.pusher setVideoMirror:(VeLiveVideoMirrorPushStream) enable:mirror];
}
- (void)setPreviewMirror:(BOOL)mirror {
    [self.pusher setVideoMirror:(VeLiveVideoMirrorPreview) enable:mirror];
}

- (void)setEnableAudioHardwareEcho:(BOOL)enable {
    if (self.pusher.getAudioDevice.isSupportHardwareEcho) {
        [self.pusher.getAudioDevice enableEcho:enable];
    }
}

- (BOOL)isHardwareEchoEnable {
    return [self.pusher.getAudioDevice isEnableEcho];
}

- (void)setAudioLoudness:(float)loudness {
    [self.pusher.getAudioDevice setVoiceLoudness:loudness];
}

- (void)setPreviewRenderMode:(VELSettingPreviewRenderMode)renderMode {
    [self.pusher setRenderFillMode:(VeLivePusherRenderMode)renderMode];
}

- (float)getCurrentAudioLoudness {
    return [self.pusher.getAudioDevice getVoiceLoudness];
}

- (void)updateVideoEncodeResolution:(VELSettingResolutionType)resolution {
    self.config.encodeResolutionType = resolution;
    [self updateLivePusherEncodeConfig];
}

- (void)updateVideoEncodeFps:(int)fps {
    if (fps < 15 || fps > 30) {
        return;
    }
    self.config.encodeFPS = fps;
    [self updateLivePusherEncodeConfig];
}

- (void)updateLivePusherEncodeConfig {
    VeLiveVideoEncoderConfiguration *videoEncodeCfg = [[VeLiveVideoEncoderConfiguration alloc] initWithResolution:(VeLiveVideoResolution)self.config.encodeResolutionType];
    videoEncodeCfg.fps = (int)self.config.encodeFPS;
    [self.pusher setVideoEncoderConfiguration:videoEncodeCfg];
}
- (BOOL)isSupportTorch {
    return [self.pusher.getCameraDevice isTorchSupported];
}
- (void)torch:(BOOL)isOn {
    [self.pusher.getCameraDevice enableTorch:isOn];
}
- (void)rotatedTo:(UIInterfaceOrientation)orientation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.pusher setOrientation:orientation];
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
    
    VeLivePusherStatistics * statistics = self.staticts;
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_push_adress", @":%@\n"), self.staticts.url)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_max_bitrate", @":%d kbps"), (int)statistics.maxVideoBitrate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_initial_bitrate", @":%d kbps\n"), (int)statistics.videoBitrate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_min_bitrate", @":%d kbps"), (int)statistics.minVideoBitrate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_capture_resolution", @":%d, %d \n"), (int)statistics.captureWidth, (int)statistics.captureHeight)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_push_resolution", @":%d, %d "), (int)statistics.encodeWidth, (int)statistics.encodeHeight)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_capture_fps", @":%d \n"), (int)statistics.captureFps)];
    
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_capture_io_fps", @":%d/%d"), (int)statistics.captureFps, (int)statistics.encodeFps)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_video_encode_format", @":%@ \n"), statistics.codec)];
    
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_real_time_transport_fps", @":%d \n"), (int)statistics.transportFps)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_real_time_encode_bitrate", @":%d kbps"), (int)statistics.encodeVideoBitrate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(LocalizedStringByAppendingString(@"medialive_real_time_transport_bitrate", @":%d kbps\n"), (int)statistics.transportVideoBitrate)];
    return attributedString;
}

- (void)sendSEIWithKey:(NSString *)key value:(NSString *)value {
    [self.pusher sendSeiMessage:key value:value repeat:-1 isKeyFrame:YES allowsCovered:YES];
    [self.pusher requestIDRFrame];
}

- (void)stopSendSEIForKey:(NSString *)key {
    [self.pusher sendSeiMessage:key value:nil repeat:0 isKeyFrame:NO allowsCovered:NO];
}
- (void)setupEffectManager {
    if (!self.hasInitEffect) {
        self.hasInitEffect = YES;
        _beautyComponent = [[BytedEffectProtocol alloc] initWithEngine:self.pusher withType:EffectTypeMediaLive useCache:YES];
        if (_beautyComponent == nil) {
            self.hasInitEffect = NO;
        }
    }
}
- (void)startRecord:(int)width height:(int)height {
    VeLiveFileRecorderConfiguration *cfg = [[VeLiveFileRecorderConfiguration alloc] init];
    cfg.width = width;
    cfg.height = height;
    if ([VELDeviceRotateHelper currentDeviceOrientation] == UIDeviceOrientationLandscapeLeft || [VELDeviceRotateHelper currentDeviceOrientation] == UIDeviceOrientationLandscapeRight) {
        int max = (int)MAX(cfg.width, cfg.height);
        int min = (int)MIN(cfg.width, cfg.height);
        cfg.width = max;
        cfg.height = min;
    }
    [self.pusher startFileRecording:[self getRecordPath:YES] config:cfg listener:self];
    self.isRecording = YES;
}
- (void)stopRecord {
    if (self.isRecording) {
        [self.pusher stopFileRecording];
    }
    self.isRecording = NO;
}
- (void)snapShot {
    if (self.isRecording) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_record", @"MediaLive")];
        return;
    }
    [self.pusher snapshot:self];
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
    return self.pusher.getCameraDevice.getCurrentZoomRatio;
}
- (CGFloat)getCameraZoomMaxRatio {
    return self.pusher.getCameraDevice.getMaxZoomRatio;
}
- (CGFloat)getCameraZoomMinRatio {
    return self.pusher.getCameraDevice.getMinZoomRatio;
}
- (void)setCameraZoomRatio:(CGFloat)ratio {
    [self.pusher.getCameraDevice setZoomRatio:ratio];
}

- (BOOL)isSupportCameraZoomRatio {
    return YES;
}

- (BOOL)isAutoFocusSupported {
    return YES;
}

- (void)enableCameraAutoFocus:(BOOL)enable {
    [self.pusher.getCameraDevice enableAutoFocus:enable];
}

- (void)setCameraFocusPosition:(CGPoint)position {
    [self.pusher.getCameraDevice setFocusPosition:position];
}

/// MARK: - All Listeners
- (void)addPushListeners {
    [self.pusher addVideoFrameListener:self];
    [self.pusher addAudioFrameListener:self];
    [self.pusher setVideoFrameFilter:self];
    [self.pusher setAudioFrameFilter:self];
}

- (void)removePushListeners {
    [self.pusher removeAudioFrameListener:self];
    [self.pusher removeVideoFrameListener:self];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.pusher setVideoFrameFilter:nil];
    [self.pusher setAudioFrameFilter:nil];
#pragma clang diagnostic pop
}

/// MARK: - VeLivePusherObserver
- (void)onError:(int)code subcode:(int)subcode message:(nullable NSString *)msg {
    NSString *info = [NSString stringWithFormat:@"%@-(%d-%d)", msg, code, subcode];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    vel_sync_main_queue(^{
        [VELUIToast showText:@"%@", info];
        [self setStreamStatus:(VELStreamStatusError) msg:msg];
    });
}
- (void)onStatusChange:(VeLivePushStatus)status {
    NSString *info = [NSString stringWithFormat:LocalizedStringByAppendingString(@"medialive_push_status", @"：%@"), [self getStreamStatusDes:status]];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    vel_sync_main_queue(^{
        NSString *msg = nil;
        switch (status) {
            case VeLivePushStatusNone:
                msg = LocalizedStringFromBundle(@"medialive_push_status_unknown", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusNone) msg:msg];
                break;
            case VeLivePushStatusConnecting:
                msg = LocalizedStringFromBundle(@"medialive_push_status_connecting", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusConnecting) msg:msg];
                break;
            case VeLivePushStatusConnectSuccess:
                msg = LocalizedStringFromBundle(@"medialive_push_status_connected", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusConnected) msg:msg];
                break;
            case VeLivePushStatusReconnecting:
                msg = LocalizedStringFromBundle(@"medialive_push_status_reconnecting", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusReconnecting) msg:msg];
                break;
            case VeLivePushStatusConnectStop:
                msg = LocalizedStringFromBundle(@"medialive_push_status_stop", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusStop) msg:msg];
                break;
            case VeLivePushStatusConnectError:
                msg = LocalizedStringFromBundle(@"medialive_push_status_error", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusError) msg:msg];
                break;
            case VeLivePushStatusDisconnected:
                msg = LocalizedStringFromBundle(@"medialive_push_status_disconnect", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusEnded) msg:msg];
                break;
            default:
                break;
        }
    });
}

- (void)onFirstVideoFrame:(VeLiveFirstFrameType)type timestampMs:(int64_t)timestampMs {
    NSString *info = [NSString stringWithFormat:LocalizedStringByAppendingString(@"medialive_video_first_frame", @"-%d"), (int)type];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
}


- (void)onFirstAudioFrame:(VeLiveFirstFrameType)type timestampMs:(int64_t)timestampMs {
    NSString *info = [NSString stringWithFormat:LocalizedStringByAppendingString(@"medialive_audio_first_frame", @"-%d"), (int)type];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
}

- (void)onCameraOpened:(bool)open {
    NSString *info = open ? LocalizedStringFromBundle(@"medialive_camer_on", @"MediaLive") : LocalizedStringFromBundle(@"medialive_camer_off", @"MediaLive");
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    vel_sync_main_queue(^{
        [VELUIToast showText:@"%@", info];
    });
}

- (void)onMicrophoneOpened:(bool)open {
    NSString *info = open ? LocalizedStringFromBundle(@"medialive_mic_on", @"MediaLive") : LocalizedStringFromBundle(@"medialive_mic_off", @"MediaLive");
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    vel_sync_main_queue(^{
        [VELUIToast showText:@"%@", info];
    });
}

- (void)onNetworkQuality:(VeLiveNetworkQuality)quality {
    NSString *info = [NSString stringWithFormat:LocalizedStringByAppendingString(@"medialive_network_quality", @": %@"), [self getNetworQualityDes:quality]];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    vel_sync_main_queue(^{
        switch (quality) {
            case VeLiveNetworkQualityUnknown:
                [self setNetworkQuality:(VELNetworkQualityUnKnown)];
                break;
            case VeLiveNetworkQualityBad:
                [self setNetworkQuality:(VELNetworkQualityBad)];
                break;
            case VeLiveNetworkQualityPoor:
                [self setNetworkQuality:(VELNetworkQualityPoor)];
                break;
            case VeLiveNetworkQualityGood:
                [self setNetworkQuality:(VELNetworkQualityGood)];
                break;
        }
    });
}

- (void)onAudioPowerQuality:(VeLiveAudioPowerLevel)level value:(float)value {
    NSString *info = [NSString stringWithFormat:LocalizedStringByAppendingString(@"medialive_audio_quality", @"-%@-%.2f"), [self getAudioQualityDes:level], value];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
}

- (void)onVideoFluencyQuality:(VeLiveVideoFluencyLevel)level fps:(int)fps {
    NSString *info = [NSString stringWithFormat:LocalizedStringByAppendingString(@"medialive_video_quality", @"-%d-%d"),(int)level, fps];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
}

- (void)onStatistics:(VeLivePusherStatistics *)statistics {
    self.staticts = statistics;
    NSString *info = [self getPushInfoString].string;
    [self updateCycleInfo:info append:NO];
    VELLogDebug(LOG_TAG, @"%@", info);
}

/// MARK: - VeLiveFileRecordingListener

- (void)onFileRecordingStarted {
    NSString *info = [NSString stringWithFormat:LocalizedStringFromBundle(@"medialive_start_record", @"MediaLive")];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    vel_sync_main_queue(^{
        [VELUIToast showText:@"%@", info];
        [self setRecordStartResultError:nil];
    });
}

- (void)onFileRecordingStopped {
    NSString *info = [NSString stringWithFormat:LocalizedStringFromBundle(@"medialive_stop_record", @"MediaLive")];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    vel_sync_main_queue(^{
        [VELUIToast showText:@"%@", info];
        [self setRecordResult:[self getRecordPath:NO] error:nil];
    });
}

- (void)onFileRecordingError:(int)errorCode message:(NSString *)msg {
    NSString *info = [NSString stringWithFormat:LocalizedStringByAppendingString(@"medialive_record_failed", @" - %d - %@"),errorCode, msg];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    vel_sync_main_queue(^{
        [self setRecordResult:nil error:VEL_ERROR(errorCode, msg)];
    });
}

/// MARK: - VeLiveSnapshotListener
- (void)onSnapshotComplete:(UIImage *)image {
    NSString *info = [NSString stringWithFormat:LocalizedStringFromBundle(@"medialive_snapshot_finished", @"MediaLive")];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    vel_sync_main_queue(^{
        [self setSnapShotResult:image error:nil];
    });
}


/// MARK: - Lazy
- (NSString *)getRecordPath:(BOOL)delete {
    NSString *videoPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    videoPath = [videoPath stringByAppendingPathComponent:@"record_video.mp4"];
    if (delete && [NSFileManager.defaultManager fileExistsAtPath:videoPath]) {
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

- (NSString *)getStreamStatusDes:(VeLivePushStatus)status {
    switch (status) {
        case VeLivePushStatusNone: return @"None";
        case VeLivePushStatusConnecting: return @"Connecting";
        case VeLivePushStatusConnectSuccess: return @"ConnectSuccess";
        case VeLivePushStatusReconnecting: return @"Reconnecting";
        case VeLivePushStatusConnectStop: return @"Stop";
        case VeLivePushStatusConnectError: return @"Error";
        case VeLivePushStatusDisconnected: return @"Disconnected";
    }
    return @"UnKnown";
}

- (NSString *)getNetworQualityDes:(VeLiveNetworkQuality)quality {
    switch (quality) {
        case VeLiveNetworkQualityUnknown : return @"Unknown";
        case VeLiveNetworkQualityBad : return @"Bad";
        case VeLiveNetworkQualityPoor : return @"Poor";
        case VeLiveNetworkQualityGood : return @"Good";
    }
    return @"Unknown";
}

- (NSString *)getAudioQualityDes:(VeLiveAudioPowerLevel)audioPower {
    switch ((int)audioPower) {
        case 0: return @"Silent - 无声";
        case 1: return @"Quiet - 安静";
        case 2: return @"Light - 轻声";
        case 3: return @"Normal - 正常";
        case 4: return @"Loud - 较大";
        case 5: return @"Noisy - 吵闹";
    }
    return @"Silent - 无声";
}

- (void)writeWaterMarkImage:(UIImage *)image {
    NSData *localData = UIImagePNGRepresentation(image);
    NSString *mixImageLocaPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    mixImageLocaPath = [mixImageLocaPath stringByAppendingPathComponent:@"pusher_water_mark.png"];
    [localData writeToFile:mixImageLocaPath atomically:YES];
}
@end


