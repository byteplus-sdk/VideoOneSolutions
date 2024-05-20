// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushScreenCaptureNewViewController.h"
#import "VELPushUIViewController+Private.h"
#import <AppConfig/BuildConfig.h>
#import <MediaLive/VeLiveSolutionScreenCaptureManager.h>
#import <MediaLive/VeLiveBroadcaseExtensionUILauncher.h>
#import <ToolKit/Localizator.h>

#define LocalizedStringByAppendingString(key,sufix) [LocalizedStringFromBundle(key, @"MediaLive") stringByAppendingString:sufix]
#define LOG_TAG @"NEW_PUSH_SCREEN"

@interface VELPushScreenCaptureNewViewController()<VeLiveSolutionScreenCaptureManagerDelegate, VeLivePusherObserver, VeLivePusherStatisticsObserver>
@property (nonatomic, strong) VeLiveSolutionScreenCaptureManager *screenCaptureManager;
@property (nonatomic) UIInterfaceOrientation orientation;
@property (nonatomic, strong) NSString *accompanimentIdentifier;
@property (nonatomic, strong) VeLivePusherStatistics *staticts;
@end

@implementation VELPushScreenCaptureNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_preview", @"MediaLive")];
}

- (void)setupEngine {
    VeLivePusherConfiguration *cfg = [[VeLivePusherConfiguration alloc] init];
    
    VeLiveAudioCaptureConfiguration *audioCaptureConfig = [[VeLiveAudioCaptureConfiguration alloc] init];
    cfg.audioCaptureConfig = audioCaptureConfig;
    
    self.screenCaptureManager = [[VeLiveSolutionScreenCaptureManager alloc]initWithApplicationGroupIdentifier:APP_GROUP_ID pusherConfig:cfg];
    self.screenCaptureManager.delegate = self;
    
    [self.screenCaptureManager.pusher setObserver:self];
    [self.screenCaptureManager.pusher setStatisticsObserver:self interval:1];
    [self.screenCaptureManager.pusher setEGLVersion:(int)self.config.glVersion];
}

- (void)destoryEngine {
    self.screenCaptureManager = nil;
}

- (void)muteAudio {
    [self.screenCaptureManager.pusher setMute:YES];
}
- (void)unMuteAudio {
    [self.screenCaptureManager.pusher setMute:NO];
}
- (void) checkAndRotation {
    if ([self.screenCaptureManager.pusher isPushing]) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_change_rotation", @"MediaLive") detailText:@""];
        return;
    }
    if (self.orientation == UIInterfaceOrientationUnknown || self.orientation == UIInterfaceOrientationPortrait) {
        [self.screenCaptureManager setOrientation:UIInterfaceOrientationLandscapeRight];
        self.orientation = UIInterfaceOrientationLandscapeRight;
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_landscape_push", @"MediaLive") detailText:@""];
    } else {
        [self.screenCaptureManager setOrientation:UIInterfaceOrientationPortrait];
        self.orientation = UIInterfaceOrientationPortrait;
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_portrait_push", @"MediaLive") detailText:@""];
    }
}

- (BOOL) isStreaming {
    return [self.screenCaptureManager.pusher isPushing] || self.streamStatus == VELStreamStatusConnecting || self.streamStatus == VELStreamStatusReconnecting || self.streamStatus == VELStreamStatusConnected;
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
    [self.screenCaptureManager startScreenCapture];
    if (self.config.enableFixScreenCaptureVideoAudioDiff) {
        [self.screenCaptureManager.pusher setProperty:@"VeLiveKeySetScreenCaptureVideoAudioDiff" value:@400];
    } else {
        [self.screenCaptureManager.pusher setProperty:@"VeLiveKeySetScreenCaptureVideoAudioDiff" value:@200];
    }
    VeLiveVideoEncoderConfiguration *videoEncodeConfig = [[VeLiveVideoEncoderConfiguration alloc] initWithResolution:(VeLiveVideoResolution)self.config.encodeResolutionType];
    videoEncodeConfig.fps = (int)self.config.encodeFPS;
    videoEncodeConfig.enableAccelerate = YES;
    [self.screenCaptureManager.pusher setVideoEncoderConfiguration:videoEncodeConfig];
    
    [VeLiveBroadcaseExtensionUILauncher launch:BROADCASE_EXTENSION_BUNDLE_ID];
}

- (void)exitStreaming {
    [self stopStreaming];
}

- (void)stopStreaming {
    [self.screenCaptureManager stopScreenCapture];
    [VELUIToast hideAllLoadingView];
    [self setStreamStatus:(VELStreamStatusNone) msg:nil];
}

