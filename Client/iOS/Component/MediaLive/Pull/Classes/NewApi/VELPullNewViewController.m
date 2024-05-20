// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullNewViewController.h"
#import <MediaLive/VELCore.h>
#import "VELAudioRender.h"
#import <ToolKit/Localizator.h>
#define LOG_TAG @"PULL_NEW"
@interface VELPullUrlConfig (VELHelper)
@property (nonatomic, assign, readonly) VeLivePlayerFormat veliveFormat;
@property (nonatomic, assign, readonly) VeLivePlayerProtocol veliveProtocol;
@property (nonatomic, assign, readonly) VeLivePlayerStreamType veliveStreamType;
@property (nonatomic, assign, readonly) VeLivePlayerResolution veliveResolution;
+ (VeLivePlayerFormat)getVeLiveFormat:(VELPullUrlFormat)format;
+ (VeLivePlayerProtocol)getVeLiveProtocol:(VELPullUrlProtocol)protocol;
+ (VeLivePlayerResolution)veLiveResolutionFor:(VELPullResolutionType)resolution;
+ (VELPullResolutionType)velResolutionForVeLiveType:(VeLivePlayerResolution)resolution;
+ (NSString *)veLiveResolutionDes:(VeLivePlayerResolution)resolution;
+ (NSString *)veLiveStreamTypeDes:(VeLivePlayerStreamType)streamType;
@end
@interface VELPullABRUrlConfig (VELHelper)
@end

@interface VELPullNewViewController () <VeLivePlayerObserver, TVLSettingsManagerDataSource>
@property (nonatomic, strong) VeLivePlayerStreamData *streamData;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *lastStallDate;
@property (nonatomic, assign, getter=isManualSwitchResolution) BOOL manualSwitchResolution;
@property (nonatomic, assign, getter=isDisableAutoABR) BOOL disableAutoABR;
@property (nonatomic, assign) VELPullResolutionType manualResolution;
@property (nonatomic, assign) VELPullResolutionType lastManualResolution;
@property (nonatomic, assign) VELPullResolutionType abrResolution;
@property (nonatomic, assign) BOOL isManualChangeUrl;
@property (nonatomic, strong) CALayer *videoDisplayLayer;
@property (nonatomic, assign) int videoFps;
@property (nonatomic, strong) VELFileWritter *videoCallBackWriter;
@property (nonatomic, strong) VELFileWritter *audioCallBackWriter;
@property (nonatomic, strong) VELAudioRender *audioRender;
@property (nonatomic, strong) NSMutableArray <VeLivePlayerStream *> *mainStreams;
@end

@implementation VELPullNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoFps = 15;
    [self setupPlayer];
    if (self.autoPlayWhenLoaded || self.isPreLoading) {
        [self playInternal];
    }
}

- (void)dealloc {
}

- (void)applicationDidBecomeActive {
    if (!self.config.ignoreOpenglActivity) {
        [TVLManager startOpenGLESActivity];
    }
    if (!self.isFirstAppear && !self.isManualPaused) {
        [self.playerManager play];
    }
}

- (void)applicationWillResignActive {
    if (!self.config.ignoreOpenglActivity) {
        [TVLManager stopOpenGLESActivity];
    }
    if (!self.isManualPaused
        && !self.shouldPlayInBackground) {
        [self.playerManager stop];
    }
}
- (void)setupPlayer {
    if (!self.config.ignoreOpenglActivity) {
        [TVLManager startOpenGLESActivity];
    }
    if (self.playerManager == nil) {
        self.playerManager = [[TVLManager alloc] initWithOwnPlayer:YES];
    }
    if (self.playerManager == nil) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_licens_illegal", @"MediaLive") inView:self.playerContainer];
        return;
    }
    self.playerContainer.hidden = NO;
    self.playerManager.playerView.hidden = self.isPreLoading || self.isAutoHidePlayerView;
    
    VeLivePlayerConfiguration *config = [[VeLivePlayerConfiguration alloc] init];
    config.enableSei = self.config.enableSEI;
    config.enableStatisticsCallback = YES;
    [self.playerManager setConfig:config];
    [self.playerManager setPlayerViewRenderType:(TVLPlayerViewRenderTypeMetal)];
    [self.playerManager setObserver:self];
    [self.playerManager setProjectKey:[NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleName"]];
    self.playerManager.playerView.frame = self.playerContainer.bounds;
    [self.playerContainer addSubview:self.playerManager.playerView];
    [self.playerManager.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playerContainer);
    }];
}

