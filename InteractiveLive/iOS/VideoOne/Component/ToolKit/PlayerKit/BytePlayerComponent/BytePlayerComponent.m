// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "BytePlayerComponent.h"
#import <TTSDK/TTVideoLive.h>
#import <TTSDK/TTSDKManager.h>
#import <TTSDK/TTLiveURLComposer.h>
#import <TTSDK/TVLPlayerItem+TTSDK.h>
#import <Masonry/Masonry.h>
#import "LiveSettingData.h"

@interface BytePlayerComponent () <VeLivePlayerObserver>
@property (nonatomic, strong) TVLManager *player;
@property (nonatomic, copy) NSString *currentURLString;
@property (nonatomic, copy) NSString *currentRTMURLString;
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *urlMap;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *urlMapCache;
@property (nonatomic, copy) void (^SEIBlcok)(NSDictionary *SEIBlock);
@property (atomic, strong) NSDictionary *statisticsInfo;
@end

@implementation BytePlayerComponent

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        [self addObserver];
    }
    return self;
}

- (void)startWithConfiguration {
    [TVLManager startOpenGLESActivity];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [TVLManager startOpenGLESActivity];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [TVLManager stopOpenGLESActivity];
}

#pragma mark - Methods

- (void)configPlayerItem:(NSString *)defaultResolution {
    if ([LiveSettingData abr] || ![LiveSettingData rtmPullStreaming]) {
        [self.player setPlayStreamData:[self createPlayerStreamData:defaultResolution]];
    } else {
        [self.player replaceCurrentItemWithPlayerItem:[self createPlayerItem:defaultResolution]];
    }
}

- (void)setPlayWithUrlMap:(NSDictionary<NSString *,NSString *> *)urlMap
        defaultResolution:(NSString *)defaultResolution
               superView:(UIView *)superView
                SEIBlcok:(nonnull void (^)(NSDictionary * _Nonnull))SEIBlcok {
    _urlMap = urlMap;
    _urlMapCache = urlMap.mutableCopy;
    _SEIBlcok = SEIBlcok;
    [self configPlayerItem:defaultResolution];
    [superView addSubview:self.player.playerView];
    [self.player.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superView);
    }];
    self.player.playerView.backgroundColor = [UIColor clearColor];
}

- (void)updatePlayScaleMode:(PullScalingMode)scalingMode {
    switch (scalingMode) {
        case PullScalingModeNone:
            self.player.playerViewScaleMode = TVLViewScalingModeNone;
            break;
        case PullScalingModeAspectFit:
            self.player.playerViewScaleMode = TVLViewScalingModeAspectFit;
            break;
        case PullScalingModeAspectFill:
            self.player.playerViewScaleMode = TVLViewScalingModeAspectFill;
            break;
        case PullScalingModeFill:
            self.player.playerViewScaleMode = TVLViewScalingModeFill;
            break;
            
        default:
            self.player.playerViewScaleMode = TVLViewScalingModeNone;
            break;
    }
}

- (void)play {
    [self.player play];
}

- (void)replaceWithUrlMap:(NSDictionary <NSString *, NSString *> *)urlMap
        defaultResolution:(NSString *)defaultResolution {
    if ([_urlMap isEqualToDictionary:urlMap]
        && [LiveSettingData abr]
        && [_urlMap.allKeys containsObject:defaultResolution]) {
        [self.player switchResolution:[self getResolutionFromResolution:defaultResolution]];
    } else {
        _urlMap = urlMap;
        [self configPlayerItem:defaultResolution];
    }
}

- (void)stop {
    [self.player stop];
}

- (void)destroy {
    [self.player close];
    self.player = nil;
}

#pragma mark - Player Private Method
- (VeLivePlayerStream *)createStream:(NSString *)url {
    VeLivePlayerStream *stream = [[VeLivePlayerStream alloc] init];
    stream.url = url;
    stream.type = VeLivePlayerStreamTypeMain;
    stream.resolution = VeLivePlayerResolutionOrigin;
    NSURLComponents *urlComponts = [[NSURLComponents alloc] initWithString:url];
    if ([urlComponts.path hasSuffix:@".sdp"]) {
        stream.format = VeLivePlayerFormatRTM;
    } else if ([urlComponts.path hasSuffix:@".m3u8"]) {
        stream.format = VeLivePlayerFormatHLS;
    } else {
        stream.format = VeLivePlayerFormatFLV;
    }
    stream.protocol = [urlComponts.scheme isEqualToString:@"https"] ? VeLivePlayerProtocolTLS : VeLivePlayerProtocolTCP;
    return stream;
}

