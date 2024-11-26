// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveNormalPushStreamingImpl.h"
#import "LiveRTCInteractUtils.h"
#import "LiveRTCManager.h"
#import "LiveSettingData.h"
#import "LiveStreamConfiguration.h"
#import <TTSDK/VeLivePusher.h>

@interface LiveNormalPushStreamingImpl () <ByteRTCVideoSinkDelegate,
                                           ByteRTCAudioFrameObserver,
                                           VeLivePusherObserver,
                                           VeLivePusherStatisticsObserver>

@property (nonatomic, strong) VeLivePusher *livePusher;
@property (nonatomic, strong) VeLiveVideoEncoderConfiguration *videoEncoderConfig;

@property (nonatomic, assign) BOOL isRTCSinkReady;

@end

@implementation LiveNormalPushStreamingImpl

@synthesize streamLogCallback;

- (instancetype)init {
    if (self = [super init]) {
    }

    return self;
}

- (void)dealloc {
    [self stopNormalStreaming];
    [self destroyLivePusher];
}

- (void)setStreamConfig:(LiveNormalStreamConfig *)streamConfig {
    _streamConfig = streamConfig;
}

- (void)startNormalStreaming {
    [self setupLiveCoreIfNeed];

    if (![self.livePusher isPushing]) {
        NSString *rtmpUrl = self.streamConfig.rtmpUrl;
        rtmpUrl = [LiveRTCInteractUtils setPriorityForUrl:rtmpUrl];
        NSAssert(rtmpUrl, @"rtmp url is nil");
        NSArray *urls = @[rtmpUrl];

        [self.livePusher startPushWithUrls:urls];
    }

    [self addRTCVideoAndAudioSink];
}

- (void)stopNormalStreaming {
    [self removeRTCVideoAndAudioSink];
    [self.livePusher stopPush];
}

- (void)cameraStateChanged:(BOOL)cameraOn {
    if (cameraOn) {
        [self stopPushDarkFrame];
    } else {
        if ([self.livePusher isPushing]) {
            [self startPushDarkFrame];
        }
    }
}

- (void)setupLiveCoreIfNeed {
    if (self.livePusher != nil) {
        return;
    }

    LiveNormalStreamConfig *streamConfig = self.streamConfig;

    // Video Capture Config
    VeLiveVideoCaptureConfiguration *videoCaptureConfig = [[VeLiveVideoCaptureConfiguration alloc] init];
    videoCaptureConfig.width = streamConfig.outputSize.width;
    videoCaptureConfig.height = streamConfig.outputSize.height;
    videoCaptureConfig.fps = (int)streamConfig.videoFPS;

    // Audio Capture Config
    VeLiveAudioCaptureConfiguration *audioCaptureConfig = [[VeLiveAudioCaptureConfiguration alloc] init];
    audioCaptureConfig.sampleRate = VeLiveAudioSampleRate44100;
    audioCaptureConfig.channel = VeLiveAudioChannelStereo;

    VeLivePusherConfiguration *config = [[VeLivePusherConfiguration alloc] init];
    config.reconnectCount = 12;
    config.reconnectIntervalSeconds = 5; // seconds
    config.videoCaptureConfig = videoCaptureConfig;
    config.audioCaptureConfig = audioCaptureConfig;

    self.livePusher = [[VeLivePusher alloc] initWithConfig:config];

    [self.livePusher setObserver:self];
    [self.livePusher setStatisticsObserver:self interval:1];

    // Video Encoder Config
    VeLiveVideoResolution resolution = VeLiveVideoResolution720P;
    CGFloat minValue = MIN(streamConfig.outputSize.width, streamConfig.outputSize.height);

    if (minValue <= 360) {
        resolution = VeLiveVideoResolution360P;
    } else if (minValue <= 480) {
        resolution = VeLiveVideoResolution480P;
    } else if (minValue <= 720) {
        resolution = VeLiveVideoResolution720P;
    } else {
        resolution = VeLiveVideoResolution1080P;
    }

    VeLiveVideoEncoderConfiguration *videoEncoderConfig = [[VeLiveVideoEncoderConfiguration alloc] initWithResolution:(resolution)];
    videoEncoderConfig.minBitrate = streamConfig.minBitrate * 0.001;
    videoEncoderConfig.maxBitrate = streamConfig.maxBitrate * 0.001;
    videoEncoderConfig.bitrate = streamConfig.bitrate * 0.001;
    videoEncoderConfig.fps = (int)streamConfig.videoFPS;

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"16.4") && SYSTEM_VERSION_LESS_THAN(@"16.5")) {
        videoEncoderConfig.minBitrate = streamConfig.bitrate * 0.001;
        videoEncoderConfig.maxBitrate = streamConfig.bitrate * 0.001;
        videoEncoderConfig.bitrate = streamConfig.bitrate * 0.001;
        [self.livePusher setProperty:@"VeLiveKeySetBitrateAdaptStrategy" value:@"CLOSE"];
    }

    self.videoEncoderConfig = videoEncoderConfig;

    [self.livePusher setVideoEncoderConfiguration:videoEncoderConfig];

    [self.livePusher startVideoCapture:VeLiveVideoCaptureExternal];
    [self.livePusher startAudioCapture:VeLiveAudioCaptureExternal];
}

