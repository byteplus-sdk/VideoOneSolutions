//
//  MDVideoPlayerController+Resolution.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/5.
//

#import "MDVideoPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoPlayerController (Resolution)

+ (TTVideoEngineResolutionType)getPlayerCurrentResolution;

+ (void)setPlayerCurrentResolution:(TTVideoEngineResolutionType)defaultResolution;

@end

NS_ASSUME_NONNULL_END
