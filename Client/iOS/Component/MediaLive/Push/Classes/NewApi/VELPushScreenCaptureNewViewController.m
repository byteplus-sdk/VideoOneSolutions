// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushScreenCaptureNewViewController.h"
#import "VELPushUIViewController+Private.h"
#import <AppConfig/BuildConfig.h>
#import <BytePlusRTC/BytePlusRTC.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>

#define LocalizedStringByAppendingString(key,sufix) [LocalizedStringFromBundle(key, @"MediaLive") stringByAppendingString:sufix]
#define LOG_TAG @"NEW_PUSH_SCREEN"

static NSString *const kScreenPushTaskId = @"vel_screen_push_task";
static NSString *const kScreenPushRoomIdPrefix = @"vel_screen_push_room";

@interface VELPushScreenCaptureNewViewController()<ByteRTCEngineDelegate, ByteRTCRoomDelegate>
@property (nonatomic, strong) ByteRTCEngine *rtcEngine;
@property (nonatomic, strong) ByteRTCRoom *rtcRoom;
@property (nonatomic, strong) NSString *rtcToken;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic) UIInterfaceOrientation orientation;
@property (nonatomic, strong) ByteRTCLocalStreamStats *localStats;
@end

@implementation VELPushScreenCaptureNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_preview", @"MediaLive")];
}

- (void)setupEngine {
    if (self.rtcEngine) {
        return;
    }
    ByteRTCEngineConfig *config = [[ByteRTCEngineConfig alloc] init];
    config.appID = [RTCTokenProtocol rtcAppId];
    config.parameters = @{};
    self.rtcEngine = [ByteRTCEngine createRTCEngine:config delegate:self];
    [self.rtcEngine setExtensionConfig:APP_GROUP_ID];
    
    self.userId = [LocalUserComponent userModel].uid;
    self.roomId = [NSString stringWithFormat:@"%@_%@", kScreenPushRoomIdPrefix, self.userId];
    if (!self.rtcRoom) {
        self.rtcRoom = [self.rtcEngine createRTCRoom:self.roomId];
        [self.rtcRoom setRTCRoomDelegate:self];
    }

    ByteRTCVideoEncoderConfig *videoEncoderConfig = [[ByteRTCVideoEncoderConfig alloc] init];
    videoEncoderConfig.width = self.config.encodeSize.width;
    videoEncoderConfig.height = self.config.encodeSize.height;
    videoEncoderConfig.frameRate = self.config.encodeFPS;
    videoEncoderConfig.maxBitrate = self.config.bitrate;
    videoEncoderConfig.minBitrate = self.config.enableAutoBitrate ? -1 : self.config.bitrate;
    videoEncoderConfig.keyFrameIntervalMS = 2000;
    [self.rtcEngine setVideoEncoderConfig:videoEncoderConfig];
}

- (void)destoryEngine {
    [self.rtcEngine stopScreenCapture];
    if (self.rtcRoom) {
        [self.rtcRoom destroy];
        self.rtcRoom = nil;
    }
    [ByteRTCEngine destroyRTCEngine];
    self.rtcEngine = nil;
}

- (void)startVideoCapture {
    // do nothing for screen streaming
}

- (void)stopVideoCapture {
    // do nothing for screen streaming
}

- (void)startAudioCapture {
    // do nothing for screen streaming
}

- (void)stopAudioCapture {
    // do nothing for screen streaming
}

- (void)muteAudio {
    [self.rtcEngine muteAudioCapture:YES];
}
- (void)unMuteAudio {
    [self.rtcEngine muteAudioCapture:NO];
}
- (void) checkAndRotation {
    if ([self isStreaming]) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_change_rotation", @"MediaLive") detailText:@""];
        return;
    }
    if (self.orientation == UIInterfaceOrientationUnknown || self.orientation == UIInterfaceOrientationPortrait) {
        self.orientation = UIInterfaceOrientationLandscapeRight;
        [self.rtcEngine setVideoOrientation:ByteRTCVideoOrientationLandscape];
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_landscape_push", @"MediaLive") detailText:@""];
    } else {
        self.orientation = UIInterfaceOrientationPortrait;
        [self.rtcEngine setVideoOrientation:ByteRTCVideoOrientationPortrait];
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_portrait_push", @"MediaLive") detailText:@""];
    }
}

