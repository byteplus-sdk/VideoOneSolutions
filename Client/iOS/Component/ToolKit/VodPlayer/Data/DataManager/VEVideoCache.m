// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoCache.h"
#import <YYCache/YYCache.h>
#import <TTSDKFramework/TTSDKFramework.h>

@interface VEVideoCache ()

@property (nonatomic, strong) NSMutableDictionary *videoCacheDic;

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

- (TTVideoEngineModel *)videoForKey:(NSString *)key {
    if (!key || key.length <= 0) {
        return nil;
    }
    TTVideoEngineModel *videoMode = [self.videoCacheDic objectForKey:key];
    if (videoMode != nil && [videoMode hasExpired]) {
        [self.videoCacheDic removeObjectForKey:key];
        return nil;
    }
    return videoMode;
}

- (void)setVideo:(TTVideoEngineModel *)object forKey:(NSString *)key {
    if (!object || !key || key.length <= 0) {
        return;
    }
    [self.videoCacheDic setObject:object forKey:key];
}

- (void)removeVideoForKey:(NSString *)key {
    if (!key || key.length <= 0) {
        return;
    }
    [self.videoCacheDic removeObjectForKey:key];
}

- (void)removeAllVideos {
    [self.videoCacheDic removeAllObjects];
}

- (NSMutableDictionary *)videoCacheDic {
    if (!_videoCacheDic) {
        _videoCacheDic = [[NSMutableDictionary alloc] init];
    }
    return _videoCacheDic;
}

@end
