// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BytedPlayerProtocol.h"

@interface BytedPlayerProtocol ()

@property (nonatomic, strong) id<BytedPlayerDelegate> bytePlayerDeleagte;

@end

@implementation BytedPlayerProtocol

- (instancetype)init {
    if (self = [super init]) {
        NSObject<BytedPlayerDelegate> *playerComponent = [[NSClassFromString(@"BytePlayerComponent") alloc] init];
        if (playerComponent) {
            self.bytePlayerDeleagte = playerComponent;
        }
    }

    return self;
}

- (void)setPlayerWithUrlMap:(NSDictionary<NSString *, NSString *> *)urlMap defaultResolution:(NSString *)defaultResolution superView:(UIView *)superView SEIBlcok:(void (^)(NSDictionary *_Nonnull))SEIBlcok {
    if ([self.bytePlayerDeleagte respondsToSelector:@selector(protocol:setPlayWithUrlMap:defaultResolution:superView:SEIBlcok:)]) {
        [self.bytePlayerDeleagte protocol:self setPlayWithUrlMap:urlMap defaultResolution:defaultResolution superView:superView SEIBlcok:SEIBlcok];
    }
}

- (void)updatePlayScaleMode:(PullScalingMode)scalingMode {
    if ([self.bytePlayerDeleagte respondsToSelector:@selector(protocol:updatePlayScaleMode:)]) {
        [self.bytePlayerDeleagte protocol:self updatePlayScaleMode:scalingMode];
    }
}

- (void)play {
    if ([self.bytePlayerDeleagte respondsToSelector:@selector(protocolDidPlay:)]) {
        [self.bytePlayerDeleagte protocolDidPlay:self];
    }
}

- (void)replacePlayWithUrlMap:(NSDictionary<NSString *, NSString *> *)urlMap defaultResolution:(NSString *)defaultResolution {
    if ([self.bytePlayerDeleagte respondsToSelector:@selector(protocol:replaceWithUrlMap:defaultResolution:)]) {
        [self.bytePlayerDeleagte protocol:self replaceWithUrlMap:urlMap defaultResolution:defaultResolution];
    }
}

- (void)stop {
    if ([self.bytePlayerDeleagte respondsToSelector:@selector(protocolDidStop:)]) {
        [self.bytePlayerDeleagte protocolDidStop:self];
    }
}

- (BOOL)isSupportSEI {
    if ([self.bytePlayerDeleagte respondsToSelector:@selector(protocolIsSupportSEI)]) {
        return [self.bytePlayerDeleagte protocolIsSupportSEI];
    } else {
        return NO;
    }
}

- (void)startWithConfiguration {
    if ([self.bytePlayerDeleagte respondsToSelector:@selector(protocolStartWithConfiguration)]) {
        [self.bytePlayerDeleagte protocolStartWithConfiguration];
    }
}

- (void)destroy {
    if ([self.bytePlayerDeleagte respondsToSelector:@selector(protocolDestroy:)]) {
        [self.bytePlayerDeleagte protocolDestroy:self];
    }
}

- (NSDictionary *)getPlayInfo {
    if ([self.bytePlayerDeleagte respondsToSelector:@selector(protocolGetPlayInfo)]) {
        return [self.bytePlayerDeleagte protocolGetPlayInfo];
    }
    return @{};
}

@end