- (void)destroyPlayer {
    [self.audioRender stop];
    [self.playerManager destroy];
    self.playerManager = nil;
}

- (BOOL)isPlaying {
    return self.playerManager.isPlaying;
}

- (void)clearState {
    self.isManualChangeUrl = NO;
    self.manualResolution = VELPullResolutionTypeOrigin;
    self.lastManualResolution = VELPullResolutionTypeOrigin;
    self.manualSwitchResolution = NO;
    self.abrResolution = VELPullResolutionTypeOrigin;
}

- (void)playWithNetworkReachable {
    if (self.isManualPaused && self.playerManager != nil) {
        return;
    }
    VELLogDebug(LOG_TAG, LocalizedStringFromBundle(@"medialive_newwork_resume", @"MediaLive"));
    [self play];
}

- (void)preload {
    self.preloading = YES;
    [self playInternal];
}

- (void)play {
    self.manualPaused = NO;
    if (self.isPreLoading) {
        self.preloading = NO;
        [self resume];
    } else {
        [self playInternal];
    }
}

- (void)playInternal {
    if (self.playerManager == nil || self.streamData != nil) {
        return;
    }

    if (!self.isManualChangeUrl) {
        self.mainStreams = [NSMutableArray arrayWithCapacity:5];
        VeLivePlayerStreamData *streamData = [[VeLivePlayerStreamData alloc] init];
        streamData.enableABR = self.config.enableABR && self.config.enableAutoResolutionDegrade;
        self.streamData = streamData;
        streamData.defaultFormat = [VELPullUrlConfig getVeLiveFormat:self.config.suggestFormat];
        streamData.defaultProtocol = [VELPullUrlConfig getVeLiveProtocol:self.config.suggestProtocol];
        if (self.config.mainUrlConfig.enableABR) {
            [self.config.mainUrlConfig.abrUrlConfigs enumerateObjectsUsingBlock:^(VELPullABRUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self appendStreamTo:streamData urlConfig:obj];
                if (obj.isDefault) {
                    self.abrResolution = obj.resolution;
                    [self setupDefaultStream:streamData withUrlConfig:obj];
                }
            }];
        } else {
            [self appendStreamTo:streamData urlConfig:self.config.mainUrlConfig];
            [self appendRTMBackUpFlvIfNeed:streamData urlConfig:self.config.mainUrlConfig];
            [self setupDefaultStream:streamData withUrlConfig:self.config.mainUrlConfig];
        }
        
        streamData.mainStream = self.mainStreams;
        [self.playerManager setPlayStreamData:streamData];
        VELLogDebug(LOG_TAG, @"PlayConfig: %@", [self.config yy_modelToJSONString]);
    }
    [self.playerManager setMute:self.isPreLoading];
    self.playerManager.playerView.hidden = self.isPreLoading || self.isAutoHidePlayerView;
    [self.playerManager play];
    self.startDate = [NSDate date];
    self.currentVolume = self.volumeSlider.value;
}

- (void)setupDefaultStream:(VeLivePlayerStreamData *)streamData withUrlConfig:(VELPullUrlConfig *)obj {
    streamData.defaultResolution = obj.veliveResolution;
    NSArray <VELPullUrlConfig *> * mutableFmtCfgs = obj.mutableFmtConfigs;
    __block VELPullUrlConfig *defaultObj = obj;
    if (mutableFmtCfgs != nil) {
        defaultObj = mutableFmtCfgs.firstObject;
        [mutableFmtCfgs enumerateObjectsUsingBlock:^(VELPullUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isSupportRTM) {
                defaultObj = obj;
                *stop = YES;
            } else if (obj.enableQuic && obj.isSupportQuic) {
                defaultObj = obj;
                *stop = YES;
            }
        }];
    }
    if (defaultObj != obj) {
        if ([defaultObj isSupportRTM]) {
            [VELUIToast showText:LocalizedStringFromBundle(@"medialive_default_rtm", @"MediaLive") inView:self.playerContainer];
        } else if (defaultObj.enableQuic && [defaultObj isSupportQuic]) {
            [VELUIToast showText:LocalizedStringFromBundle(@"medialive_default_quic", @"MediaLive") inView:self.playerContainer];
        } else {
            [VELUIToast showText:[NSString stringWithFormat:LocalizedStringFromBundle(@"medialive_choose_pull_address", @"MediaLive"), [self getFormatDes:defaultObj.veliveFormat]] inView:self.playerContainer];
        }
    }
    streamData.defaultFormat = defaultObj.veliveFormat;
    streamData.defaultProtocol = defaultObj.veliveProtocol;
}

