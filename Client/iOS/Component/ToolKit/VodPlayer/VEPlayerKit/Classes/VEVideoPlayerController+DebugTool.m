// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoPlayerController+DebugTool.h"
#import <AppConfig/BuildConfig.h>
#import <RangersAppLog/RangersAppLog.h>
#import <objc/runtime.h>

@implementation VEVideoPlayerController (DebugTool)

- (void)showDebugViewInView:(UIView *)hudView {
    self.videoEngineDebugTool.videoEngine = self.videoEngine;
    [self.videoEngineDebugTool setDebugInfoView:hudView];
    self.videoEngineDebugTool.indexForSuperView = 0;
    [self.videoEngineDebugTool start];
}

- (void)removeDebugTool {
    [self.videoEngineDebugTool remove];
}

- (void)setVideoEngineDebugTool:(TTVideoEngineDebugTools *)videoEngineDebugTool {
    objc_setAssociatedObject(self, @selector(videoEngineDebugTool), videoEngineDebugTool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTVideoEngineDebugTools *)videoEngineDebugTool {
    TTVideoEngineDebugTools *debugTools = objc_getAssociatedObject(self, @selector(videoEngineDebugTool));
    if (debugTools == nil) {
        debugTools = [[TTVideoEngineDebugTools alloc] init];
        debugTools.debugToolsEnable = YES;
        [self setVideoEngineDebugTool:debugTools];
    }
    return debugTools;
}

+ (NSString *)deviceID {
    return [[BDAutoTrack trackWithAppID:VODAPPID] rangersDeviceID] ?: @"null";
}

@end