- (BOOL) isStreaming {
    return self.streamStatus == VELStreamStatusConnecting || self.streamStatus == VELStreamStatusReconnecting || self.streamStatus == VELStreamStatusConnected;
}

- (void)backButtonClick {
    [self stopStreaming];
    [super backButtonClick];
}

- (void)startStreaming {
    if (![self checkConfigIsValid]) {
        return;
    }
    self.micViewModel.isSelected = NO;
    [self.micViewModel updateUI];

    ByteRTCVideoEncoderConfig *videoEncodeConfig = [[ByteRTCVideoEncoderConfig alloc] init];
    videoEncodeConfig.width = self.config.encodeSize.width;
    videoEncodeConfig.height = self.config.encodeSize.height;
    videoEncodeConfig.frameRate = self.config.encodeFPS;
    videoEncodeConfig.maxBitrate = self.config.bitrate;
    videoEncodeConfig.minBitrate = self.config.enableAutoBitrate ? -1 : self.config.bitrate;
    videoEncodeConfig.keyFrameIntervalMS = 2000;
    [self.rtcEngine setVideoEncoderConfig:videoEncodeConfig];
    
    [self.rtcEngine startScreenCapture:ByteRTCScreenMediaTypeVideoAndAudio bundleId:BROADCASE_EXTENSION_BUNDLE_ID];
}

- (void)exitStreaming {
    [self stopStreaming];
}

- (void)startStreamingInternal {
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
        [self.rtcRoom joinRoom:token userInfo:userInfo userVisibility:YES roomConfig:roomConfig];

        [self.config.urls enumerateObjectsUsingBlock:^(NSString * _Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
            if (url.length > 0) {
                NSString *taskId = [NSString stringWithFormat:@"%@_%ld", kScreenPushTaskId, (unsigned long)idx];
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
    }];
}

- (void)stopStreamingInternal {
    [self.config.urls enumerateObjectsUsingBlock:^(NSString * _Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
        if (url.length > 0) {
            NSString *taskId = [NSString stringWithFormat:@"%@_%ld", kScreenPushTaskId, (unsigned long)idx];
            [self.rtcEngine stopPushSingleStream:taskId];
        }
    }];
    if (self.rtcRoom) {
        [self.rtcRoom leaveRoom];
    }
}

- (void)stopStreaming {
    [self stopStreamingInternal];
    [self.rtcEngine stopScreenCapture];
    [VELUIToast hideAllLoadingView];
    [self setStreamStatus:(VELStreamStatusNone) msg:nil];
}

- (void)updateVideoEncodeFps:(int)fps {
    if (fps < 15 || fps > 30) {
        return;
    }
    self.config.encodeFPS = fps;
    [self updateRTCVideoEncoderConfig];
}

- (void)updateVideoEncodeResolution:(VELSettingResolutionType)resolution {
    self.config.encodeResolutionType = resolution;
    [self updateRTCVideoEncoderConfig];
}

- (void)updateRTCVideoEncoderConfig {
    VOLogD(VOMediaLive, @"fps: %ld resolusion: %ld", self.config.encodeFPS, self.config.encodeResolutionType);
    ByteRTCVideoEncoderConfig *videoEncodeCfg = [[ByteRTCVideoEncoderConfig alloc] init];
    videoEncodeCfg.width = self.config.encodeSize.width;
    videoEncodeCfg.height = self.config.encodeSize.height;
    videoEncodeCfg.frameRate = self.config.encodeFPS;
    videoEncodeCfg.maxBitrate = self.config.bitrate;
    videoEncodeCfg.minBitrate = self.config.enableAutoBitrate ? -1 : self.config.bitrate;
    videoEncodeCfg.keyFrameIntervalMS = 2000;
    [self.rtcEngine setVideoEncoderConfig:videoEncodeCfg];
}

- (NSAttributedString *)getPushInfoString {
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    static NSDictionary *contentStyle = nil;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    [paraStyle setParagraphStyle:NSParagraphStyle.defaultParagraphStyle];
    paraStyle.lineHeightMultiple = 1.2;
    if (!contentStyle) {
        contentStyle = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.whiteColor,
            NSParagraphStyleAttributeName : paraStyle,
        };
    }
#define VEL_PUSH_CONTENT(fmt, ...) [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:fmt, ##__VA_ARGS__] attributes:contentStyle]

    ByteRTCLocalVideoStats *videoStats = self.localStats.videoStats;
    ByteRTCLocalAudioStats *audioStats = self.localStats.audioStats;

    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%@\n", LocalizedStringFromBundle(@"medialive_push_adress", @"MediaLive"),self.config.urls.firstObject ?: @"")];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d kbps\n", LocalizedStringFromBundle(@"medialive_video_max_bitrate", @"MediaLive"),(int)self.config.bitrate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d kbps\n", LocalizedStringFromBundle(@"medialive_video_initial_bitrate", @"MediaLive"),(int)self.config.bitrate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d, %d \n", LocalizedStringFromBundle(@"medialive_video_capture_resolution", @"MediaLive"),(int)self.config.captureSize.width, (int)self.config.captureSize.height)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d, %d \n", LocalizedStringFromBundle(@"medialive_video_push_resolution", @"MediaLive"),(int)self.config.encodeSize.width, (int)self.config.encodeSize.height)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d \n", LocalizedStringFromBundle(@"medialive_video_capture_fps", @"MediaLive"),(int)self.config.captureFPS)];
    
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d/%d\n", LocalizedStringFromBundle(@"medialive_video_capture_io_fps", @"MediaLive"),(int)videoStats.inputFrameRate, (int)videoStats.sentFrameRate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%@ \n", LocalizedStringFromBundle(@"medialive_video_encode_format", @"MediaLive"),@"H264")];
    
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d \n", LocalizedStringFromBundle(@"medialive_real_time_transport_fps", @"MediaLive"),(int)videoStats.sentFrameRate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d kbps\n",LocalizedStringFromBundle(@"medialive_real_time_encode_bitrate", @"MediaLive"), (int)videoStats.sentKBitrate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d kbps\n",LocalizedStringFromBundle(@"medialive_real_time_transport_bitrate", @"MediaLive"), (int)(videoStats.sentKBitrate + audioStats.sentKBitrate))];
    
    return attributedString;
}

