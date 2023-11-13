// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoPlayerController+Strategy.h"
#import <TTSDK/TTVideoEngine+Strategy.h>
#import <objc/message.h>
#import "VEVideoCache.h"

@implementation VEVideoPlayerController (Strategy)

- (void)setPreloadOpen:(BOOL)preloadOpen {
    objc_setAssociatedObject(self, @selector(preloadOpen), @(preloadOpen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)preloadOpen {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

- (void)setPreRenderOpen:(BOOL)preRenderOpen {
    objc_setAssociatedObject(self, @selector(preRenderOpen), @(preRenderOpen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)preRenderOpen {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

+ (BOOL)enableEngineStrategy:(TTVideoEngineStrategyType)strategyType scene:(NSString *)scene {
    return [TTVideoEngine enableEngineStrategy:strategyType scene:scene];
}

+ (void)setStrategyVideoSources:(NSArray<id<TTVideoEngineMediaSource>> *)videoSources {
    [TTVideoEngine setStrategyVideoSources:videoSources];
}

+ (void)addStrategyVideoSources:(NSArray<id<TTVideoEngineMediaSource>> *)videoSources {
    [TTVideoEngine addStrategyVideoSources:videoSources];
}

+ (void)clearAllEngineStrategy {
    [TTVideoEngine clearAllEngineStrategy];
}

+ (void)preloadVideoSource:(id<TTVideoEngineMediaSource>)videoSource {
    TTVideoEnginePreloaderVidItem *item = [TTVideoEnginePreloaderVidItem vidItemWithVideoSource:videoSource preloadSize:800 * 1024];
    item.fetchDataEnd = ^(TTVideoEngineModel * _Nullable model, NSError * _Nullable error) {
        // get video model end
        if (model != nil) {
            [self addStrategyVideoModel:model forSource:videoSource];
        }
    };
    [TTVideoEngine ls_addTaskWithVidItem:item];
}

+ (void)cancelPreloadVideoSources {
    [TTVideoEngine ls_cancelAllTasks];
}

+ (void)addStrategyVideoModel:(TTVideoEngineModel *)videoModel forSource:(id<TTVideoEngineMediaSource>)videoSource {
    if ([videoSource isKindOfClass:[TTVideoEngineVidSource class]]) {
        TTVideoEngineVidSource *source = videoSource;
        [[VEVideoCache shared] setVideo:videoModel forKey:source.vid];
    }
}

+ (void)clearAllVideoModelStrategy {
    [[VEVideoCache shared] removeAllVideos];
}

- (void)loadStrategyVideoModel {
    if (![self.mediaSource isKindOfClass:[TTVideoEngineVidSource class]]) {
        return;
    }
    TTVideoEngineVidSource *source = (TTVideoEngineVidSource *)self.mediaSource;
    TTVideoEngineModel *videoModel = [[VEVideoCache shared] videoForKey:source.vid];
    if (videoModel) {
        [self.videoEngine setVideoModel:videoModel];
    }
}

@end