- (void)destroyLivePusher {
    [self.livePusher stopAudioCapture];
    [self.livePusher stopVideoCapture];
    [self.livePusher destroy];
    self.livePusher = nil;
}

- (void)startPushDarkFrame {
    [self.livePusher switchVideoCapture:VeLiveVideoCaptureDummyFrame];
}

- (void)stopPushDarkFrame {
    [self.livePusher switchVideoCapture:VeLiveVideoCaptureExternal];
}

- (void)toggleReconnectCapability:(BOOL)turnOn {
    //    self.livePusher.reconnectCount =  turnOn ? 9 : 0;
    //
    //    self.livePusher.liveSession.maxReconnectCount = turnOn ? 9 : 0;
}

#pragma mark-- VeLivePusherObserver & VeLivePusherStatisticsObserver
- (void)onStatusChange:(VeLivePushStatus)status {
    VOLogI(VOInteractiveLive,@"VeLivePusher: onStatusChange: %lu", status);

    if (status == VeLivePushStatusConnectSuccess) {
        NSDictionary *dic = @{
            @"liveMode": @(1),
            @"LIVECore": @(1)
        };
        id obj = [dic yy_modelToJSONString];
        // Because liveMode=1 is default status, so 60 times is enough to tell client change layout
        if (obj) {
            [self.livePusher sendSeiMessage:@"app_data" value:obj repeat:60 isKeyFrame:YES allowsCovered:YES];
        }
    }
}

- (void)onNetworkQuality:(VeLiveNetworkQuality)quality {
    VOLogI(VOInteractiveLive,@"VeLivePusher: onNetworkQuality: %lu", quality);
    if ([self.delegate respondsToSelector:@selector(updateOnNetworkStatusChange:)]) {
        LiveNetworkQualityStatus liveQuality = LiveNetworkQualityStatusBad;
        switch (quality) {
            case VeLiveNetworkQualityGood:
                liveQuality = LiveNetworkQualityStatusGood;
                break;
            case VeLiveNetworkQualityPoor:
            case VeLiveNetworkQualityBad:
                liveQuality = LiveNetworkQualityStatusBad;
                break;
            case VeLiveNetworkQualityUnknown:
                liveQuality = LiveNetworkQualityStatusNone;
                break;
            default:
                liveQuality = LiveNetworkQualityStatusNone;
                break;
        }
        [self.delegate updateOnNetworkStatusChange:liveQuality];
    }
}

- (void)onStatistics:(VeLivePusherStatistics *)statistics {
    if (self.streamLogCallback == nil) {
        return;
    }
    NSDictionary *log = @{
        @"event_key": @"push_stream",
        @"defaultBitrate": @(statistics.videoBitrate * 1000),
        @"minBitrate": @(statistics.minVideoBitrate * 1000),
        @"maxBitrate": @(statistics.maxVideoBitrate * 1000),
        @"width": @(self.streamConfig.outputSize.width),
        @"height": @(self.streamConfig.outputSize.height),
        @"fps": @(self.streamConfig.videoFPS),
        @"video_codec": statistics.codec ?: @"unknown",
        @"hardware": @(self.videoEncoderConfig.enableAccelerate),
        @"preview_fps": @(self.streamConfig.videoFPS),
        @"transportFps": @(statistics.transportFps),
        @"video_enc_bitrate": @(statistics.encodeVideoBitrate),
        @"real_bitrate": @(statistics.transportVideoBitrate),
    };

    NSDictionary *extra = @{
        @"defaultBitrate": @(statistics.videoBitrate * 1000),
        @"minBitrate": @(statistics.minVideoBitrate * 1000),
        @"maxBitrate": @(statistics.maxVideoBitrate * 1000),
        @"fps": @(statistics.fps),
        @"strategy": @"normal",
    };
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.streamLogCallback) {
            self.streamLogCallback(statistics.videoBitrate * 1000, log, extra);
        }
    });
}