#pragma mark - ByteRTCEngineDelegate

- (void)rtcEngine:(ByteRTCEngine *)engine onConnectionStateChanged:(ByteRTCConnectionState)state {
    VELLogDebug(LOG_TAG, @"Connection state changed: %ld", (long)state);
}

- (void)rtcEngine:(ByteRTCEngine *)engine onError:(ByteRTCErrorCode)errorCode {
    NSString *info = [NSString stringWithFormat:@"RTC Error: %ld", (long)errorCode];
    [self updateCallBackInfo:info append:YES];
    vel_sync_main_queue(^{
        [VELUIToast showText:@"%@", info];
        [self setStreamStatus:(VELStreamStatusError) msg:info];
    });
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
                msg = LocalizedStringFromBundle(@"medialive_push_screen_status_error", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusError) msg:msg];
                break;
            case ByteRTCSingleStreamTaskEventStopSuccess:
                msg = LocalizedStringFromBundle(@"medialive_push_status_stop", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusStop) msg:msg];
                break;
            case ByteRTCSingleStreamTaskEventStopFailed:
            case ByteRTCSingleStreamTaskEventWarning:
                msg = LocalizedStringFromBundle(@"medialive_push_status_reconnecting", @"MediaLive");
                [self setStreamStatus:(VELStreamStatusReconnecting) msg:msg];
                break;
            default:
                break;
        }
    });
}

- (void)rtcEngine:(ByteRTCEngine *)engine onVideoDeviceStateChanged:(NSString *)deviceID device_type:(ByteRTCVideoDeviceType)deviceType device_state:(ByteRTCMediaDeviceState)deviceState device_error:(ByteRTCMediaDeviceError)deviceError {
    if (deviceType != ByteRTCVideoDeviceTypeScreenCaptureDevice) {
        return;
    }
    if (deviceState == ByteRTCMediaDeviceStateStarted) {
        [self startStreamingInternal];
    } else {
        [self stopStreamingInternal];
    }
}

- (float)getCurrentAudioLoudness {
    return 0;
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

- (void)setEnableAudioHardwareEcho:(BOOL)enable {
    if (enable) {
        [self.rtcEngine setEarMonitorMode:ByteRTCEarMonitorModeOn];
    } else {
        [self.rtcEngine setEarMonitorMode:ByteRTCEarMonitorModeOff];
    }
}

- (BOOL)isHardwareEchoEnable {
    return NO;
}

- (void)setAudioLoudness:(float)loudness {
    [self.rtcEngine setCaptureVolume:(int)(loudness * 100)];
}

@end