- (VeLivePlayerStreamData *)createPlayerStreamData:(NSString *)defaultResolution {
    NSString *originUrl = [self getOriginalUlr];
    NSString *url = _urlMap[defaultResolution] ?: originUrl;
    self.currentURLString = url;
    VeLivePlayerStreamData *streamData = [[VeLivePlayerStreamData alloc] init];
    __block VeLivePlayerStream *defaultStream = nil;
    if ([LiveSettingData abr]) {
        NSMutableArray <VeLivePlayerStream *> * streams = [NSMutableArray arrayWithCapacity:_urlMap.count];
        if (originUrl.length > 0) {
            VeLivePlayerStream *stream = [self createStream:originUrl];
            stream.resolution = [self getResolutionFromResolution:nil];
            stream.url = [self checkAppendfor:originUrl suffix:[self getStreamSuffixFor:nil]];
            stream.bitrate = (int)[self getStreamBitrateFor:nil];
            [streams addObject:stream];
        }
        [_urlMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:originUrl]) {
                return;
            }
            VeLivePlayerStream *stream = [self createStream:obj];
            stream.resolution = [self getResolutionFromResolution:key];
            stream.url = [self checkAppendfor:obj suffix:[self getStreamSuffixFor:key]];
            stream.bitrate = (int)[self getStreamBitrateFor:key];
            [streams addObject:stream];
            if ([key isEqualToString:defaultResolution]) {
                defaultStream = stream;
            }
        }];
        streamData.mainStream = streams;
    } else if ([LiveSettingData rtmPullStreaming]) {
        NSString *sdpUrl = [self changeToRTMUrl:originUrl];
        self.currentRTMURLString = sdpUrl;
        defaultStream = [self createStream:sdpUrl];
        streamData.mainStream = @[defaultStream, [self createStream:originUrl]];
    } else  {
        defaultStream = [self createStream:originUrl];
        streamData.mainStream = @[defaultStream];
    }
    
    streamData.defaultFormat = defaultStream.format;
    streamData.defaultResolution = defaultStream.resolution;
    streamData.defaultProtocol = defaultStream.protocol;
    return streamData;
}

- (TVLPlayerItem *)createPlayerItem:(NSString *)defaultResolution {
    NSString *originUrl = [self getOriginalUlr];
    NSString *url = _urlMap[defaultResolution] ?: originUrl;
    TTLiveURLComposer *composer = [[TTLiveURLComposer alloc] init];
    TVLPlayerItem *item = nil;
    if ([LiveSettingData rtmPullStreaming]) {
        NSString *sdpUrl = [self changeToRTMUrl:url];
        [composer addUrl:sdpUrl forFormat:TVLMediaFormatTypeLLS];
        [composer addUrl:url
           forResolution:TVLMediaResolutionTypeOrigin
                forCodec:TVLVideoCodecTypeH264
               forSource:TVLMediaSourceTypeMain
               forFormat:TVLMediaFormatTypeFLV];
        item = [TVLPlayerItem playerItemWithComposer:composer];
        for (TVLPlayerItemPreferences *preference in item.supportedPreferences) {
            if ([preference.formatType isEqualToString:TVLMediaFormatTypeLLS]) {
                item.preferences = preference;
                break;
            }
        }
    }
    if (item.preferences == nil) {
        for (TVLPlayerItemPreferences *preference in item.supportedPreferences) {
            if ([preference.sourceType isEqualToString:TVLMediaSourceTypeMain]) {
                item.preferences = preference;
                break;
            }
        }
    }
    if (item.preferences == nil) {
        item.preferences = item.supportedPreferences.firstObject;
    }
    return item;
}

- (VeLivePlayerResolution)getResolutionFromResolution:(NSString *)key {
    if (key != nil) {
        if ([key containsString:@"1080"]) {
            return VeLivePlayerResolutionUHD;
        } else if ([key containsString:@"720"]) {
            return VeLivePlayerResolutionHD;
        } else if ([key containsString:@"540"]) {
            return VeLivePlayerResolutionSD;
        } else if ([key containsString:@"480"]) {
            return VeLivePlayerResolutionLD;
        }
    }
    return VeLivePlayerResolutionOrigin;
}


