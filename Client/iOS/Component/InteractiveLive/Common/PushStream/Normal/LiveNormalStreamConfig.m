// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveNormalStreamConfig.h"
#import "LiveSettingVideoConfig.h"

@implementation LiveNormalStreamConfig

+ (instancetype)defaultConfig {
    LiveNormalStreamConfig *config = [[LiveNormalStreamConfig alloc] init];
    LiveSettingVideoConfig *setting = [LiveSettingVideoConfig defultVideoConfig];
    config.videoFPS = setting.fps;
    config.outputSize = setting.videoSize;
    config.bitrate = setting.bitrate * 1000;
    config.maxBitrate = setting.maxBitrate * 1000;
    ;
    config.minBitrate = setting.minBitrate * 1000;
    ;
    return config;
}

@end
