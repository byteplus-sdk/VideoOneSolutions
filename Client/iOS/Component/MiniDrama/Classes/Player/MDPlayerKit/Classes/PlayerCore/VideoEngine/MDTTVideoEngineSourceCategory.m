// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDTTVideoEngineSourceCategory.h"
#import <objc/message.h>

@implementation TTVideoEngineVidSource (MDVidSource)

#pragma mark - Setter && getter

- (void)setStartTime:(NSTimeInterval)startTime {
    objc_setAssociatedObject(self, @selector(startTime), @(startTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)startTime {
    return [objc_getAssociatedObject(self, @selector(startTime)) doubleValue];
}

- (void)setTitle:(NSString *)title {
    objc_setAssociatedObject(self, @selector(title), title, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)title {
    return objc_getAssociatedObject(self, @selector(title));
}

- (void)setCover:(NSString *)cover {
    objc_setAssociatedObject(self, @selector(cover), cover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)cover {
    return objc_getAssociatedObject(self, @selector(cover));
}

@end


@implementation TTVideoEngineUrlSource (MDUrlSource)

#pragma mark - Setter && getter

- (void)setStartTime:(NSTimeInterval)startTime {
    objc_setAssociatedObject(self, @selector(startTime), @(startTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)startTime {
    return [objc_getAssociatedObject(self, @selector(startTime)) doubleValue];
}

- (void)setTitle:(NSString *)title {
    objc_setAssociatedObject(self, @selector(title), title, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)title {
    return objc_getAssociatedObject(self, @selector(title));
}

- (void)setCover:(NSString *)cover {
    objc_setAssociatedObject(self, @selector(cover), cover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)cover {
    return objc_getAssociatedObject(self, @selector(cover));
}

@end

@implementation TTVideoEngineVideoModelSource (MDVideoModelSource)
- (void)setStartTime:(NSTimeInterval)startTime {
    objc_setAssociatedObject(self, @selector(startTime), @(startTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSTimeInterval)startTime {
    return [objc_getAssociatedObject(self, @selector(startTime)) doubleValue];
}
@end

NSTimeInterval MDSourceStartTime(id<TTVideoEngineMediaSource> source) {
    if ([source isKindOfClass:TTVideoEngineVidSource.class]) return [(TTVideoEngineVidSource *)source startTime];
    if ([source isKindOfClass:TTVideoEngineUrlSource.class]) return [(TTVideoEngineUrlSource *)source startTime];
    if ([source isKindOfClass:TTVideoEngineVideoModelSource.class]) return [(TTVideoEngineVideoModelSource *)source startTime];
    return 0;
}

NSString *MDSourceIdentity(id<TTVideoEngineMediaSource> source) {
    NSString *parameters = @"";
    if ([source isKindOfClass:TTVideoEngineVidSource.class]) {
        TTVideoEngineVidSource *vid = (id)source;
        parameters = [NSString stringWithFormat:@"%ld/%ld/%ld/%d/%d/%@/%@/%@",
                      (long)vid.resolution, (long)vid.encodeType, (long)vid.codecStrategy,
                      vid.isHLS, vid.isDash, vid.playAuthToken, vid.urlExtendParams, vid.customHeaders];
    } else if ([source isKindOfClass:TTVideoEngineUrlSource.class]) {
        TTVideoEngineUrlSource *url = (id)source;
        parameters = [NSString stringWithFormat:@"%@/%@", url.urls, url.customHeaders];
    } else if ([source isKindOfClass:TTVideoEngineVideoModelSource.class]) {
        TTVideoEngineVideoModelSource *model = (id)source;
        parameters = [NSString stringWithFormat:@"%ld/%p/%@", (long)model.resolution, model.videoModel, model.customHeaders];
    }
    return [NSString stringWithFormat:@"%@/%.3f/%@", source.uniqueId, MDSourceStartTime(source), parameters];
}

@interface MDCacheTask : NSObject
@property (nonatomic, strong) TTVideoEnginePreloaderItem *item;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, copy) void (^completion)(NSError *);
@end
@implementation MDCacheTask
@end

@interface MDCacheLoader ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, MDCacheTask *> *tasks;
@end

@implementation MDCacheLoader
- (instancetype)init {
    if ((self = [super init])) _tasks = [NSMutableDictionary dictionary];
    return self;
}

- (BOOL)preload:(id<TTVideoEngineMediaSource>)source bytes:(NSInteger)bytes completion:(void (^)(NSError *))completion {
    NSAssert(NSThread.isMainThread, @"Preload ownership must be updated on main thread");
    if (!source.uniqueId.length || bytes <= 0) return NO;
    NSString *identity = MDSourceIdentity(source);
    if (self.tasks[identity]) {
        return YES; // Do not recreate tasks in the same window, even after completion.
    }
    NSInteger startMS = (NSInteger)llround(MAX(0, MDSourceStartTime(source)) * 1000);
    if (source.sourceType == TTVideoEngineSourceTypeDirectUrl && startMS > 0) {
        NSLog(@"[MDPreload] URL resume preload unsupported by this SDK public item API; use VideoModel");
        return NO;
    }
    MDCacheTask *task = [MDCacheTask new];
    task.completion = completion;
    self.tasks[identity] = task;
    if (source.sourceType == TTVideoEngineSourceTypeVideoId) {
        TTVideoEnginePreloaderVidItem *item = [TTVideoEnginePreloaderVidItem vidItemWithVideoSource:source preloadSize:bytes];
        if (!item) {
            [self finishTask:task identity:identity error:[NSError errorWithDomain:@"MDPreload" code:1 userInfo:nil]];
            return NO;
        }
        task.item = item;
        if (startMS > 0) {
            // The VID item has no timestamp parameter; fetch the model first, then preload the resume position with a VideoModel item.
            item.onlyFetchVideoModel = YES;
            __weak typeof(self) weakSelf = self;
            __weak MDCacheTask *weakTask = task;
            __weak TTVideoEnginePreloaderVidItem *weakFetchItem = item;
            item.fetchDataEnd = ^(TTVideoEngineModel *model, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MDCacheLoader *loader = weakSelf;
                    MDCacheTask *task = weakTask;
                    if (!loader || !task || loader.tasks[identity] != task ||
                        task.item != weakFetchItem || task.finished) return;
                    if (!model || error) {
                        [loader finishTask:task identity:identity error:error ?: [NSError errorWithDomain:@"MDPreload" code:2 userInfo:nil]];
                        return;
                    }
                    TTVideoEngineVidSource *vid = (id)source;
                    TTVideoEngineVideoModelSource *modelSource = [[TTVideoEngineVideoModelSource alloc] initWithVid:vid.vid resolution:vid.resolution videoModel:model];
                    modelSource.customHeaders = vid.customHeaders;
                    modelSource.startTime = MDSourceStartTime(source);
                    [loader addModelSource:modelSource bytes:bytes startMS:startMS task:task identity:identity];
                });
            };
            // Finishing the model fetch does not mean the media download has finished.
            item.preloadCanceled = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    MDCacheTask *task = weakTask;
                    if (task.item == weakFetchItem) [weakSelf finishTask:task identity:identity error:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]];
                });
            };
        } else {
            [self observeItem:item task:task identity:identity];
        }
        [TTVideoEngine ls_addTaskWithVidItem:item];
    } else if (source.sourceType == TTVideoEngineSourceTypeDirectUrl) {
        TTVideoEnginePreloaderURLItem *item = [TTVideoEnginePreloaderURLItem urlItemWithVideoSource:source preloadSize:bytes];
        if (!item) {
            [self finishTask:task identity:identity error:[NSError errorWithDomain:@"MDPreload" code:1 userInfo:nil]];
            return NO;
        }
        task.item = item;
        [self observeItem:item task:task identity:identity];
        [TTVideoEngine ls_addTaskWithURLItem:item];
    } else if (source.sourceType == TTVideoEngineSourceTypeVideoModel) {
        [self addModelSource:source bytes:bytes startMS:startMS task:task identity:identity];
    } else {
        [self.tasks removeObjectForKey:identity];
        return NO;
    }
    return YES;
}

- (void)addModelSource:(id<TTVideoEngineMediaSource>)source bytes:(NSInteger)bytes startMS:(NSInteger)startMS task:(MDCacheTask *)task identity:(NSString *)identity {
    TTVideoEnginePreloaderVideoModelItem *item = [TTVideoEnginePreloaderVideoModelItem videoModelItemWithVideoSource:source preloadSize:bytes params:nil];
    if (!item) {
        [self finishTask:task identity:identity error:[NSError errorWithDomain:@"MDPreload" code:1 userInfo:nil]];
        return;
    }
    item.preloadTimestamp = startMS; // SDK timestamp for precise preloading, in milliseconds.
    task.item = item;
    [self observeItem:item task:task identity:identity];
    [TTVideoEngine ls_addTaskWithVideoModelItem:item];
}

- (void)observeItem:(TTVideoEnginePreloaderItem *)item task:(MDCacheTask *)task identity:(NSString *)identity {
    __weak typeof(self) weakSelf = self;
    __weak MDCacheTask *weakTask = task;
    __weak TTVideoEnginePreloaderItem *weakItem = item;
    item.preloadEnd = ^(TTVideoEngineLocalServerTaskInfo *info, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MDCacheTask *task = weakTask;
            if (task.item == weakItem) [weakSelf finishTask:task identity:identity error:error];
        });
    };
    item.preloadCanceled = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            MDCacheTask *task = weakTask;
            if (task.item == weakItem) [weakSelf finishTask:task identity:identity error:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]];
        });
    };
    item.preloadProgress = ^(TTVideoEngineLoadProgress *progress) {
#if DEBUG
        // This reports cache writes. Playback cache hits are reported by the original player callback.
        for (TTVideoEngineLoadCacheInfo *info in progress.cacheInfos) {
            NSLog(@"[MDPreload] key=%@ file=%@ offset=%ld bytes=%ld ranges=%lu",
                  info.cacheKey, info.localFilePath, (long)info.preloadOffset,
                  (long)info.preloadSize, (unsigned long)info.cacheRanges.count);
            for (TTVideoEngineCacheRange *range in info.cacheRanges) {
                NSLog(@"[MDPreloadRange] key=%@ offset=%ld bytes=%ld", info.cacheKey, (long)range.offset, (long)range.size);
            }
        }
#endif
    };
}

- (void)finishTask:(MDCacheTask *)task identity:(NSString *)identity error:(NSError *)error {
    if (!task || self.tasks[identity] != task || task.finished) return;
    task.finished = YES;
    task.item = nil;
    void (^completion)(NSError *) = task.completion;
    task.completion = nil;
    if (completion) completion(error);
}

- (void)stopTask:(id<TTVideoEngineMediaSource>)source {
    NSString *identity = MDSourceIdentity(source);
    MDCacheTask *task = self.tasks[identity];
    [self.tasks removeObjectForKey:identity]; // Revoke ownership first to prevent cancel or model-fetch callbacks from recreating the task.
    task.completion = nil;
    [task.item cancel];
}

- (void)stopAll {
    NSArray<MDCacheTask *> *tasks = self.tasks.allValues;
    [self.tasks removeAllObjects];
    for (MDCacheTask *task in tasks) {
        task.completion = nil;
        [task.item cancel];
    }
}

- (void)dealloc {
    [self stopAll];
}
@end