- (NSInteger)getStreamBitrateFor:(NSString *)key {
    if (key != nil) {
        if ([key containsString:@"1080"]) {
            return 3200000;
        } else if ([key containsString:@"720"]) {
            return 2048000;
        } else if ([key containsString:@"540"]) {
            return 1638000;
        } else if ([key containsString:@"480"]) {
            return 1024000;
        }
    }
    return 5000000;
}

- (NSString *)getStreamSuffixFor:(NSString *)key {
    if (key != nil) {
        if ([key containsString:@"1080"]) {
            return @"_uhd";
        } else if ([key containsString:@"720"]) {
            return @"_hd";
        } else if ([key containsString:@"540"]) {
            return @"_sd";
        } else if ([key containsString:@"480"]) {
            return @"_ld";
        }
    }
    return @"";
}

- (NSString *)changeToRTMUrl:(NSString *)urlString {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:urlString];
    NSString *urlPath = urlComponents.path;
    if (urlPath.pathExtension.length <= 0) {
        urlPath = [urlPath stringByAppendingPathExtension:@"sdp"];
    } else {
        urlPath = [urlPath stringByReplacingOccurrencesOfString:urlPath.pathExtension withString:@"sdp"];
    }
    urlComponents.path = urlPath;
    if (![urlComponents.scheme hasPrefix:@"http"]) {
        urlComponents.scheme = @"http";
    }
    return urlComponents.URL.absoluteString;
}

/// 获取源流地址
- (NSString *)getOriginalUlr {
    __block NSString *originalUrl = [self.urlMap objectForKey:@"origin"];
    if (originalUrl == nil) {
        NSArray <NSString *>* resolutions = @[@"ld", @"sd", @"hd", @"uhd"];
        [self.urlMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            NSURLComponents *com = [[NSURLComponents alloc] initWithString:obj];
            NSString *lastPath = com.path.lastPathComponent.stringByDeletingPathExtension;
            NSString *resolutionTag = [lastPath componentsSeparatedByString:@"_"].lastObject;
            if (resolutionTag.length > 0 && [resolutions containsObject:resolutionTag]) {
                com.path = [com.path stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%@", resolutionTag] withString:@""];
                originalUrl = com.URL.absoluteString;
                *stop = YES;
            }
        }];
    }
    return originalUrl;
}

- (NSString *)checkAppendfor:(NSString *)urlString suffix:(NSString *)suffix {
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *path = [url lastPathComponent];
    if ([path containsString:suffix] || suffix.length < 1) {
        return urlString;
    }
    NSString *pathExt = [path pathExtension];
    path = [path stringByDeletingPathExtension];
    path = [path stringByAppendingString:suffix];
    if (pathExt.length > 0) {
        path = [path stringByAppendingFormat:@".%@", pathExt];
    }
    NSString *res = [urlString stringByReplacingOccurrencesOfString:url.lastPathComponent withString:path];
    [self.urlMapCache setObject:urlString forKey:suffix];
    return res;
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

#pragma mark - BytedPlayerDelegate

- (void)protocol:(BytedPlayerProtocol *)protocol setPlayWithUrlMap:(NSDictionary<NSString *,NSString *> *)urlMap defaultResolution:(NSString *)defaultResolution superView:(UIView *)superView SEIBlcok:(void (^)(NSDictionary * _Nonnull))SEIBlcok {
    [self setPlayWithUrlMap:urlMap defaultResolution:defaultResolution superView:superView SEIBlcok:SEIBlcok];
}

- (void)protocolDidPlay:(BytedPlayerProtocol *)protocol {
    [self play];
}

- (void)protocolDidStop:(BytedPlayerProtocol *)protocol {
    [self stop];
}

- (void)protocol:(BytedPlayerProtocol *)protocol updatePlayScaleMode:(PullScalingMode)scalingMode {
    [self updatePlayScaleMode:scalingMode];
}

- (void)protocol:(BytedPlayerProtocol *)protocol replaceWithUrlMap:(NSDictionary<NSString *,NSString *> *)urlMap defaultResolution:(NSString *)defaultResolution {
    [self replaceWithUrlMap:urlMap defaultResolution:defaultResolution];
}

- (BOOL)protocolIsSupportSEI {
    return YES;
}

- (void)protocolStartWithConfiguration {
    [self startWithConfiguration];
}

- (void)protocolDestroy:(BytedPlayerProtocol *)protocol {
    [self destroy];
}

- (NSDictionary *)protocolGetPlayInfo {
    return self.statisticsInfo.copy;
}

#pragma mark - TVLDelegate
- (void)onReceiveSeiMessage:(TVLManager *)player message:(NSString *)message {
    @try {
        NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData != nil) {
            NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            if ([obj isKindOfClass:NSDictionary.class] && _SEIBlcok) {
                _SEIBlcok(obj);
            }
        }
    } @catch (NSException *exception) {
        
    }
    
}

