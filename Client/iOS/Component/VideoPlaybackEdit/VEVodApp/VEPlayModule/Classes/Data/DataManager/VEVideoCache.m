// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoCache.h"
#import <YYCache/YYCache.h>
#import <TTSDK/TTVideoEngineModel.h>

@interface VEVideoCache ()

@property (nonatomic, strong) YYMemoryCache *yyCache;

@end

@implementation VEVideoCache

+ (instancetype)shared {
    static VEVideoCache * _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.yyCache = [YYMemoryCache new];
        self.yyCache.name = @"com.byteplus.videoone.vod";
    }
    return self;
}

- (TTVideoEngineModel *)videoForKey:(NSString *)key {
    TTVideoEngineModel *videoMode = [self.yyCache objectForKey:key];
    if (videoMode != nil && [videoMode hasExpired]) {
        [self.yyCache removeObjectForKey:key];
        return nil;
    }
    return videoMode;
}

- (void)setVideo:(TTVideoEngineModel *)object forKey:(NSString *)key {
    [self.yyCache setObject:object forKey:key];
}

- (void)removeVideoForKey:(NSString *)key {
    [self.yyCache removeObjectForKey:key];
}

- (void)removeAllVideos {
    [self.yyCache removeAllObjects];
}

@end