- (void)appendStreamTo:(VeLivePlayerStreamData *)streamData urlConfig:(VELPullUrlConfig *)obj {
    if (obj.mutableFmtConfigs != nil) {
        [obj.mutableFmtConfigs enumerateObjectsUsingBlock:^(VELPullUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self appendStreamTo:streamData urlConfig:obj];
        }];
        return;
    }
    VeLivePlayerStream *stream = [[VeLivePlayerStream alloc] init];
    stream.url = obj.ipHostUrl;
    stream.resolution = obj.veliveResolution;
    if (obj.bitrate > 1) {
        stream.bitrate = (int)obj.bitrate * 1000;
    }
    stream.protocol = obj.veliveProtocol;
    stream.format = obj.veliveFormat;
    stream.type = obj.veliveStreamType;
    
    if (obj.veliveStreamType == VeLivePlayerStreamTypeMain) {
        [self.mainStreams addObject:stream];
    }
}

- (void)appendRTMBackUpFlvIfNeed:(VeLivePlayerStreamData *)streamData urlConfig:(VELPullUrlConfig *)urlConfig {
    if (self.config.mainUrlConfig.mutableFmtConfigs.count > 1) {
        VELLogDebug(LOG_TAG, LocalizedStringFromBundle(@"medialive_multiple_url", @"MediaLive"));
        return;
    }
    if (!urlConfig.isSupportRTM) {
        VELLogDebug(LOG_TAG, LocalizedStringFromBundle(@"medialive_not_rtm", @"MediaLive"));
        return;
    }
}

- (void)pause {
    self.manualPaused = YES;
    [self.playerManager pause];
}

- (void)resume {
    self.manualPaused = NO;
    [self.playerManager play];
}

- (void)stop {
    self.streamData = nil;
    [self.playerManager stop];
    [self updateCycleInfo:self.isPlaying ? LocalizedStringFromBundle(@"medialive_isplay_yes", @"MediaLive") : LocalizedStringFromBundle(@"medialive_isplay_no", @"MediaLive") append:NO];
}
- (void)startPlayInBackground {
    self.shouldPlayInBackground = YES;
}

- (void)stopPlayInBackground {
    self.shouldPlayInBackground = NO;
}

- (BOOL)resolutionShouldChanged:(VELPullResolutionType)fromResolution to:(VELPullResolutionType)toResolution {
    if (!self.config.urlConfig.enableABR) {
        return NO;
    }
    
    __block BOOL support = NO;
    [self.config.urlConfig.abrUrlConfigs enumerateObjectsUsingBlock:^(VELPullABRUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.resolution == toResolution) {
            support = YES;
            *stop = YES;
        }
    }];
    return support;
}

- (void)resolutionDidChanged:(VELPullResolutionType)fromResolution to:(VELPullResolutionType)toResolution {
    [VELUIToast showLoading:LocalizedStringFromBundle(@"medialive_gear_switching", @"MediaLive") inView:self.playerContainer];
    self.manualSwitchResolution = YES;
    self.disableAutoABR = YES;
    [self changePlayerResolutionFrom:fromResolution to:toResolution];
}

- (void)changePlayerResolutionFrom:(VELPullResolutionType)fromResolution to:(VELPullResolutionType)toResolution {
    self.startDate = [NSDate date];
    self.lastManualResolution = fromResolution;
    self.manualResolution = toResolution;
    [self.playerManager switchResolution:[VELPullUrlConfig veLiveResolutionFor:toResolution]];
}

- (NSArray<NSNumber *> *)getCurrentSupportResolutions {
    return [self.config getSupportResolutions];
}

