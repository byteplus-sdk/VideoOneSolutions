// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>
#import "BytedPlayerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LivePlayerManager : NSObject

+ (LivePlayerManager *_Nullable)sharePlayer;

/**
 * @brief start configuration Player
 */

- (void)startWithConfiguration;


/**
 * @brief Set playback address, parent view
 * @param urlMap Clarity pull streaming address
 * @param defaultResolution default resolution
 * @param superView parent class view
 * @param SEIBlcok SEI callback
 */

- (void)setPlayerWithUrlMap:(NSDictionary <NSString *, NSString *> *)urlMap
          defaultResolution:(NSString *)defaultResolution
               superView:(UIView *)superView
                SEIBlcok:(void (^)(NSDictionary *SEIDic))SEIBlcok;

/**
 * @brief start playing
 */

- (void)playPull;

/**
 * @brief stop playback
 */

- (void)stopPull;

/**
 * @brief Whether the player supports SEI function
 * @return BOOL YES supports SEI, NO does not support SEI
 */

- (BOOL)isSupportSEI;

/**
 * @brief update playback scale mode
 * @param scalingMode playback scale mode
 */

- (void)updatePlayScaleMode:(PullScalingMode)scalingMode;

/**
 * @brief Update the new playback address
 * @param url new play URL
 */

- (void)replacePlayWithUrlMap:(NSDictionary <NSString *, NSString *> *)urlMap defaultResolution:(NSString *)defaultResolution;

- (NSDictionary *)getPlayeInfo;
@end

NS_ASSUME_NONNULL_END
