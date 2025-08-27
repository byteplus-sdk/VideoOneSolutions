// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDVideoEnginePool.h"
#import "BTDMacros.h"
#import <TTSDKFramework/TTSDKFramework.h>

@interface MDVideoEnginePool ()

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMapTable<NSString *, TTVideoEngine *> *videoEngines;;

@end

@implementation MDVideoEnginePool

+ (MDVideoEnginePool *)shareInstance {
    static MDVideoEnginePool *enginePoolShareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (enginePoolShareInstance == nil) {
            enginePoolShareInstance = [[MDVideoEnginePool alloc] init];
        }
    });
    return enginePoolShareInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc] init];
        self.videoEngines = [NSMapTable weakToWeakObjectsMapTable];
    }
    return self;
}

- (void)createVideoEngine:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource needPrerenderEngine:(BOOL)needPrerender block:(MDEnginePoolBlock)block {
    [self.lock lock];
    if (mediaSource.uniqueId == nil || mediaSource.uniqueId.length == 0) {
        NSAssert(mediaSource.uniqueId, @"source uniqueId is nil");
        
        BTDLog(@"EnginePool: %@ ===== init video engine play", mediaSource.uniqueId);
        TTVideoEngine *videoEngine = [[TTVideoEngine alloc] init];
        [self.videoEngines setObject:videoEngine forKey:mediaSource.uniqueId];
        BTD_BLOCK_INVOKE(block, videoEngine, MDCreateEngineFrom_Init);
    } else {
        TTVideoEngine *prerenderVideoEngine = nil;
        if (needPrerender) {
            prerenderVideoEngine = [TTVideoEngine getPreRenderVideoEngineWithVideoSource:mediaSource];
        }
        if (prerenderVideoEngine) {
            BTDLog(@"EnginePool: %@ ===== use pre render video engine play", mediaSource.uniqueId);
            [self.videoEngines setObject:prerenderVideoEngine forKey:mediaSource.uniqueId];
            BTD_BLOCK_INVOKE(block, prerenderVideoEngine, MDCreateEngineFrom_Prerender);
        } else {
            TTVideoEngine *videoEngine = [self.videoEngines objectForKey:mediaSource.uniqueId];
            if (videoEngine == nil) {
                BTDLog(@"EnginePool: %@ ===== init video engine play", mediaSource.uniqueId);
                videoEngine = [[TTVideoEngine alloc] init];
                [self.videoEngines setObject:videoEngine forKey:mediaSource.uniqueId];
                BTD_BLOCK_INVOKE(block, videoEngine, MDCreateEngineFrom_Init);
                
            } else {
                BTDLog(@"EnginePool: %@ ===== use cahce video engine play", mediaSource.uniqueId);
                [self.videoEngines setObject:videoEngine forKey:mediaSource.uniqueId];
                BTD_BLOCK_INVOKE(block, videoEngine, MDCreateEngineFrom_Cache);
            }
        }
    }
    BTDLog(@"EnginePool: %@ ===== engine count %@", mediaSource.uniqueId, @(self.videoEngines.count));
    [self.lock unlock];
}

- (void)removeVideoEngine:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    [self.lock lock];
    if (mediaSource.uniqueId) {
        [self.videoEngines removeObjectForKey:mediaSource.uniqueId];
    }
    [self.lock unlock];
}

@end