- (VELPullResolutionType)getCurrentResolution {
    if (self.isManualSwitchResolution) {
        return self.manualResolution;
    }

    if (self.config.urlConfig.enableABR && !self.isDisableAutoABR) {
        return self.abrResolution;
    }
    
    TVLMediaResolutionType resolution = self.playerManager.currentItem.preferences.resolutionType;
    if ([resolution isEqualToString:TVLMediaResolutionTypeOrigin]) {
        return VELPullResolutionTypeOrigin;
    } else if ([resolution isEqualToString:TVLMediaResolutionTypeUHD]) {
        return VELPullResolutionTypeUHD;
    } else if ([resolution isEqualToString:TVLMediaResolutionTypeHD]) {
        return VELPullResolutionTypeHD;
    } else if ([resolution isEqualToString:TVLMediaResolutionTypeLD]) {
        return VELPullResolutionTypeLD;
    } else if ([resolution isEqualToString:TVLMediaResolutionTypeSD]) {
        return VELPullResolutionTypeSD;
    } else if ([resolution isEqualToString:TVLMediaResolutionTypeAuto]) {
        return self.abrResolution;
    }
    return VELPullResolutionTypeOrigin;
}

- (void)openHDR {
    [self.playerManager setOptionValue:@(1) forIdentifier:@(TVLPlayerOptionEnableHDR10)];
    [self.playerManager setOptionValue:@(1) forIdentifier:@(TVLPlayerOptionPreferSpdlForHDR)];
}

- (void)closeHDR {
    [self.playerManager setOptionValue:@(0) forIdentifier:@(TVLPlayerOptionEnableHDR10)];
    [self.playerManager setOptionValue:@(0) forIdentifier:@(TVLPlayerOptionPreferSpdlForHDR)];
}

- (BOOL)isSupportHDR {
    TVLPlayerItemPreferences *preferences = self.playerManager.currentItem.preferences;
    return [preferences.DRType isEqualToString:TVLMediaDRTypeHDR];
}

- (void)snapshot {
    int ret = [self.playerManager snapshot];
    if (ret != 0) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_can_not_snapshot", @"MediaLive") inView:self.playerContainer];
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [VELUIToast hideAllToast];
    if (error == nil) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_snapshot_saved", @"MediaLive") inView:self.playerContainer];
    } else {
        [VELUIToast showText:[NSString stringWithFormat:@"%@ %@",LocalizedStringFromBundle(@"medialive_snapshot_save_failed", @"MediaLive") ,error.localizedDescription] inView:self.playerContainer];
    }
}

- (void)mute {
    [self.playerManager setMute:YES];
}

- (void)unMute {
    [self.playerManager setMute:NO];
}

- (void)changeVolume:(float)volume {
    self.playerManager.volume = volume;
}

- (float)currentVolume {
    return self.playerManager.volume;
}

/// MARK: - VeLivePlayerObsever
- (NSString *)getErrorCodeDes:(VeLivePlayerErrorCode)code {
    switch (code) {
        case VeLivePlayerNoError: return @"NoError";
        case VeLivePlayerInvalidLicense: return @"InvalidLicense";
        case VeLivePlayerInvalidParameter: return @"InvalidParameter";
        case VeLivePlayerErrorRefused: return @"Refused";
        case VeLivePlayerErrorLibraryLoadFailed: return @"LibraryLoadFailed";
        case VeLivePlayerErrorPlayUrl: return @"PlayUrl";
        case VeLivePlayerErrorNoStreamData: return @"NoStreamData";
        case VeLivePlayerErrorInternalRetryStart: return @"InternalRetryStart";
        case VeLivePlayerErrorInternalRetryFailed: return @"InternalRetryFailed";
        case VeLivePlayerErrorDnsParseFailed: return @"DnsParseFailed";
        case VeLivePlayerErrorNetworkRequestFailed: return @"NetworkRequestFailed";
        case VeLivePlayerErrorDemuxFailed: return @"DemuxFailed";
        case VeLivePlayerErrorDecodeFailed: return @"DecodeFailed";
        case VeLivePlayerErrorAVOutputFailed: return @"AVOutputFailed";
        case VeLivePlayerErrorSRDeviceUnsupported: return @"SRDeviceUnsupported";
        case VeLivePlayerErrorSRResolutionUnsupported: return @"SRResolutionUnsupported";
        case VeLivePlayerErrorSRFpsUnsupported: return @"SRFpsUnsupported";
        case VeLivePlayerErrorSRInitFail: return @"SRInitFail";
        case VeLivePlayerErrorSRExecuteFail: return @"SRExecuteFail";
        case VeLivePlayerErrorInternal: return @"Internal";
        case VeLivePlayerLicenseUnsupportedH265: return @"LicenseNotSupportH265";
        default:
            return @"UnKnown";
    }
    return @"UnKnown";
}