- (void)onStatistics:(TVLManager *)player statistics:(VeLivePlayerStatistics *)statistics {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    NSMutableString *str = [[NSMutableString alloc] initWithString:@"\n"];
    info[@"url"] = statistics.url;
    info[@"width"] = @(statistics.width);
    info[@"height"] = @(statistics.height);
    info[@"fps"] = @(statistics.fps);
    if (statistics.bitrate > 0) {
        info[@"bitrate"] = @(statistics.bitrate);
    }
    if (statistics.videoBufferMs >= 0) {
        info[@"videoBufferMs"] = @(statistics.videoBufferMs);
    }
    if (statistics.audioBufferMs >= 0) {
        info[@"audioBufferMs"] = @(statistics.audioBufferMs);
    }
    info[@"format"] = [self getFormatDes:statistics.format];
    info[@"protocol"] = [self getProtocolDes:statistics.protocol];
    if (![statistics.videoCodec isEqualToString:@"none"]) {
        info[@"videoCodec"] = statistics.videoCodec ?: @"UnKnown";
    }
    info[@"delayMs"] = @(statistics.delayMs);
    info[@"stallTimeMs"] = @(statistics.stallTimeMs);
    info[@"isPlaying"] = @(player.isPlaying);
    info[@"isMute"] = @(player.isMute);
    info[@"isHardWareDecode"] = @(statistics.isHardWareDecode);
    self.statisticsInfo = info;
}

- (void)onAudioRenderStall:(TVLManager *)player stallTime:(int64_t)stallTime {
}


- (void)onError:(TVLManager *)player error:(VeLivePlayerError *)error {
    NSLog(@"onPlayerError: %@", error.errorMsg);
}
- (void)onFirstAudioFrameRender:(TVLManager *)player isFirstFrame:(BOOL)isFirstFrame {
    
}
- (void)onFirstVideoFrameRender:(TVLManager *)player isFirstFrame:(BOOL)isFirstFrame {
}
- (void)onMainBackupSwitch:(TVLManager *)player streamType:(VeLivePlayerStreamType)streamType error:(VeLivePlayerError *)error {
}
- (void)onPlayerStatusUpdate:(TVLManager *)player status:(VeLivePlayerStatus)status {
}
- (void)onRenderAudioFrame:(TVLManager *)player audioFrame:(VeLivePlayerAudioFrame *)audioFrame {
}
- (void)onRenderVideoFrame:(TVLManager *)player videoFrame:(VeLivePlayerVideoFrame *)videoFrame {
}
- (void)onResolutionSwitch:(TVLManager *)player resolution:(VeLivePlayerResolution)resolution error:(VeLivePlayerError *)error reason:(VeLivePlayerResolutionSwitchReason)reason {
}
- (void)onSnapshotComplete:(TVLManager *)player image:(UIImage *)image {
}
- (void)onStallEnd:(TVLManager *)player {
}
- (void)onStallStart:(TVLManager *)player {
}
- (void)onVideoRenderStall:(TVLManager *)player stallTime:(int64_t)stallTime {
}
- (void)onVideoSizeChanged:(TVLManager *)player width:(int)width height:(int)height {
}


#pragma mark - Getter
- (TVLManager *)player {
    if (!_player) {
        _player = [[TVLManager alloc] initWithOwnPlayer:YES];
        [_player setPlayerViewRenderType:(TVLPlayerViewRenderTypeMetal)];
        [_player setProjectKey:@"VideoOne"];
        _player.observer = self;
        VeLivePlayerConfiguration *config = [[VeLivePlayerConfiguration alloc] init];
        config.enableSei = YES;
        config.enableHardwareDecode = YES;
        config.enableStatisticsCallback = YES;
        [_player setConfig:config];
        [TVLManager setLogCallback:^(TVLLogLevel level, NSString *tag, NSString *log){
            NSLog(@"LiveTTSDK setLogCallback %luu|%@",(unsigned long) (unsigned long)level, log);
        }];
    }
    return _player;
}

@end
