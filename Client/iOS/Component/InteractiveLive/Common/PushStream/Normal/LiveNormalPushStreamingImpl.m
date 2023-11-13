// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveNormalPushStreamingImpl.h"
#import "LiveRTCInteractUtils.h"
#import "LiveRTCManager.h"
#import "LiveSettingData.h"
#import "LiveStreamConfiguration.h"

@interface LiveNormalPushStreamingImpl ()

@property (nonatomic, strong) LiveCore *liveCore;

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
    self.liveCore = nil;
}

- (void)setStreamConfig:(LiveNormalStreamConfig *)streamConfig {
    _streamConfig = streamConfig;
}

- (NSString *)generalRTMUrl:(NSString *)rtmpUrl {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:rtmpUrl];
    NSString *urlPath = urlComponents.path;
    if (IsEmptyStr(urlPath.pathExtension)) {
        urlPath = [urlPath stringByAppendingPathExtension:@"sdp"];
    } else {
        urlPath = [urlPath stringByReplacingOccurrencesOfString:urlPath.pathExtension withString:@"sdp"];
    }
    urlComponents.path = urlPath;
    if (![urlComponents.scheme hasPrefix:@"http"]) {
        urlComponents.scheme = @"http";
    }
    NSString *rtmUrl = urlComponents.URL.absoluteString;
    return rtmUrl;
}

- (void)startNormalStreaming {
    NSLog(@"aaa startNormalStreaming");
    [self setupLiveCoreIfNeed];
    if (![self.liveCore isStreaming]) {
        NSLog(@"aaa update normal config");
        LiveStreamConfiguration *sessionConfig = [LiveStreamConfiguration defaultConfiguration];
        NSString *rtmpUrl = self.streamConfig.rtmpUrl;
        rtmpUrl = [LiveRTCInteractUtils setPriorityForUrl:rtmpUrl];
        NSAssert(rtmpUrl, @"rtmp url is nil");
        //        rtm push
        if ([LiveSettingData rtmPushStreaming]) {
            NSString *rtmUrl = [self generalRTMUrl:rtmpUrl];
            sessionConfig.URLs = @[rtmUrl, rtmpUrl];
            /// We config this for oversea RTM, and it's needed.
            sessionConfig.rtsHttpPort = 9922;
            sessionConfig.rtsEnableDtls = YES;
        } else {
            sessionConfig.URLs = @[rtmpUrl];
        }
        sessionConfig.rtmpURL = rtmpUrl;
        sessionConfig.outputSize = _streamConfig.outputSize;
        //        sessionConfig.bitrateAdaptStrategy =
        sessionConfig.bitrate = _streamConfig.bitrate;
        sessionConfig.maxBitrate = _streamConfig.maxBitrate;
        sessionConfig.minBitrate = _streamConfig.minBitrate;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"16.4")) {
            sessionConfig.maxBitrate = sessionConfig.bitrate;
            sessionConfig.minBitrate = sessionConfig.bitrate;
            sessionConfig.bitrateAdaptStrategy = -1;
        }

        [self.liveCore setupLiveSessionWithConfig:sessionConfig];
        [self.liveCore startStreaming];
    }
    [[LiveRTCManager shareRtc].rtcEngineKit setLocalVideoSink:ByteRTCStreamIndexMain withSink:self withPixelFormat:ByteRTCVideoSinkPixelFormatI420];
    ByteRTCAudioFormat *audioFormat = [[ByteRTCAudioFormat alloc] init];
    audioFormat.channel = ByteRTCAudioChannelStereo;
    audioFormat.sampleRate = ByteRTCAudioSampleRate44100;
    [[LiveRTCManager shareRtc].rtcEngineKit enableAudioFrameCallback:(ByteRTCAudioFrameCallbackRecord) format:audioFormat];
    [[LiveRTCManager shareRtc].rtcEngineKit setAudioFrameObserver:self];
    WeakSelf;
    self.liveCore.statusChangedBlock = ^(LiveStreamSessionState state, LiveStreamErrorCode errCode) {
        StrongSelf;
        if (state == LiveStreamSessionStateStarted) {
            NSDictionary *dic = @{
                @"liveMode": @(1),
                @"LIVECore": @(1)
            };
            id obj = [dic yy_modelToJSONString];
            [sself.liveCore sendSEIMsgWithKey:@"app_data" value:obj repeatTimes:2];
        }
    };
    self.liveCore.networkQualityCallback = ^(LiveCoreNetworkQuality networkQuality) {
        StrongSelf;
        if ([sself.delegate respondsToSelector:@selector(updateOnNetworkStatusChange:)]) {
            [sself.delegate updateOnNetworkStatusChange:networkQuality];
        }
    };
    self.liveCore.networkQualityCallback(LiveCoreNetworkQualityBad);
}