- (void)onError:(TVLManager *)player error:(VeLivePlayerError *)error {
    [VELUIToast hideAllLoadingView];
    NSString *msg = [NSString stringWithFormat:@"%@: VeLivePlayerError%@ - %d", LocalizedStringFromBundle(@"medialive_toast_error", @"MediaLive"),[self getErrorCodeDes:error.errorCode], (int)error.errorCode];
    if (error.code != VeLivePlayerErrorInternalRetryStart && error.code != VeLivePlayerErrorInternal) {
        [VELUIToast showText:msg inView:self.playerContainer];
    }
    [self updateCallBackInfo:msg append:YES];
    VELLogError(LOG_TAG, @"%@", msg);
}

- (void)onStatistics:(TVLManager *)player statistics:(VeLivePlayerStatistics *)statistics {
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendFormat:@"%@：%@\n", LocalizedStringFromBundle(@"medialive_play_address", @"MediaLive"),statistics.url];
    [str appendFormat:@"%@: %d        ", LocalizedStringFromBundle(@"medialive_paly_width", @"MediaLive"),statistics.width];
    [str appendFormat:@"%@: %d\n", LocalizedStringFromBundle(@"medialive_paly_height", @"MediaLive"),statistics.height];
    
    [str appendFormat:@"%@: %.2f      ", LocalizedStringFromBundle(@"medialive_play_fps", @"MediaLive"),statistics.fps];
    [str appendFormat:@"%@: %ld kbps\n", LocalizedStringFromBundle(@"medialive_play_bitrate", @"MediaLive"),statistics.bitrate];
    
    if (statistics.videoBufferMs > 0) {
        [str appendFormat:@"%@: %ld ms  ", LocalizedStringFromBundle(@"medialive_play_cache_time", @"MediaLive"),statistics.videoBufferMs];
    }
    
    if (statistics.audioBufferMs > 0) {
        [str appendFormat:@"%@: %ld ms\n", LocalizedStringFromBundle(@"medialive_play_audio_cache_time", @"MediaLive"),statistics.audioBufferMs];
    }
    
    [str appendFormat:@"%@: %@       ", LocalizedStringFromBundle(@"medialive_stream_format", @"MediaLive"),[self getFormatDes:statistics.format]];
    [str appendFormat:@"%@: %@\n", LocalizedStringFromBundle(@"medialive_stream_protocol", @"MediaLive"),[self getProtocolDes:statistics.protocol]];
    
    [str appendFormat:@"%@: %@  \n",  LocalizedStringFromBundle(@"medialive_play_codec", @"MediaLive"),statistics.videoCodec ?: @"UnKnown"];
    
    [str appendFormat:@"%@: %d ms   ", LocalizedStringFromBundle(@"medialive_play_delay", @"MediaLive"),(int)statistics.delayMs];
    [str appendFormat:@"%@: %d ms\n", LocalizedStringFromBundle(@"medialive_play_stall", @"MediaLive"),(int)statistics.stallTimeMs];
    [str appendString: player.isPlaying ? LocalizedStringFromBundle(@"medialive_isplay_yes", @"MediaLive") : LocalizedStringFromBundle(@"medialive_isplay_no", @"MediaLive")];
    [str appendString:player.isMute ?  LocalizedStringFromBundle(@"medialive_ismuse_yes", @"MediaLive") : LocalizedStringFromBundle(@"medialive_ismuse_no", @"MediaLive")];
    [str appendString:statistics.isHardWareDecode ?  LocalizedStringFromBundle(@"medialive_is_hardware_decode_yes", @"MediaLive") : LocalizedStringFromBundle(@"medialive_is_hardware_decode_no", @"MediaLive")];
    [self updateCycleInfo:str append:NO];
    self.videoFps = (int)statistics.fps;
    VELLogInfo(LOG_TAG, @"%@:\n %@",LocalizedStringFromBundle(@"medialive_cycle_info_callback", @"MediaLive") ,str);
}