#pragma mark-- ByteRTC Video and Audio Sink
- (void)addRTCVideoAndAudioSink {
    if (self.isRTCSinkReady) {
        return;
    }

    [[LiveRTCManager shareRtc].rtcEngineKit setLocalVideoSink:ByteRTCStreamIndexMain
                                                     withSink:self
                                              withPixelFormat:ByteRTCVideoSinkPixelFormatI420];

    ByteRTCAudioFormat *audioFormat = [[ByteRTCAudioFormat alloc] init];
    audioFormat.channel = ByteRTCAudioChannelStereo;
    audioFormat.sampleRate = ByteRTCAudioSampleRate44100;
    [[LiveRTCManager shareRtc].rtcEngineKit enableAudioFrameCallback:(ByteRTCAudioFrameCallbackRecord)
                                                              format:audioFormat];
    [[LiveRTCManager shareRtc].rtcEngineKit registerAudioFrameObserver:self];
    self.isRTCSinkReady = YES;
}

- (void)removeRTCVideoAndAudioSink {
    if (!self.isRTCSinkReady) {
        return;
    }

    [[LiveRTCManager shareRtc].rtcEngineKit setLocalVideoSink:ByteRTCStreamIndexMain
                                                     withSink:nil
                                              withPixelFormat:ByteRTCVideoSinkPixelFormatI420];
    [[LiveRTCManager shareRtc].rtcEngineKit registerAudioFrameObserver:nil];
    self.isRTCSinkReady = NO;
}

#pragma mark-- ByteRTCVideoSinkDelegate
- (void)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer rotation:(ByteRTCVideoRotation)rotation contentType:(ByteRTCVideoContentType)contentType extendedData:(NSData *)extendedData {
    CMTime pts = CMTimeMakeWithSeconds(CACurrentMediaTime(), 1000000000);
    VeLiveVideoFrame *videoFrame = [[VeLiveVideoFrame alloc] init];

    videoFrame.pts = pts;
    videoFrame.pixelBuffer = pixelBuffer;
    VeLiveVideoRotation videoRotation = VeLiveVideoRotation0;
    switch (rotation) {
        case ByteRTCVideoRotation0:
            videoRotation = VeLiveVideoRotation0;
            break;

        case ByteRTCVideoRotation90:
            videoRotation = VeLiveVideoRotation90;
            break;

        case ByteRTCVideoRotation180:
            videoRotation = VeLiveVideoRotation180;
            break;

        case ByteRTCVideoRotation270:
            videoRotation = VeLiveVideoRotation270;
            break;

        default:
            break;
    }
    videoFrame.rotation = videoRotation;
    videoFrame.bufferType = VeLiveVideoBufferTypePixelBuffer;
    [self.livePusher pushExternalVideoFrame:videoFrame];
}

- (int)getRenderElapse {
    return 0;
}

#pragma mark--  ByteRTCAudioFrameObserver
- (void)onRecordAudioFrame:(ByteRTCAudioFrame *_Nonnull)audioFrame {
    int channel = 2;

    if (audioFrame.channel == ByteRTCAudioChannelMono) {
        channel = 1;
    } else if (audioFrame.channel == ByteRTCAudioChannelStereo) {
        channel = 2;
    }

    CMTime pts = CMTimeMakeWithSeconds(CACurrentMediaTime(), 1000000000);

    VeLiveAudioFrame *frame = [[VeLiveAudioFrame alloc] init];
    frame.bufferType = VeLiveAudioBufferTypeNSData;
    frame.data = audioFrame.buffer;
    frame.pts = pts;
    frame.channels = (VeLiveAudioChannel)channel;
    frame.sampleRate = VeLiveAudioSampleRate44100;

    [self.livePusher pushExternalAudioFrame:frame];
}

- (void)onMixedAudioFrame:(ByteRTCAudioFrame *_Nonnull)audioFrame {
}

- (void)onPlaybackAudioFrame:(ByteRTCAudioFrame *_Nonnull)audioFrame {
}

- (void)onRemoteUserAudioFrame:(ByteRTCRemoteStreamKey *_Nonnull)streamKey audioFrame:(ByteRTCAudioFrame *_Nonnull)audioFrame {
}

@end
