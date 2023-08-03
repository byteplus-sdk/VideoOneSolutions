// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LivePlayerManager.h"

@interface LivePlayerManager ()

@property (nonatomic, strong) BytedPlayerProtocol *player;

@property (nonatomic, copy) NSDictionary <NSString *, NSString *> *currentUrlMap;
@property (nonatomic, copy) NSString *currentResolution;
@end

@implementation LivePlayerManager

+ (LivePlayerManager *_Nullable)sharePlayer {
    static LivePlayerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LivePlayerManager alloc] init];
    });
    return manager;
}

#pragma mark - Publish Action

- (void)startWithConfiguration {
    [self.player startWithConfiguration];
}

- (void)setPlayerWithUrlMap:(NSDictionary <NSString *, NSString *> *)urlMap
          defaultResolution:(NSString *)defaultResolution
               superView:(UIView *)superView
                SEIBlcok:(void (^)(NSDictionary *SEIDic))SEIBlcok {
    // Use the player to pull CDN audio and video streams
    if (urlMap != nil && ![_currentUrlMap isEqualToDictionary:urlMap]) {
        self.currentUrlMap = urlMap;
        self.currentResolution = defaultResolution;
        [self.player setPlayerWithUrlMap:urlMap
                       defaultResolution:defaultResolution
                               superView:superView
                                SEIBlcok:SEIBlcok];
    }
}

- (BOOL)isSupportSEI {
    // Whether the player supports parsing SEI
    return [self.player isSupportSEI];
}

- (void)replacePlayWithUrlMap:(NSDictionary <NSString *, NSString *> *)urlMap defaultResolution:(NSString *)defaultResolution {
    if (urlMap == nil) {
        [self stopPull];
        return;
    }
    // The player updates the pull stream address
    if ([_currentUrlMap isEqualToDictionary:urlMap] && [self.currentResolution isEqualToString:defaultResolution]) {
        return;
    }
    self.currentUrlMap = urlMap;
    self.currentResolution = defaultResolution;
    [self.player replacePlayWithUrlMap:urlMap defaultResolution:defaultResolution];
    [self.player play];
}

- (void)stopPull {
    // The player stops pulling the stream
    self.currentUrlMap = nil;
    self.currentResolution = nil;
    if (self.player) {
        [self.player stop];
        [self.player destroy];
    }
}

- (void)playPull {
    if (self.player) {
        [self.player play];
    }
}

- (void)updatePlayScaleMode:(PullScalingMode)scalingMode {
    [self.player updatePlayScaleMode:scalingMode];
}
- (NSDictionary *)getPlayeInfo {
    return [self.player getPlayInfo];
}
#pragma mark - Getter

- (BytedPlayerProtocol *)player {
    if (!_player) {
        _player = [[BytedPlayerProtocol alloc] init];
    }
    return _player;
}

@end