- (void)stopNormalStreaming {
    NSLog(@"aaa stopNormalStreaming");
    [self.liveCore stopStreaming];
    [[LiveRTCManager shareRtc].rtcEngineKit setLocalVideoSink:ByteRTCStreamIndexMain withSink:nil withPixelFormat:ByteRTCVideoSinkPixelFormatI420];
    [[LiveRTCManager shareRtc].rtcEngineKit setAudioFrameObserver:nil];
}

- (void)setupLiveCoreIfNeed {
    if (self.liveCore) {
        return;
    }
    self.liveCore = [[LiveCore alloc] initWithMode:(LiveCoreModuleLiveStreaming)];
    [self.liveCore setStatusChangedBlock:^(LiveStreamSessionState state, LiveStreamErrorCode errCode) {
        switch (state) {
            case LiveStreamSessionStateError:
                NSLog(@"normal push error");
                break;
            case LiveStreamSessionStateUrlerr:
                NSLog(@"normal push url error");
                break;
            default:
                break;
        }
    }];
    WeakSelf;
    [self.liveCore setStreamLogCallback:^(NSDictionary *log) {
        StrongSelf;
        dispatch_queue_async_safe(dispatch_get_main_queue(), (^{
                                      NSNumber *bitrate = [sself.liveCore.liveSession getStreamInfoForKey:LiveStreamInfo_RealTransportBitrate];
                                      LiveStreamConfiguration *configuration = sself.liveCore.liveSession.configuration;
                                      NSString *strategy = @"None";
                                      switch (configuration.bitrateAdaptStrategy) {
                                          case LiveStreamBitrateAdaptationStrategy_NORMAL:
                                              strategy = @"normal";
                                              break;
                                          case LiveStreamBitrateAdaptationStrategy_SENSITIVE:
                                              strategy = @"sensitive";
                                              break;
                                          case LiveStreamBitrateAdaptationStrategy_MORE_SENSITIVE:
                                              strategy = @"more_sensitive";
                                              break;
                                          case LiveStreamBitrateAdaptationStrategy_BASE_BWE:
                                              strategy = @"base_bwe";
                                              break;
                                      }
                                      NSDictionary *extra = @{@"defaultBitrate": @(configuration.bitrate),
                                                              @"minBitrate": @(configuration.minBitrate),
                                                              @"maxBitrate": @(configuration.maxBitrate),
                                                              @"fps": @(configuration.videoFPS),
                                                              @"strategy": strategy
                                      };
                                      if (sself.streamLogCallback) {
                                          sself.streamLogCallback([bitrate integerValue], log, extra);
                                      }
                                  }));
    }];
}

#pragma mark-- ByteRTCVideoSinkDelegate
- (void)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer rotation:(ByteRTCVideoRotation)rotation contentType:(ByteRTCVideoContentType)contentType extendedData:(NSData *)extendedData {
    int64_t value = (int64_t)(CACurrentMediaTime() * 1000000000);
    int32_t timeScale = 1000000000;
    CMTime pts = CMTimeMake(value, timeScale);
    [self.liveCore.liveSession pushVideoBuffer:pixelBuffer andCMTime:pts rotation:(int)rotation];
}

- (int)getRenderElapse {
    return 0;
}

#pragma mark--  ByteRTCAudioFrameObserver
- (void)onRecordAudioFrame:(ByteRTCAudioFrame *_Nonnull)audioFrame;
{
    int channel = 2;
    if (audioFrame.channel == ByteRTCAudioChannelMono) {
        channel = 1;
    } else if (audioFrame.channel == ByteRTCAudioChannelStereo) {
        channel = 2;
    }

    int64_t value = (int64_t)(CACurrentMediaTime() * 1000000000);
    int32_t timeScale = 1000000000;
    CMTime pts = CMTimeMake(value, timeScale);

    int bytesPerFrame = 16 * channel / 8;
    int numFrames = (int)(audioFrame.buffer.length / bytesPerFrame);

    [self.liveCore pushAudioBuffer:(uint8_t *)[audioFrame.buffer bytes]
                        andDataLen:(size_t)audioFrame.buffer.length
                 andInNumberFrames:numFrames
                         andCMTime:pts];
}

- (void)onMixedAudioFrame:(ByteRTCAudioFrame *_Nonnull)audioFrame {
}

- (void)onPlaybackAudioFrame:(ByteRTCAudioFrame *_Nonnull)audioFrame {
}

- (void)onRemoteUserAudioFrame:(ByteRTCRemoteStreamKey *_Nonnull)streamKey audioFrame:(ByteRTCAudioFrame *_Nonnull)audioFrame {
}

@end