- (void)onPlayerStatusUpdate:(TVLManager *)player status:(VeLivePlayerStatus)status {
    NSString *statusDes = @"UnKnown";
    switch (status) {
        case VeLivePlayerStatusPrepared: {
            statusDes = @"Prepared";
            self.startDate = [NSDate date];
        }
            break;
        case VeLivePlayerStatusPlaying: {
            statusDes = @"Playing";
        }
            break;
        case VeLivePlayerStatusPaused: {
            statusDes = @"Paused";
        }
            break;
        case VeLivePlayerStatusStopped: {
            statusDes = @"Stopped";
        }
            break;
        case VeLivePlayerStatusError: {
            statusDes = @"Error";
        }
            break;
    }
    NSString *info = [NSString stringWithFormat:@"%@: %@-%d", LocalizedStringFromBundle(@"medialive_player_status_change", @"MediaLive"),statusDes, (int)status];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    if (self.isManualChangeUrl && (status == VeLivePlayerStatusPlaying || status == VeLivePlayerStatusError)) {
        [VELUIToast hideAllLoadingView];
        if (status == VeLivePlayerStatusPlaying) {
            [VELUIToast showText:LocalizedStringFromBundle(@"medialive_switch_address_success", @"MediaLive") inView:self.playerContainer];
        } else if (status == VeLivePlayerStatusError) {
            [VELUIToast showText:LocalizedStringFromBundle(@"medialive_switch_address_failed", @"MediaLive") inView:self.playerContainer];
        }
        self.isManualChangeUrl = NO;
    }
    
    if (status == VeLivePlayerStatusPlaying
        || status == VeLivePlayerStatusError
        || status == VeLivePlayerStatusPaused) {
        [VELUIToast hideAllLoadingView];
    }
}

- (void)onFirstVideoFrameRender:(TVLManager *)player isFirstFrame:(BOOL)isFirstFrame {

    NSString *info = [NSString stringWithFormat:@"%@：%.2f ms", LocalizedStringFromBundle(@"medialive_first_vframe_render_time", @"MediaLive"),[[NSDate date] timeIntervalSinceDate:self.startDate] * 1000];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    if (self.isPreLoading) {
        [self.playerManager setMute:NO];
        [self pause];
    }
    vel_sync_main_queue(^{
        self.playerManager.playerView.hidden = NO;
    });
}

- (void)onFirstAudioFrameRender:(TVLManager *)player isFirstFrame:(BOOL)isFirstFrame {
    NSString *info = [NSString stringWithFormat:@"%@：%.2f ms",LocalizedStringFromBundle(@"medialive_first_aframe_render_time", @"MediaLive") ,[[NSDate date] timeIntervalSinceDate:self.startDate] * 1000];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
}

- (void)onStallStart:(TVLManager *)player {
    self.lastStallDate = [NSDate date];
    NSString *info = [NSString stringWithFormat:@"%@ %@", LocalizedStringFromBundle(@"medialive_stall_start", @"MediaLive"),[self.dateFormatter stringFromDate:self.lastStallDate]];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    [VELUIToast showLoading:info inView:self.playerContainer];
}

- (void)onStallEnd:(TVLManager *)player {
    [VELUIToast hideAllToast];
    NSTimeInterval time = [NSDate.date timeIntervalSinceDate:self.lastStallDate] * 1000;
    NSString *info = [NSString stringWithFormat:@"%@: %.2f ms", LocalizedStringFromBundle(@"medialive_stall_end", @"MediaLive"),time];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    [VELUIToast showText:info inView:self.playerContainer];
}

- (void)onVideoRenderStall:(TVLManager *)player stallTime:(int64_t)time {
    NSString *info = [NSString stringWithFormat:@"%@: %lld ms", LocalizedStringFromBundle(@"medialive_vrender_stall", @"MediaLive"),time];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    [VELUIToast showText:info inView:self.playerContainer];
}

