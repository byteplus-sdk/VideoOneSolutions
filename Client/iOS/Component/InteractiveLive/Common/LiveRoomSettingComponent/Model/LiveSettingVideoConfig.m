// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveSettingVideoConfig.h"

@implementation LiveSettingVideoConfig

+ (instancetype)defaultVideoConfig {
    static LiveSettingVideoConfig *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });

    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.fpsType = LiveSettingVideoFpsType_15;
        self.resolutionType = LiveSettingVideoResolutionType_720P;
        self.bitrate = 1600;
    }
    return self;
}

- (CGSize)guestVideoSize {
    return CGSizeMake(256, 256);
}

- (void)setFpsType:(LiveSettingVideoFpsType)fpsType {
    _fpsType = fpsType;

    CGFloat fps = 0.0;
    switch (fpsType) {
        case LiveSettingVideoFpsType_15: {
            fps = 15.0;
        } break;
        case LiveSettingVideoFpsType_20: {
            fps = 20.0;
        } break;

        default: {
            fps = 15.0;
        } break;
    }
    self.fps = fps;
}

- (void)setResolutionType:(LiveSettingVideoResolutionType)resolutionType {
    _resolutionType = resolutionType;

    NSInteger minKbps = 0;
    NSInteger maxKbps = 0;
    NSInteger defultKbps = 0;
    CGSize videoSize = CGSizeZero;

    switch (resolutionType) {
        case LiveSettingVideoResolutionType_540P: {
            minKbps = 500;
            maxKbps = 1520;
            defultKbps = 1200;
            videoSize = CGSizeMake(540, 960);
        } break;
        case LiveSettingVideoResolutionType_720P: {
            minKbps = 800;
            maxKbps = 1900;
            defultKbps = 1600;
            videoSize = CGSizeMake(720, 1280);
        } break;
        case LiveSettingVideoResolutionType_1080P: {
            minKbps = 1000;
            maxKbps = 3800;
            defultKbps = 2800;
            videoSize = CGSizeMake(1080, 1920);
        } break;

        default:
            break;
    }

    if (self.bitrate == 0) {
        self.bitrate = defultKbps;
    }
    if (self.bitrate < minKbps) {
        self.bitrate = minKbps;
    }
    if (self.bitrate > maxKbps) {
        self.bitrate = maxKbps;
    }

    self.minBitrate = minKbps;
    self.maxBitrate = maxKbps;
    self.defaultBitrate = defultKbps;
    self.videoSize = videoSize;
}

- (NSDictionary *)resolutionDic {
    if (!_resolutionDic) {
        _resolutionDic = @{@(LiveSettingVideoResolutionType_540P): @"540p",
                           @(LiveSettingVideoResolutionType_720P): @"720p",
                           @(LiveSettingVideoResolutionType_1080P): @"1080p"};
    }
    return _resolutionDic;
}

@end