- (void)onStatistics:(VeLivePusherStatistics *)statistics {
    self.staticts = statistics;
    NSString *info = [self getPushInfoString].string;
    [self updateCycleInfo:info append:NO];
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

- (NSString *)getNetworQualityDes:(VeLiveNetworkQuality)quality {
    switch (quality) {
        case VeLiveNetworkQualityUnknown : return @"Unknown";
        case VeLiveNetworkQualityBad : return @"Bad";
        case VeLiveNetworkQualityPoor : return @"Poor";
        case VeLiveNetworkQualityGood : return @"Good";
    }
    return @"Unknown";
}
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
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%@\n", LocalizedStringFromBundle(@"medialive_push_adress", @"MediaLive"),self.config.urls.firstObject)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d kbps", LocalizedStringFromBundle(@"medialive_video_max_bitrate", @"MediaLive"),(int)statistics.maxVideoBitrate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d kbps\n", LocalizedStringFromBundle(@"medialive_video_initial_bitrate", @"MediaLive"),(int)statistics.videoBitrate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d kbps", LocalizedStringFromBundle(@"medialive_video_min_bitrate", @"MediaLive"),(int)statistics.minVideoBitrate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d, %d \n", LocalizedStringFromBundle(@"medialive_video_capture_resolution", @"MediaLive"),(int)statistics.captureWidth, (int)statistics.captureHeight)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d, %d ", LocalizedStringFromBundle(@"medialive_video_push_resolution", @"MediaLive"),(int)statistics.encodeWidth, (int)statistics.encodeHeight)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d \n", LocalizedStringFromBundle(@"medialive_video_capture_fps", @"MediaLive"),(int)statistics.captureFps)];
    
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d/%d", LocalizedStringFromBundle(@"medialive_video_capture_io_fps", @"MediaLive"),(int)statistics.captureFps, (int)statistics.encodeFps)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%@ \n", LocalizedStringFromBundle(@"medialive_video_encode_format", @"MediaLive"),statistics.codec)];
    
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d \n", LocalizedStringFromBundle(@"medialive_real_time_transport_fps", @"MediaLive"),(int)statistics.transportFps)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d kbps",LocalizedStringFromBundle(@"medialive_real_time_encode_bitrate", @"MediaLive"), (int)statistics.encodeVideoBitrate)];
    [attributedString appendAttributedString:VEL_PUSH_CONTENT(@"%@:%d kbps\n",LocalizedStringFromBundle(@"medialive_real_time_transport_bitrate", @"MediaLive"), (int)statistics.transportVideoBitrate)];
    return attributedString;
}

/// MARK: - VeLivePusherObserver
- (void)onError:(int)code subcode:(int)subcode message:(nullable NSString *)msg {
    NSString *info = [NSString stringWithFormat:@"%@-(%d-%d)", msg, code, subcode];
    [self updateCallBackInfo:info append:YES];
    vel_sync_main_queue(^{
        [VELUIToast showText:@"%@", info];
        [self setStreamStatus:(VELStreamStatusError) msg:msg];
    });
}
- (void)onStatusChange:(VeLivePushStatus)status {
    NSString *info = [NSString stringWithFormat:@"%@：%@",LocalizedStringFromBundle(@"medialive_push_status", @"MediaLive") ,[self getStreamStatusDes:status]];
    [self updateCallBackInfo:info append:YES];
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
                    msg = LocalizedStringFromBundle(@"medialive_push_screen_status_error", @"MediaLive");
                    [self setStreamStatus:(VELStreamStatusError) msg:msg];
                    [self.screenCaptureManager stopScreenCapture];
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

- (float)getCurrentAudioLoudness {
    return [self.screenCaptureManager.pusher.getAudioDevice getVoiceLoudness];
}
- (float)getCurrentAppAudioLoudness {
    return self.screenCaptureManager.appAudioVolumn;
}
- (void)setAppAudioLoudness:(float)loudness {
    self.screenCaptureManager.appAudioVolumn = loudness;
}

- (void)setEnableAudioHardwareEcho:(BOOL)enable {
    if (self.screenCaptureManager.pusher.getAudioDevice.isSupportHardwareEcho) {
        [self.screenCaptureManager.pusher.getAudioDevice enableEcho:enable];
    }
}

- (BOOL)isHardwareEchoEnable {
    return [self.screenCaptureManager.pusher.getAudioDevice isEnableEcho];
}

- (void)setAudioLoudness:(float)loudness {
    [self.screenCaptureManager.pusher.getAudioDevice setVoiceLoudness:loudness];
}

- (void)onFirstVideoFrame:(VeLiveFirstFrameType)type timestampMs:(int64_t)timestampMs {
    
}

#pragma -- mark screen capture delegate

- (void)broadcastStarted {
    [self.screenCaptureManager.pusher startPush:self.config.urls.firstObject];
    [self setStreamStatus:(VELStreamStatusConnected) msg:LocalizedStringFromBundle(@"medialive_push_screen_success", @"MediaLive")];
}

- (void)broadcastPaused {
    
}

- (void)broadcastResumed {
    
}

- (void)broadcastFinishedBegin {

}

- (void)broadcastFinishedEnd {
    [self setStreamStatus:(VELStreamStatusStop) msg:LocalizedStringFromBundle(@"medialive_push_finish", @"MediaLive")];
}

@end