- (void)onAudioRenderStall:(TVLManager *)player stallTime:(int64_t)time {
    NSString *info = [NSString stringWithFormat:@"%@: %lld ms", LocalizedStringFromBundle(@"medialive_arender_stall", @"MediaLive"),time];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    [VELUIToast showText:info inView:self.playerContainer];
}


- (void)onVideoSizeChanged:(TVLManager *)player width:(int)width height:(int)height {
    self.videoSize = CGSizeMake(width, height);
    NSString *info = [NSString stringWithFormat:@"%@：width:%d height:%d", LocalizedStringFromBundle(@"medialive_change_resolution", @"MediaLive"),width, height];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
    [VELUIToast showText:info inView:self.playerContainer];
    vel_async_main_queue(^{
        if (width > height) {
            [player setRenderFillMode:(VeLivePlayerFillModeAspectFit)];
        } else {
            [player setRenderFillMode:(VeLivePlayerFillModeAspectFill)];
        }        
    });
}

- (void)onSnapshotComplete:(TVLManager *)player image:(UIImage *)image {
    NSString *info = [NSString stringWithFormat:@"%@ -- %@", LocalizedStringFromBundle(@"medialive_snapshot_callback", @"MediaLive"),image];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@ -- %@", LocalizedStringFromBundle(@"medialive_snapshot_callback", @"MediaLive"),image);
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)onReceiveSeiMessage:(TVLManager *)player message:(NSString*)message {
    NSString *info = [NSString stringWithFormat:@"%@：%@",LocalizedStringFromBundle(@"medialive_receive_sei", @"MediaLive") ,message];
    [self updateCallBackInfo:info append:YES];
    VELLogDebug(LOG_TAG, @"%@", info);
}


- (void)onResolutionSwitch:(TVLManager *)player resolution:(VeLivePlayerResolution)resolution error:(VeLivePlayerError *)error reason:(VeLivePlayerResolutionSwitchReason)reason {
    vel_async_main_queue(^{
        [VELUIToast hideAllLoadingView];
        NSString *info = error.errorMsg?:@"";
        if (reason == VeLivePlayerResolutionSwitchByAuto) {
            if (error == nil) {
                self.abrResolution = [VELPullUrlConfig velResolutionForVeLiveType:resolution];
                self.manualResolution = [VELPullUrlConfig velResolutionForVeLiveType:resolution];
                info = [NSString stringWithFormat:@"%@: %@", LocalizedStringFromBundle(@"medialive_abr_switched_res", @"MediaLive"),[VELPullUrlConfig veLiveResolutionDes:resolution]];
                [self refreshCurrentResolution];
            } else {
                info = [NSString stringWithFormat:@"%@: %@", LocalizedStringFromBundle(@"medialive_abr_switch_fail", @"MediaLive"),error.errorMsg];
            }
        } else if (reason == VeLivePlayerResolutionSwitchByManual && self.isManualSwitchResolution) {
            if (error == nil) {
                self.abrResolution = [VELPullUrlConfig velResolutionForVeLiveType:resolution];
                self.manualResolution = [VELPullUrlConfig velResolutionForVeLiveType:resolution];
                if (self.isManualSwitchResolution) {
                    info = LocalizedStringFromBundle(@"medialive_switched_res", @"MediaLive");
                } else {
                    info = LocalizedStringFromBundle(@"medialive_resume_res", @"MediaLive");
                }
            } else {
                info = LocalizedStringFromBundle(@"medialive_switch_res_fail", @"MediaLive");
                if (!(self.lastManualResolution == VELPullResolutionTypeOrigin
                      && self.manualResolution == VELPullResolutionTypeOrigin)) {
                    [self changePlayerResolutionFrom:self.manualResolution to:self.lastManualResolution];
                    [self refreshCurrentResolution];
                }
            }
            [self refreshCurrentResolution];
            self.manualSwitchResolution = NO;
        }
        [self updateCallBackInfo:info append:YES];
        VELLogDebug(LOG_TAG, @"%@", info);
        [VELUIToast showText:info inView:self.playerContainer];
    });
}

- (NSString *)getProtocolDes:(VeLivePlayerProtocol)protocol {
   switch (protocol) {
       case VeLivePlayerProtocolTCP: return @"TCP";
       case VeLivePlayerProtocolQUIC: return @"QUIC";
       case VeLivePlayerProtocolTLS: return @"TLS";
   }
   return @"UnKnown";
}
- (NSString *)getFormatDes:(VeLivePlayerFormat)format {
   switch (format) {
       case VeLivePlayerFormatFLV : return @"FLV";
       case VeLivePlayerFormatHLS : return @"HLS";
       case VeLivePlayerFormatRTM : return @"RTM";
   }
   return @"UnKnown";
}
@end

@implementation VELPullUrlConfig (VELHelper)
+ (VeLivePlayerFormat)getVeLiveFormat:(VELPullUrlFormat)format {
    if (format == VELPullUrlFormatRTM) {
        return VeLivePlayerFormatRTM;
    } else if (format == VELPullUrlFormatHLS) {
        return VeLivePlayerFormatHLS;
    } else if (format == VELPullUrlFormatFLV) {
        return VeLivePlayerFormatFLV;
    }
    return VeLivePlayerFormatFLV;
}

- (VeLivePlayerFormat)veliveFormat {
    return [[self class] getVeLiveFormat:self.format];
}

+ (VeLivePlayerProtocol)getVeLiveProtocol:(VELPullUrlProtocol)protocol {
    switch (protocol) {
        case VELPullUrlProtocolUnKnown:
        case VELPullUrlProtocolTCP:
            return VeLivePlayerProtocolTCP;
        case VELPullUrlProtocolQuic: return VeLivePlayerProtocolQUIC;
        case VELPullUrlProtocolTLS: return VeLivePlayerProtocolTLS;
    }
    return VeLivePlayerProtocolTCP;
}

- (VeLivePlayerProtocol)veliveProtocol {
    return [[self class] getVeLiveProtocol:self.protocol];
}

- (VeLivePlayerStreamType)veliveStreamType {
    if (self.urlType == VELPullUrlTypeMain) {
        return VeLivePlayerStreamTypeMain;
    }
    return VeLivePlayerStreamTypeBackup;
}

- (VeLivePlayerResolution)veliveResolution {
    return VeLivePlayerResolutionOrigin;
}
+ (VeLivePlayerResolution)veLiveResolutionFor:(VELPullResolutionType)resolution {
    switch (resolution) {
        case VELPullResolutionTypeOrigin: return VeLivePlayerResolutionOrigin;
        case VELPullResolutionTypeUHD: return VeLivePlayerResolutionUHD;
        case VELPullResolutionTypeHD: return VeLivePlayerResolutionHD;
        case VELPullResolutionTypeLD: return VeLivePlayerResolutionLD;
        case VELPullResolutionTypeSD: return VeLivePlayerResolutionSD;
    }
    return VeLivePlayerResolutionOrigin;
}

+ (VELPullResolutionType)velResolutionForVeLiveType:(VeLivePlayerResolution)resolution {
    switch (resolution) {
        case VeLivePlayerResolutionOrigin: return VELPullResolutionTypeOrigin;
        case VeLivePlayerResolutionUHD: return VELPullResolutionTypeUHD;
        case VeLivePlayerResolutionHD: return VELPullResolutionTypeHD;
        case VeLivePlayerResolutionLD: return VELPullResolutionTypeLD;
        case VeLivePlayerResolutionSD: return VELPullResolutionTypeSD;
    }
    return VELPullResolutionTypeOrigin;
}

+ (NSString *)veLiveResolutionDes:(VeLivePlayerResolution)resolution {
    switch (resolution) {
        case VeLivePlayerResolutionOrigin: return @"Origin";
        case VeLivePlayerResolutionUHD: return @"UHD";
        case VeLivePlayerResolutionHD: return @"HD";
        case VeLivePlayerResolutionLD: return @"LD";
        case VeLivePlayerResolutionSD: return @"SD";
    }
    return @"";
}

+ (NSString *)veLiveStreamTypeDes:(VeLivePlayerStreamType)streamType {
    switch (streamType) {
        case VeLivePlayerStreamTypeMain: return @"Main";
        default: break;
    }
    return @"UnKnown";
}
@end
@implementation VELPullABRUrlConfig (VELHelper)
- (VeLivePlayerResolution)veliveResolution {
    return [self.class veLiveResolutionFor:self.resolution];
}
@end

